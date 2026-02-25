module GiacBackendExt

using MathJSONComputeEngineBridge
using MathJSON
using Giac
using LinearAlgebra

import MathJSONComputeEngineBridge: compute, GiacBackend, UnsupportedOperationError

include("operators.jl")
include("conversion_to_giac.jl")
include("conversion_to_mathjson.jl")
include("fallback.jl")

# --- Public to_giac wrapper (concrete types to avoid method overwrite) ---
MathJSONComputeEngineBridge.to_giac(expr::NumberExpr) = convert_to_giac(expr)
MathJSONComputeEngineBridge.to_giac(expr::SymbolExpr) = convert_to_giac(expr)
MathJSONComputeEngineBridge.to_giac(expr::StringExpr) = convert_to_giac(expr)
MathJSONComputeEngineBridge.to_giac(expr::FunctionExpr) = convert_to_giac(expr)

# --- PlutoMathInput normalization ---

"""
Normalize PlutoMathInput Function/Limits argument patterns to direct form.

Converts:
  Integrate(Function(Block(body), var), Limits(var, Nothing, Nothing)) → Integrate(body, var)
  Integrate(Function(Block(body), var), Limits(var, lo, hi))           → Integrate(body, var, lo, hi)

Returns args unchanged if the pattern doesn't match.
"""
function _normalize_plutomathinput_args(args::Vector{<:AbstractMathJSONExpr})
    length(args) == 2 || return args

    func_arg = args[1]
    limits_arg = args[2]

    # Check for Function/Limits pattern
    (func_arg isa FunctionExpr && func_arg.operator == :Function) || return args
    (limits_arg isa FunctionExpr && limits_arg.operator == :Limits) || return args

    # Validate Function has >= 2 args
    if length(func_arg.arguments) < 2
        throw(ArgumentError("Function requires at least 2 arguments (body, variable), got $(length(func_arg.arguments))"))
    end

    # Validate Limits has >= 3 args
    if length(limits_arg.arguments) < 3
        throw(ArgumentError("Limits requires at least 3 arguments (variable, lower, upper), got $(length(limits_arg.arguments))"))
    end

    # Extract body from Function(Block(body), var)
    body = func_arg.arguments[1]
    if body isa FunctionExpr && body.operator == :Block
        if isempty(body.arguments)
            throw(ArgumentError("Block requires at least one child expression"))
        end
        body = body.arguments[end]  # Last expression in Block
    end

    # Extract variable from Function's 2nd argument
    var = func_arg.arguments[2]

    # Extract bounds from Limits(var, lower, upper)
    lower = limits_arg.arguments[2]
    upper = limits_arg.arguments[3]

    # Check if bounds are Nothing (indefinite)
    lower_is_nothing = lower isa SymbolExpr && lower.name == "Nothing"
    upper_is_nothing = upper isa SymbolExpr && upper.name == "Nothing"

    if lower_is_nothing && upper_is_nothing
        return AbstractMathJSONExpr[body, var]  # Indefinite
    else
        return AbstractMathJSONExpr[body, var, lower, upper]  # Definite
    end
end

# --- compute methods for GiacBackend ---

function compute(::GiacBackend, expr::NumberExpr)
    g = convert_to_giac(expr)
    return convert_to_mathjson(g)
end

function compute(::GiacBackend, expr::SymbolExpr)
    # Nothing sentinel: pass through unchanged
    if expr.name == "Nothing"
        return expr
    end
    # Constants stay as-is (Giac evaluates e → exp(1), Pi → pi, etc.)
    if haskey(GIAC_CONSTANTS, expr.name)
        return expr
    end
    # Non-constant symbols: preserve as symbolic variables
    return expr
end

function compute(::GiacBackend, expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments

    # --- Block passthrough (evaluate all, return last) ---
    if op == :Block
        if isempty(args)
            throw(ArgumentError("Block requires at least one child expression"))
        end
        for i in 1:length(args)-1
            compute(GiacBackend(), args[i])
        end
        return compute(GiacBackend(), args[end])
    end

    # --- Normalize PlutoMathInput Function/Limits args for calculus ops ---
    if op in (:Integrate, :Sum, :Product, :Limit, :D)
        args = _normalize_plutomathinput_args(args)
        expr = FunctionExpr(op, args)
    end

    # IsPrime needs special handling: Giac returns 0/1, we want True/False
    if op == :IsPrime
        giac_arg = convert_to_giac(expr.arguments[1])
        result = Giac.invoke_cmd(:isprime, giac_arg)
        val = Giac.to_julia(result)
        return SymbolExpr(val == 1 ? "True" : "False")
    end

    # Matrix operations need special result handling
    if op in (:Determinant, :Transpose, :Inverse)
        giac_arg = convert_to_giac(expr.arguments[1])
        if giac_arg isa Giac.GiacMatrix
            if op == :Determinant
                result = LinearAlgebra.det(giac_arg)
                return convert_to_mathjson(result)
            elseif op == :Transpose
                result = Base.transpose(giac_arg)
                return convert_to_mathjson(result)
            elseif op == :Inverse
                result = Base.inv(giac_arg)
                return convert_to_mathjson(result)
            end
        end
    end

    # General case: convert to GiacExpr, then convert result back
    result = convert_to_giac(expr)
    if result isa Giac.GiacMatrix
        return convert_to_mathjson(result)
    end
    return convert_to_mathjson(result)
end

# --- __init__: Set GiacBackend as default when Giac is loaded ---

function __init__()
    if !MathJSONComputeEngineBridge._explicit_default[]
        MathJSONComputeEngineBridge.set_default_backend!(GiacBackend())
        # Reset the explicit flag since this was automatic, not user-requested
        MathJSONComputeEngineBridge._explicit_default[] = false
    end
end

end

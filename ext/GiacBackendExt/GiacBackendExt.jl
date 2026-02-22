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

# --- compute methods for GiacBackend ---

function compute(::GiacBackend, expr::NumberExpr)
    g = convert_to_giac(expr)
    return convert_to_mathjson(g)
end

function compute(::GiacBackend, expr::SymbolExpr)
    # Constants stay as-is (Giac evaluates e → exp(1), Pi → pi, etc.)
    if haskey(GIAC_CONSTANTS, expr.name)
        return expr
    end
    # Non-constant symbols: preserve as symbolic variables
    return expr
end

function compute(::GiacBackend, expr::FunctionExpr)
    op = expr.operator

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

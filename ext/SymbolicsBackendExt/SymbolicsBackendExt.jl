module SymbolicsBackendExt

using MathJSONComputeEngineBridge
using MathJSON
using Symbolics
using LinearAlgebra

import MathJSONComputeEngineBridge: compute, SymbolicsBackend, UnsupportedOperationError

include("operators.jl")
include("conversion_to_symbolics.jl")
include("conversion_to_mathjson.jl")

# --- compute methods for SymbolicsBackend ---

function compute(::SymbolicsBackend, expr::NumberExpr)
    val = convert_to_symbolics(expr)
    return convert_to_mathjson(val)
end

function compute(::SymbolicsBackend, expr::SymbolExpr)
    # Constants stay as-is
    if haskey(SYMBOLICS_CONSTANTS, expr.name)
        return expr
    end
    # Non-constant symbols: preserve as symbolic variables
    return expr
end

function compute(::SymbolicsBackend, expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments

    # Check for unsupported operations first
    if haskey(UNSUPPORTED_OPS, op)
        suggested = UNSUPPORTED_OPS[op]
        throw(UnsupportedOperationError(op, SymbolicsBackend(), suggested))
    end

    # --- Symbolic algebra operations ---

    if op == :Expand
        sym_expr = convert_to_symbolics(args[1])
        result = Symbolics.expand(sym_expr)
        return convert_to_mathjson(result)
    end

    if op == :Simplify
        sym_expr = convert_to_symbolics(args[1])
        result = Symbolics.simplify(sym_expr)
        return convert_to_mathjson(result)
    end

    if op == :Substitute
        # Substitute(expr, var1, val1, var2, val2, ...)
        sym_expr = convert_to_symbolics(args[1])
        substitutions = Dict{Symbolics.Num,Any}()
        i = 2
        while i + 1 <= length(args)
            var = convert_to_symbolics(args[i])
            val = convert_to_symbolics(args[i + 1])
            substitutions[var] = val
            i += 2
        end
        result = Symbolics.substitute(sym_expr, substitutions)
        return convert_to_mathjson(result)
    end

    # --- Calculus operations ---

    if op == :D
        # D(f, x) — differentiation
        sym_f = convert_to_symbolics(args[1])
        sym_x = convert_to_symbolics(args[2])
        result = Symbolics.derivative(sym_f, sym_x)
        return convert_to_mathjson(result)
    end

    # --- Equation solving ---

    if op == :Solve
        # Solve(expr, var) — solve equation expr = 0 for var
        sym_expr = convert_to_symbolics(args[1])
        sym_var = convert_to_symbolics(args[2])
        # Try symbolic_solve first (needs Nemo.jl for polynomial roots)
        try
            solutions = Symbolics.symbolic_solve(sym_expr, sym_var)
            return convert_to_mathjson(solutions)
        catch
            # Fall back to solve_for for linear equations (expr ~ 0)
            try
                eq = sym_expr ~ 0
                solutions = Symbolics.solve_for([eq], [sym_var])
                return convert_to_mathjson(solutions)
            catch
                throw(UnsupportedOperationError(:Solve, SymbolicsBackend(), ["GiacBackend"]))
            end
        end
    end

    # --- Matrix operations ---

    if op == :Determinant
        sym_mat = convert_to_symbolics(args[1])
        result = LinearAlgebra.det(sym_mat)
        return convert_to_mathjson(result)
    end

    if op == :Transpose
        sym_mat = convert_to_symbolics(args[1])
        result = Base.transpose(sym_mat)
        return convert_to_mathjson(result)
    end

    if op == :Inverse
        sym_mat = convert_to_symbolics(args[1])
        result = Base.inv(sym_mat)
        return convert_to_mathjson(result)
    end

    # --- Code generation ---

    if op == :Build
        # Build(expr, var1, var2, ...) — generate callable function
        sym_expr = convert_to_symbolics(args[1])
        sym_vars = [convert_to_symbolics(arg) for arg in args[2:end]]
        Symbolics.build_function(sym_expr, sym_vars...; expression=Val{false})
        # Return a representation with the symbolic expression
        return FunctionExpr(:CompiledFunction, AbstractMathJSONExpr[StringExpr(string(sym_expr))])
    end

    # --- General case: arithmetic and transcendental operations ---
    # These are handled by convert_to_symbolics which builds the Symbolics expression tree
    result = convert_to_symbolics(expr)
    return convert_to_mathjson(result)
end

# --- __init__: Set SymbolicsBackend as default when Symbolics is loaded ---

function __init__()
    if !MathJSONComputeEngineBridge._explicit_default[]
        MathJSONComputeEngineBridge.set_default_backend!(SymbolicsBackend())
        # Reset the explicit flag since this was automatic, not user-requested
        MathJSONComputeEngineBridge._explicit_default[] = false
    end
end

end

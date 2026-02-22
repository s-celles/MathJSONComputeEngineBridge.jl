# MathJSON -> Symbolics Num conversion
# Recursively converts MathJSON expression trees to Symbolics Num values

# Variable cache: same MathJSON symbol name must always map to same Num variable
# (required for referential equality in substitute/derivative operations)
const VAR_CACHE = Dict{String,Symbolics.Num}()

"""
    get_or_create_variable(name::String) -> Num

Get a cached Symbolics variable or create a new one.
Ensures the same symbol name always produces the same Num object.
"""
function get_or_create_variable(name::String)
    return get!(VAR_CACHE, name) do
        Symbolics.variable(Symbol(name))
    end
end

"""
    convert_to_symbolics(expr::NumberExpr)

Convert a MathJSON number to a plain Julia number (for use in Symbolics expressions).
"""
function convert_to_symbolics(expr::NumberExpr)
    return expr.value
end

"""
    convert_to_symbolics(expr::SymbolExpr)

Convert a MathJSON symbol to a Symbolics Num.
Constants (Pi, ExponentialE) map to Julia irrationals wrapped in Num.
Other symbols become cached Symbolics variables.
"""
function convert_to_symbolics(expr::SymbolExpr)
    name = expr.name
    if haskey(SYMBOLICS_CONSTANTS, name)
        return Symbolics.Num(SYMBOLICS_CONSTANTS[name])
    end
    return get_or_create_variable(name)
end

"""
    convert_to_symbolics(expr::StringExpr)

Convert a MathJSON string to a Symbolics variable (treating it as a symbol name).
"""
function convert_to_symbolics(expr::StringExpr)
    return get_or_create_variable(expr.value)
end

"""
    convert_to_symbolics(expr::FunctionExpr)

Convert a MathJSON function expression to a Symbolics Num value.
Handles arithmetic, unary, List, and Matrix operations.
"""
function convert_to_symbolics(expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments

    # List passthrough: recursively convert elements
    if op == :List
        return [convert_to_symbolics(arg) for arg in args]
    end

    # Matrix: convert to Matrix{Num}
    if op == :Matrix
        rows = [convert_to_symbolics(arg) for arg in args]
        # Each row should be a Vector; build a matrix
        nrows = length(rows)
        ncols = length(rows[1])
        mat = Matrix{Symbolics.Num}(undef, nrows, ncols)
        for i in 1:nrows
            for j in 1:ncols
                mat[i, j] = rows[i][j]
            end
        end
        return mat
    end

    # Arithmetic operations (variadic, use operator overloads)
    if haskey(SYMBOLICS_ARITHMETIC_OPS, op)
        f = SYMBOLICS_ARITHMETIC_OPS[op]
        sym_args = [convert_to_symbolics(arg) for arg in args]
        if length(sym_args) == 1 && op == :Subtract
            return -sym_args[1]
        elseif length(sym_args) == 2
            return f(sym_args[1], sym_args[2])
        else
            return reduce(f, sym_args)
        end
    end

    # Unary transcendental operations (Base extensions on Num)
    if haskey(SYMBOLICS_UNARY_OPS, op)
        f = SYMBOLICS_UNARY_OPS[op]
        sym_arg = convert_to_symbolics(args[1])
        return f(sym_arg)
    end

    # If we get here, the operation needs special handling (Expand, Simplify, etc.)
    # Those are handled in the compute dispatch, not in conversion.
    # Return the raw converted arguments for the caller to handle.
    error("convert_to_symbolics: unhandled FunctionExpr operator :$op")
end

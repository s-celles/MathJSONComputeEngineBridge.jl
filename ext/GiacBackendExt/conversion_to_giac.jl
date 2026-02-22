# MathJSON -> GiacExpr conversion
# Recursively converts MathJSON expression trees to Giac expression trees

"""
    convert_to_giac(expr::NumberExpr) -> GiacExpr

Convert a MathJSON number to a GiacExpr.
"""
function convert_to_giac(expr::NumberExpr)
    val = expr.value
    if val isa Rational
        return convert(Giac.GiacExpr, val)
    else
        return Giac.giac_eval(string(val))
    end
end

"""
    convert_to_giac(expr::SymbolExpr) -> GiacExpr

Convert a MathJSON symbol to a GiacExpr.
Constants (Pi, ExponentialE, ImaginaryUnit) map to Giac.Constants.
Other symbols become Giac symbolic variables.
"""
function convert_to_giac(expr::SymbolExpr)
    name = expr.name
    if haskey(GIAC_CONSTANTS, name)
        const_sym = GIAC_CONSTANTS[name]
        if const_sym == :pi
            return convert(Giac.GiacExpr, Giac.Constants.pi)
        elseif const_sym == :e
            return convert(Giac.GiacExpr, Giac.Constants.e)
        elseif const_sym == :i
            return convert(Giac.GiacExpr, Giac.Constants.i)
        end
    end
    return Giac.giac_eval(name)
end

"""
    convert_to_giac(expr::StringExpr) -> GiacExpr

Convert a MathJSON string to a GiacExpr via string evaluation.
"""
function convert_to_giac(expr::StringExpr)
    return Giac.giac_eval(expr.value)
end

"""
    convert_to_giac(expr::FunctionExpr) -> GiacExpr

Convert a MathJSON function expression to a GiacExpr.
Handles arithmetic ops, unary ops, Giac commands, matrix ops, and fallback.
"""
function convert_to_giac(expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments

    # List/Matrix passthrough: recursively convert elements
    if op == :List
        giac_args = [convert_to_giac(arg) for arg in args]
        # Build Giac vector string
        arg_strs = [string(g) for g in giac_args]
        return Giac.giac_eval("[" * join(arg_strs, ",") * "]")
    end

    if op == :Matrix
        # Matrix is a list of lists - convert to GiacMatrix
        row_exprs = [convert_to_giac(arg) for arg in args]
        return Giac.GiacMatrix(row_exprs)
    end

    # Arithmetic operations (variadic, use operator overloads)
    if haskey(GIAC_ARITHMETIC_OPS, op)
        f = GIAC_ARITHMETIC_OPS[op]
        giac_args = [convert_to_giac(arg) for arg in args]
        if length(giac_args) == 1 && op == :Subtract
            return -giac_args[1]
        elseif length(giac_args) == 2
            return f(giac_args[1], giac_args[2])
        else
            return reduce(f, giac_args)
        end
    end

    # Unary transcendental operations (Base extensions on GiacExpr)
    if haskey(GIAC_UNARY_OPS, op)
        f = GIAC_UNARY_OPS[op]
        giac_arg = convert_to_giac(args[1])
        return f(giac_arg)
    end

    # Giac commands (Factor, Expand, Solve, D, Integrate, etc.)
    if haskey(GIAC_COMMANDS, op)
        giac_cmd = GIAC_COMMANDS[op]
        giac_args = [convert_to_giac(arg) for arg in args]

        # Special handling for matrix operations: Determinant, Transpose, Inverse
        if op == :Determinant && giac_args[1] isa Giac.GiacMatrix
            return LinearAlgebra.det(giac_args[1])
        elseif op == :Transpose && giac_args[1] isa Giac.GiacMatrix
            return Base.transpose(giac_args[1])
        elseif op == :Inverse && giac_args[1] isa Giac.GiacMatrix
            return Base.inv(giac_args[1])
        end

        # IsPrime returns 0/1 from Giac - handled in compute dispatch
        return Giac.invoke_cmd(giac_cmd, giac_args...)
    end

    # InverseFunction meta-operator
    if op == :InverseFunction
        # Resolve via INVERSE_FUNCTION_MAP from julia_backend.jl
        func_name_expr = args[1]
        if func_name_expr isa SymbolExpr
            # Build a new FunctionExpr with the inverse op
            inverse_map = Dict{String,Symbol}(
                "Sin" => :Arcsin, "Cos" => :Arccos, "Tan" => :Arctan,
                "Exp" => :Ln,
            )
            if haskey(inverse_map, func_name_expr.name)
                inverse_op = inverse_map[func_name_expr.name]
                remaining_args = args[2:end]
                return convert_to_giac(FunctionExpr(inverse_op, remaining_args))
            end
        end
    end

    # Fallback: try invoke_cmd with lowercase operator name
    return giac_fallback(op, args)
end

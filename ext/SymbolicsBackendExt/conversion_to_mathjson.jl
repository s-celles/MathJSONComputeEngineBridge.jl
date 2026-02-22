# Symbolics Num -> MathJSON conversion
# Recursively converts Symbolics expression trees back to MathJSON

"""
    convert_to_mathjson(x) -> AbstractMathJSONExpr

Convert a Symbolics result (Num, Number, or BasicSymbolic) to a MathJSON expression.
"""
function convert_to_mathjson(x::Symbolics.Num)
    inner = Symbolics.unwrap(x)
    return convert_to_mathjson(inner)
end

function convert_to_mathjson(x::Number)
    # Handle irrationals (π, ℯ)
    if x === π
        return SymbolExpr("Pi")
    elseif x === ℯ
        return SymbolExpr("ExponentialE")
    end
    # Handle rationals
    if x isa Rational
        if denominator(x) == 1
            return NumberExpr(numerator(x))
        end
        return FunctionExpr(:Divide, AbstractMathJSONExpr[NumberExpr(numerator(x)), NumberExpr(denominator(x))])
    end
    # Handle complex numbers
    if x isa Complex
        if imag(x) == 0
            return convert_to_mathjson(real(x))
        end
        re_mj = convert_to_mathjson(real(x))
        im_mj = convert_to_mathjson(imag(x))
        im_term = FunctionExpr(:Multiply, AbstractMathJSONExpr[im_mj, SymbolExpr("ImaginaryUnit")])
        return FunctionExpr(:Add, AbstractMathJSONExpr[re_mj, im_term])
    end
    return NumberExpr(x)
end

function convert_to_mathjson(x::Symbolics.BasicSymbolic)
    # Symbol (leaf variable)
    if Symbolics.issym(x)
        name = String(nameof(x))
        # Check if it's a known constant
        if name == "π" || name == "pi"
            return SymbolExpr("Pi")
        elseif name == "ℯ" || name == "e"
            return SymbolExpr("ExponentialE")
        end
        return SymbolExpr(name)
    end

    # Callable expression (has operation + arguments)
    if Symbolics.iscall(x)
        op_func = Symbolics.operation(x)
        sym_args = Symbolics.arguments(x)

        # Map the operation function to a MathJSON operator
        if haskey(SYMBOLICS_OP_TO_MATHJSON, op_func)
            mathjson_op = SYMBOLICS_OP_TO_MATHJSON[op_func]
        else
            # Unknown operation — use function name as operator
            mathjson_op = Symbol(string(nameof(op_func)))
        end

        # Convert arguments recursively
        mj_args = AbstractMathJSONExpr[]
        for arg in sym_args
            try
                push!(mj_args, convert_to_mathjson(arg))
            catch
                # Fallback: wrap unconvertible sub-expression as RawSymbolics
                push!(mj_args, FunctionExpr(:RawSymbolics, AbstractMathJSONExpr[StringExpr(string(arg))]))
            end
        end

        return FunctionExpr(mathjson_op, mj_args)
    end

    # Fallback: wrap as RawSymbolics
    return FunctionExpr(:RawSymbolics, AbstractMathJSONExpr[StringExpr(string(x))])
end

# Handle Vector results (e.g., from solve)
function convert_to_mathjson(x::AbstractVector)
    elements = AbstractMathJSONExpr[]
    for elem in x
        push!(elements, convert_to_mathjson(elem))
    end
    return FunctionExpr(:List, elements)
end

# Handle Matrix results
function convert_to_mathjson(x::AbstractMatrix)
    rows = AbstractMathJSONExpr[]
    for i in axes(x, 1)
        row_elements = AbstractMathJSONExpr[]
        for j in axes(x, 2)
            push!(row_elements, convert_to_mathjson(x[i, j]))
        end
        push!(rows, FunctionExpr(:List, row_elements))
    end
    return FunctionExpr(:Matrix, rows)
end

# Catch-all for anything else
function convert_to_mathjson(x)
    # Try to convert to a number first
    try
        val = Float64(x)
        return NumberExpr(val)
    catch
    end
    # Fallback: wrap as RawSymbolics
    return FunctionExpr(:RawSymbolics, AbstractMathJSONExpr[StringExpr(string(x))])
end

# GiacExpr -> MathJSON conversion
# Recursively converts Giac expression trees back to MathJSON

"""
    convert_to_mathjson(g::Giac.GiacExpr) -> AbstractMathJSONExpr

Convert a GiacExpr to a MathJSON expression using Giac introspection.
"""
function convert_to_mathjson(g::Giac.GiacExpr)
    # Boolean check (Giac represents as INT but string is "true"/"false")
    if Giac.is_boolean(g)
        str = string(g)
        return SymbolExpr(str == "true" ? "True" : "False")
    end

    # Integer
    if Giac.is_integer(g)
        try
            val = Giac.to_julia(g)
            return NumberExpr(val)
        catch
            # Some Giac "integer" types (e.g., ifactor result) have non-numeric string forms
            # Fall through to symbolic handling
        end
    end

    # Float/Real
    if Giac.is_numeric(g)
        try
            val = Giac.to_julia(g)
            return NumberExpr(val)
        catch
            # Fall through to other handlers
        end
    end

    # Fraction (rational)
    if Giac.is_fraction(g)
        num_g = Giac.numer(g)
        den_g = Giac.denom(g)
        num_mj = convert_to_mathjson(num_g)
        den_mj = convert_to_mathjson(den_g)
        return FunctionExpr(:Divide, [num_mj, den_mj])
    end

    # Complex
    if Giac.is_complex(g)
        re_g = Giac.real_part(g)
        im_g = Giac.imag_part(g)
        re_mj = convert_to_mathjson(re_g)
        im_mj = convert_to_mathjson(im_g)
        # Build Add(re, Multiply(im, ImaginaryUnit))
        im_term = FunctionExpr(:Multiply, [im_mj, SymbolExpr("ImaginaryUnit")])
        return FunctionExpr(:Add, [re_mj, im_term])
    end

    # Identifier (symbolic variable)
    if Giac.is_identifier(g)
        name = string(g)
        # Check if it's a known constant
        if name == "pi"
            return SymbolExpr("Pi")
        elseif name == "e"
            return SymbolExpr("ExponentialE")
        elseif name == "i"
            return SymbolExpr("ImaginaryUnit")
        end
        return SymbolExpr(name)
    end

    # Vector (list)
    if Giac.is_vector(g)
        julia_vec = Giac.to_julia(g)
        if julia_vec isa Vector{Giac.GiacExpr}
            # Symbolic vector - convert each element
            elements = [convert_to_mathjson(elem) for elem in julia_vec]
        else
            # Numeric vector
            elements = [NumberExpr(v) for v in julia_vec]
        end
        return FunctionExpr(:List, elements)
    end

    # Symbolic expression (e.g., sin(x), x+1, etc.)
    if Giac.is_symbolic(g)
        return _convert_symbolic_to_mathjson(g)
    end

    # String
    if Giac.is_string(g)
        return StringExpr(string(g))
    end

    # Fallback: wrap as RawGiac
    return FunctionExpr(:RawGiac, [StringExpr(string(g))])
end

"""
    convert_to_mathjson(m::Giac.GiacMatrix) -> FunctionExpr

Convert a GiacMatrix to a MathJSON Matrix expression.
"""
function convert_to_mathjson(m::Giac.GiacMatrix)
    rows = AbstractMathJSONExpr[]
    for i in 1:m.rows
        row_elements = AbstractMathJSONExpr[]
        for j in 1:m.cols
            elem = m[i, j]
            push!(row_elements, convert_to_mathjson(elem))
        end
        push!(rows, FunctionExpr(:List, row_elements))
    end
    return FunctionExpr(:Matrix, rows)
end

"""
    _convert_symbolic_to_mathjson(g::Giac.GiacExpr) -> AbstractMathJSONExpr

Decompose a symbolic GiacExpr into MathJSON using symb_funcname and symb_argument.
"""
function _convert_symbolic_to_mathjson(g::Giac.GiacExpr)
    funcname = Giac.symb_funcname(g)
    arg = Giac.symb_argument(g)

    # Map Giac function name to MathJSON operator
    if haskey(GIAC_FUNCNAME_TO_MATHJSON, funcname)
        mathjson_op = GIAC_FUNCNAME_TO_MATHJSON[funcname]
    else
        # Use the Giac function name as-is for unknown operations
        mathjson_op = Symbol(funcname)
    end

    # The argument might be a sequence (for multi-arg functions like +, *, etc.)
    if Giac.is_vector(arg)
        # Multi-argument: convert each element
        julia_vec = Giac.to_julia(arg)
        if julia_vec isa Vector{Giac.GiacExpr}
            mj_args = [convert_to_mathjson(elem) for elem in julia_vec]
        else
            mj_args = [NumberExpr(v) for v in julia_vec]
        end
    else
        # Single argument
        mj_args = [convert_to_mathjson(arg)]
    end

    # Handle unary minus -> Negate (Giac uses "-" for both subtraction and negation)
    if funcname == "-" && length(mj_args) == 1
        return FunctionExpr(:Negate, mj_args)
    end

    # Handle scalar inv -> Power(x, -1) (Inverse is reserved for matrices in CortexJS)
    if funcname == "inv" && length(mj_args) == 1
        a = mj_args[1]
        if !(a isa FunctionExpr && a.operator == :List)
            return FunctionExpr(:Power, AbstractMathJSONExpr[a, NumberExpr(-1)])
        end
    end

    return FunctionExpr(mathjson_op, mj_args)
end

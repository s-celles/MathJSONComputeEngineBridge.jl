# --- Constants table (T002) ---

const JULIA_CONSTANTS = Dict{String,Number}(
    "Pi" => Float64(π),
    "ExponentialE" => Float64(ℯ),
    "ImaginaryUnit" => im,
)

# --- Complex number handling for ImaginaryUnit ---

"""Convert a Julia numeric value (possibly complex) to a MathJSON expression."""
function _value_to_mathjson(val)
    if val isa Complex && !iszero(imag(val))
        re = real(val)
        im_val = imag(val)
        im_base = SymbolExpr("ImaginaryUnit")
        im_term = if im_val == 1
            im_base
        elseif im_val == -1
            FunctionExpr(:Negate, AbstractMathJSONExpr[im_base])
        else
            FunctionExpr(:Multiply, AbstractMathJSONExpr[_value_to_mathjson(im_val), im_base])
        end
        if iszero(re)
            return im_term
        else
            return FunctionExpr(:Add, AbstractMathJSONExpr[_value_to_mathjson(re), im_term])
        end
    end
    if val isa Complex
        return _value_to_mathjson(real(val))
    end
    return NumberExpr(val)
end

"""Extract a Julia numeric value from a MathJSON expression (handles complex)."""
_to_numeric(expr::NumberExpr) = expr.value

function _to_numeric(expr::SymbolExpr)
    if haskey(JULIA_CONSTANTS, expr.name)
        return JULIA_CONSTANTS[expr.name]
    end
    throw(UnresolvedSymbolError([expr.name]))
end

function _to_numeric(expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments
    if op == :Negate && length(args) == 1
        return -_to_numeric(args[1])
    end
    if op in (:Add, :Subtract, :Multiply, :Divide) && length(args) >= 2
        values = [_to_numeric(arg) for arg in args]
        f = Dict(:Add => +, :Subtract => -, :Multiply => *, :Divide => /)[op]
        return length(values) == 2 ? f(values[1], values[2]) : reduce(f, values)
    end
    throw(ArgumentError("Cannot extract numeric value from FunctionExpr(:$op, ...)"))
end

# --- Variadic/binary arithmetic ops (existing, extended) ---

const JULIA_OPS = Dict{Symbol,Function}(
    :Add => +,
    :Subtract => -,
    :Multiply => *,
    :Divide => /,
)

# --- Unary ops (T003) ---

const JULIA_UNARY_OPS = Dict{Symbol,Function}(
    # Basic
    :Negate => -,
    :Sqrt => sqrt,
    :Square => x -> x^2,
    :Abs => abs,
    # Trigonometric
    :Sin => sin,
    :Cos => cos,
    :Tan => tan,
    :Cot => cot,
    :Sec => sec,
    :Csc => csc,
    # Inverse trigonometric
    :Arcsin => asin,
    :Arccos => acos,
    :Arctan => atan,
    :Arccot => acot,
    :Arcsec => asec,
    :Arccsc => acsc,
    # Hyperbolic
    :Sinh => sinh,
    :Cosh => cosh,
    :Tanh => tanh,
    :Coth => coth,
    :Sech => sech,
    :Csch => csch,
    # Inverse hyperbolic (ISO naming)
    :Arsinh => asinh,
    :Arcosh => acosh,
    :Artanh => atanh,
    :Arcoth => acoth,
    :Arsech => asech,
    :Arcsch => acsch,
    # Exponential & logarithmic
    :Exp => exp,
    :Ln => log,
    :Log2 => log2,
    :Log10 => log10,
    # Number theory (unary)
    :Factorial => factorial,
)

# --- Binary ops (T004) ---

const JULIA_BINARY_OPS = Dict{Symbol,Function}(
    :Power => (x, n) -> (x isa Integer && n isa Integer && n < 0) ? float(x)^n : x^n,
    :Root => (x, n) -> x^(1/n),
    :Binomial => binomial,
    :GCD => gcd,
    :LCM => lcm,
    :Mod => mod,
    :Hypot => hypot,
)

# --- Custom functions (T005) ---

function _sinc(x)
    x == 0 ? one(x) : sin(x) / x
end

function _haversine(θ)
    sin(θ / 2)^2
end

function _inverse_haversine(y)
    2 * asin(sqrt(y))
end

function _isprime(n::Integer)
    n <= 1 && return false
    n <= 3 && return true
    (n % 2 == 0 || n % 3 == 0) && return false
    i = 5
    while i * i <= n
        (n % i == 0 || n % (i + 2) == 0) && return false
        i += 6
    end
    return true
end
_isprime(x) = _isprime(Integer(x))

# --- InverseFunction map (T006) ---

const INVERSE_FUNCTION_MAP = Dict{String,Symbol}(
    "Sin" => :Arcsin,
    "Cos" => :Arccos,
    "Tan" => :Arctan,
    "Cot" => :Arccot,
    "Sec" => :Arcsec,
    "Csc" => :Arccsc,
    "Sinh" => :Arsinh,
    "Cosh" => :Arcosh,
    "Tanh" => :Artanh,
    "Coth" => :Arcoth,
    "Sech" => :Arsech,
    "Csch" => :Arcsch,
    "Exp" => :Ln,
)

# --- Symbolic ops (unchanged) ---

const SYMBOLIC_OPS = Set{Symbol}([
    :Factor, :Expand, :Simplify, :Solve,
    :Integrate, :D, :Limit, :PartialFractions,
    :Sum, :Product, :Laplace, :InverseLaplace,
    :ZTransform, :InverseZTransform,
])

# --- Matrix helpers ---

function _mathjson_to_matrix(expr::FunctionExpr)
    rows = map(expr.arguments) do row
        [e.value for e in row.arguments]
    end
    return hcat([collect(r) for r in rows]...)'  |> Matrix
end

function _matrix_to_mathjson(m::AbstractMatrix)
    rows = [FunctionExpr(:List, [NumberExpr(m[i, j]) for j in 1:size(m, 2)]) for i in 1:size(m, 1)]
    return FunctionExpr(:Matrix, rows)
end

# --- compute methods ---

function compute(backend::JuliaBackend, expr::NumberExpr)
    return expr
end

# (T007) Constants-aware SymbolExpr dispatch
function compute(backend::JuliaBackend, expr::SymbolExpr)
    if expr.name == "Nothing"
        return expr
    end
    if haskey(JULIA_CONSTANTS, expr.name)
        return _value_to_mathjson(JULIA_CONSTANTS[expr.name])
    end
    throw(UnresolvedSymbolError([expr.name]))
end

# (T008) Restructured FunctionExpr dispatch
function compute(backend::JuliaBackend, expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments

    if isempty(args)
        throw(ArgumentError("Empty arguments for operator '$op'"))
    end

    # --- Block passthrough (evaluate all, return last) ---
    if op == :Block
        for i in 1:length(args)-1
            compute(backend, args[i])
        end
        return compute(backend, args[end])
    end

    # --- List/Matrix passthrough ---
    if op == :List || op == :Matrix
        evaluated = [compute(backend, arg) for arg in args]
        return FunctionExpr(op, evaluated)
    end

    # --- InverseFunction meta-operator ---
    if op == :InverseFunction
        func_name_expr = args[1]
        if !(func_name_expr isa SymbolExpr)
            throw(ArgumentError("InverseFunction expects a function name as first argument"))
        end
        func_name = func_name_expr.name
        if !haskey(INVERSE_FUNCTION_MAP, func_name)
            throw(UnsupportedOperationError(:InverseFunction, backend,
                ["GiacBackend", "SymbolicsBackend"]))
        end
        inverse_op = INVERSE_FUNCTION_MAP[func_name]
        remaining_args = args[2:end]
        return compute(backend, FunctionExpr(inverse_op, remaining_args))
    end

    # --- Matrix operations ---
    if op == :Determinant
        mat_expr = compute(backend, args[1])
        m = _mathjson_to_matrix(mat_expr)
        return NumberExpr(det(m))
    end

    if op == :Transpose
        mat_expr = compute(backend, args[1])
        m = _mathjson_to_matrix(mat_expr)
        return _matrix_to_mathjson(transpose(m) |> Matrix)
    end

    if op == :Inverse
        mat_expr = compute(backend, args[1])
        m = _mathjson_to_matrix(mat_expr)
        return _matrix_to_mathjson(inv(m))
    end

    # --- IsPrime (returns SymbolExpr, not NumberExpr) ---
    if op == :IsPrime
        evaluated = compute(backend, args[1])
        result = _isprime(Integer(_to_numeric(evaluated)))
        return SymbolExpr(result ? "True" : "False")
    end

    # --- Special-case Log (variable arity) ---
    if op == :Log
        if length(args) == 1
            evaluated = compute(backend, args[1])
            return _value_to_mathjson(log(_to_numeric(evaluated)))
        elseif length(args) == 2
            eval_val = compute(backend, args[1])
            eval_base = compute(backend, args[2])
            # MathJSON: Log(value, base) → Julia: log(base, value)
            return _value_to_mathjson(log(_to_numeric(eval_base), _to_numeric(eval_val)))
        end
    end

    # --- Special functions (custom implementations) ---
    if op == :Sinc
        evaluated = compute(backend, args[1])
        return _value_to_mathjson(_sinc(_to_numeric(evaluated)))
    end
    if op == :Haversine
        evaluated = compute(backend, args[1])
        return _value_to_mathjson(_haversine(_to_numeric(evaluated)))
    end
    if op == :InverseHaversine
        evaluated = compute(backend, args[1])
        return _value_to_mathjson(_inverse_haversine(_to_numeric(evaluated)))
    end

    # --- Fibonacci ---
    if op == :Fibonacci
        evaluated = compute(backend, args[1])
        n = Integer(_to_numeric(evaluated))
        if n < 0
            throw(ArgumentError("Fibonacci requires a non-negative integer, got $n"))
        end
        return NumberExpr(Int64(Combinatorics.fibonaccinum(n)))
    end

    # --- Permutations P(n, k) = n! / (n-k)! ---
    if op == :Permutations
        eval_n = compute(backend, args[1])
        eval_k = compute(backend, args[2])
        n = Integer(_to_numeric(eval_n))
        k = Integer(_to_numeric(eval_k))
        if k > n
            return NumberExpr(0)
        end
        if k == 0
            return NumberExpr(1)
        end
        result = prod(big(i) for i in (n - k + 1):n)
        return NumberExpr(Int64(result))
    end

    # --- Statistics operations (Mean, Median, Variance, StandardDeviation) ---
    if op in (:Mean, :Median, :Variance, :StandardDeviation)
        list_expr = compute(backend, args[1])
        if !(list_expr isa FunctionExpr && list_expr.operator == :List)
            throw(ArgumentError("$op expects a List argument"))
        end
        if isempty(list_expr.arguments)
            throw(ArgumentError("$op requires a non-empty list"))
        end
        values = Float64[_to_numeric(e) for e in list_expr.arguments]
        result = if op == :Mean
            Statistics.mean(values)
        elseif op == :Median
            Statistics.median(values)
        elseif op == :Variance
            Statistics.var(values; corrected=false)
        else  # :StandardDeviation
            Statistics.std(values; corrected=false)
        end
        return NumberExpr(result)
    end

    # --- Variadic arithmetic ops ---
    if haskey(JULIA_OPS, op)
        evaluated = [compute(backend, arg) for arg in args]
        values = [_to_numeric(e) for e in evaluated]
        f = JULIA_OPS[op]
        result = if length(values) == 2
            f(values[1], values[2])
        else
            reduce(f, values)
        end
        return _value_to_mathjson(result)
    end

    # --- Unary ops ---
    if haskey(JULIA_UNARY_OPS, op)
        evaluated = compute(backend, args[1])
        f = JULIA_UNARY_OPS[op]
        return _value_to_mathjson(f(_to_numeric(evaluated)))
    end

    # --- Binary ops ---
    if haskey(JULIA_BINARY_OPS, op)
        eval1 = compute(backend, args[1])
        eval2 = compute(backend, args[2])
        f = JULIA_BINARY_OPS[op]
        return _value_to_mathjson(f(_to_numeric(eval1), _to_numeric(eval2)))
    end

    # --- Symbolic ops → UnsupportedOperationError ---
    if op in SYMBOLIC_OPS
        throw(UnsupportedOperationError(op, backend, ["GiacBackend", "SymbolicsBackend"]))
    end

    # --- Unknown operator ---
    throw(UnsupportedOperationError(op, backend, String[]))
end

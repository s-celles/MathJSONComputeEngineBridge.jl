# --- Constants table (T002) ---

const JULIA_CONSTANTS = Dict{String,Number}(
    "Pi" => Float64(π),
    "ExponentialE" => Float64(ℯ),
)

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
    if haskey(JULIA_CONSTANTS, expr.name)
        return NumberExpr(JULIA_CONSTANTS[expr.name])
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
        result = _isprime(Integer(evaluated.value))
        return SymbolExpr(result ? "True" : "False")
    end

    # --- Special-case Log (variable arity) ---
    if op == :Log
        if length(args) == 1
            evaluated = compute(backend, args[1])
            return NumberExpr(log(evaluated.value))
        elseif length(args) == 2
            eval_val = compute(backend, args[1])
            eval_base = compute(backend, args[2])
            # MathJSON: Log(value, base) → Julia: log(base, value)
            return NumberExpr(log(eval_base.value, eval_val.value))
        end
    end

    # --- Special functions (custom implementations) ---
    if op == :Sinc
        evaluated = compute(backend, args[1])
        return NumberExpr(_sinc(evaluated.value))
    end
    if op == :Haversine
        evaluated = compute(backend, args[1])
        return NumberExpr(_haversine(evaluated.value))
    end
    if op == :InverseHaversine
        evaluated = compute(backend, args[1])
        return NumberExpr(_inverse_haversine(evaluated.value))
    end

    # --- Variadic arithmetic ops ---
    if haskey(JULIA_OPS, op)
        evaluated = [compute(backend, arg) for arg in args]
        values = [e.value for e in evaluated]
        f = JULIA_OPS[op]
        result = if length(values) == 2
            f(values[1], values[2])
        else
            reduce(f, values)
        end
        return NumberExpr(result)
    end

    # --- Unary ops ---
    if haskey(JULIA_UNARY_OPS, op)
        evaluated = compute(backend, args[1])
        f = JULIA_UNARY_OPS[op]
        return NumberExpr(f(evaluated.value))
    end

    # --- Binary ops ---
    if haskey(JULIA_BINARY_OPS, op)
        eval1 = compute(backend, args[1])
        eval2 = compute(backend, args[2])
        f = JULIA_BINARY_OPS[op]
        return NumberExpr(f(eval1.value, eval2.value))
    end

    # --- Symbolic ops → UnsupportedOperationError ---
    if op in SYMBOLIC_OPS
        throw(UnsupportedOperationError(op, backend, ["GiacBackend", "SymbolicsBackend"]))
    end

    # --- Unknown operator ---
    throw(UnsupportedOperationError(op, backend, String[]))
end

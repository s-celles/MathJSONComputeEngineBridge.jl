# Operator mapping tables for GiacBackend
# Maps MathJSON operators to Giac equivalents

# Constants: MathJSON symbol name → Giac constant accessor
const GIAC_CONSTANTS = Dict{String,Symbol}(
    "Pi" => :pi,
    "ExponentialE" => :e,
    "ImaginaryUnit" => :i,
)

# Unary transcendental functions: MathJSON op → Julia/Giac Base function
# These work because Giac.jl extends Base.sin(::GiacExpr), etc.
const GIAC_UNARY_OPS = Dict{Symbol,Function}(
    :Sin => sin,
    :Cos => cos,
    :Tan => tan,
    :Exp => exp,
    :Ln => log,
    :Sqrt => sqrt,
    :Abs => abs,
    :Arcsin => asin,
    :Arccos => acos,
    :Arctan => atan,
    :Negate => -,
)

# Variadic/binary arithmetic operators: MathJSON op → GiacExpr operator
const GIAC_ARITHMETIC_OPS = Dict{Symbol,Function}(
    :Add => +,
    :Subtract => -,
    :Multiply => *,
    :Divide => /,
    :Power => ^,
)

# Commands: MathJSON op → (Giac command name, expected arg count or nothing for variable)
# These are called via invoke_cmd(:cmd, args...)
const GIAC_COMMANDS = Dict{Symbol,Symbol}(
    :Factor => :factor,
    :Expand => :expand,
    :Simplify => :simplify,
    :Solve => :solve,
    :PartialFractions => :partfrac,
    :GCD => :gcd,
    :LCM => :lcm,
    :D => :diff,
    :Integrate => :integrate,
    :Limit => :limit,
    :Sum => :sum,
    :Product => :product,
    :Laplace => :laplace,
    :InverseLaplace => :ilaplace,
    :ZTransform => :ztrans,
    :InverseZTransform => :invztrans,
    :IsPrime => :isprime,
    :Factorial => :factorial,
    :Mod => :irem,
    :Determinant => :det,
    :Transpose => :transpose,
    :Inverse => :inv,
    :IntegerFactorization => :ifactor,
    :ModPow => :powmod,
    :Series => :series,
    :Taylor => :taylor,
    :Desolve => :desolve,
)

# Reverse map from Giac function name to MathJSON operator (for conversion back)
const GIAC_FUNCNAME_TO_MATHJSON = Dict{String,Symbol}(
    "+" => :Add,
    "-" => :Subtract,
    "*" => :Multiply,
    "/" => :Divide,
    "^" => :Power,
    "pow" => :Power,
    "sin" => :Sin,
    "cos" => :Cos,
    "tan" => :Tan,
    "exp" => :Exp,
    "ln" => :Ln,
    "log" => :Ln,
    "sqrt" => :Sqrt,
    "abs" => :Abs,
    "asin" => :Arcsin,
    "acos" => :Arccos,
    "atan" => :Arctan,
    "neg" => :Negate,
    "factor" => :Factor,
    "expand" => :Expand,
    "simplify" => :Simplify,
    "solve" => :Solve,
    "partfrac" => :PartialFractions,
    "gcd" => :GCD,
    "lcm" => :LCM,
    "diff" => :D,
    "integrate" => :Integrate,
    "limit" => :Limit,
    "sum" => :Sum,
    "product" => :Product,
    "laplace" => :Laplace,
    "ilaplace" => :InverseLaplace,
    "ztrans" => :ZTransform,
    "invztrans" => :InverseZTransform,
    "isprime" => :IsPrime,
    "factorial" => :Factorial,
    "!" => :Factorial,
    "irem" => :Mod,
    "det" => :Determinant,
    "transpose" => :Transpose,
    "inv" => :Inverse,
    "ifactor" => :IntegerFactorization,
    "powmod" => :ModPow,
    "series" => :Series,
    "taylor" => :Taylor,
    "desolve" => :Desolve,
    "order_size" => :OrderSize,
    "sinh" => :Sinh,
    "cosh" => :Cosh,
    "tanh" => :Tanh,
    "asinh" => :Arsinh,
    "acosh" => :Arcosh,
    "atanh" => :Artanh,
)

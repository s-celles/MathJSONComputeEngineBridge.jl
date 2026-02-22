# Operator mapping tables for SymbolicsBackend
# Maps MathJSON operators to Symbolics/Julia equivalents

# Constants: MathJSON symbol name → Num-wrapped Julia constant
const SYMBOLICS_CONSTANTS = Dict{String,Irrational}(
    "Pi" => π,
    "ExponentialE" => ℯ,
)

# Unary transcendental functions: MathJSON op → Julia Base function
# These work because Symbolics extends Base.sin(::Num), etc.
const SYMBOLICS_UNARY_OPS = Dict{Symbol,Function}(
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
    :Sinh => sinh,
    :Cosh => cosh,
    :Tanh => tanh,
    :Log2 => log2,
    :Log10 => log10,
    :Negate => -,
)

# Variadic/binary arithmetic operators: MathJSON op → Julia operator
const SYMBOLICS_ARITHMETIC_OPS = Dict{Symbol,Function}(
    :Add => +,
    :Subtract => -,
    :Multiply => *,
    :Divide => /,
    :Power => ^,
)

# Reverse map: Julia function → MathJSON operator (for conversion back from Symbolics)
const SYMBOLICS_OP_TO_MATHJSON = Dict{Function,Symbol}(
    (+) => :Add,
    (-) => :Subtract,
    (*) => :Multiply,
    (/) => :Divide,
    (^) => :Power,
    sin => :Sin,
    cos => :Cos,
    tan => :Tan,
    exp => :Exp,
    log => :Ln,
    sqrt => :Sqrt,
    abs => :Abs,
    asin => :Arcsin,
    acos => :Arccos,
    atan => :Arctan,
    sinh => :Sinh,
    cosh => :Cosh,
    tanh => :Tanh,
    log2 => :Log2,
    log10 => :Log10,
)

# Operations that are NOT supported by SymbolicsBackend
# These raise UnsupportedOperationError with suggested backends
const UNSUPPORTED_OPS = Dict{Symbol,Vector{String}}(
    :Integrate => ["GiacBackend"],
    :Laplace => ["GiacBackend"],
    :InverseLaplace => ["GiacBackend"],
    :ZTransform => ["GiacBackend"],
    :InverseZTransform => ["GiacBackend"],
    :Factor => ["GiacBackend"],
    :PartialFractions => ["GiacBackend"],
    :Series => ["GiacBackend"],
    :Taylor => ["GiacBackend"],
    :Desolve => ["GiacBackend"],
    :Limit => ["GiacBackend"],
    :Sum => ["GiacBackend"],
    :Product => ["GiacBackend"],
    :IntegerFactorization => ["GiacBackend"],
    :ModPow => ["GiacBackend"],
)

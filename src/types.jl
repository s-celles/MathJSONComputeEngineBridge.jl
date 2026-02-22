"""
    AbstractComputeBackend

Abstract supertype for all compute backends.

Any concrete backend MUST implement `compute(::Backend, ::AbstractMathJSONExpr)`.
"""
abstract type AbstractComputeBackend end

"""
    JuliaBackend <: AbstractComputeBackend

Default backend for numeric evaluation using Julia's stdlib.

## Supported Operations

**Arithmetic**: Add, Subtract, Multiply, Divide, Negate

**Power & Root**: Power, Root, Sqrt, Square, Abs

**Trigonometric**: Sin, Cos, Tan, Cot, Sec, Csc

**Inverse Trigonometric**: Arcsin, Arccos, Arctan, Arccot, Arcsec, Arccsc

**Hyperbolic**: Sinh, Cosh, Tanh, Coth, Sech, Csch

**Inverse Hyperbolic** (ISO naming): Arsinh, Arcosh, Artanh, Arcoth, Arsech, Arcsch

**Exponential & Logarithmic**: Exp, Ln, Log (1 or 2 args), Log2, Log10

**Special Functions**: Sinc (unnormalized), Haversine, InverseHaversine, Hypot

**Number Theory**: Factorial, Binomial, GCD, LCM, Mod, IsPrime

**Matrix Operations**: Determinant, Transpose, Inverse (via LinearAlgebra)

**Combinatorics**: Fibonacci, Permutations (via Combinatorics.jl)

**Statistics**: Mean, Median, Variance, StandardDeviation (via Statistics stdlib)

**Constants**: Pi, ExponentialE, ImaginaryUnit

**Meta-operators**: InverseFunction (delegates to inverse of named function)

**Passthrough**: List, Matrix (recursive evaluation)
"""
struct JuliaBackend <: AbstractComputeBackend end

"""
    GiacBackend <: AbstractComputeBackend

Symbolic computation backend using Giac.jl.

Requires `using Giac` to activate. When Giac.jl is loaded, `GiacBackend`
becomes the default backend automatically.

## Supported Operations

**All JuliaBackend operations** plus:

**Algebra**: Factor, Expand, Simplify, Solve, PartialFractions, GCD, LCM

**Calculus**: D (differentiation), Integrate (definite/indefinite), Limit, Sum, Product

**Transforms**: Laplace, InverseLaplace, ZTransform, InverseZTransform

**Number Theory**: IsPrime, Factorial, Mod, IntegerFactorization, ModPow

**Series Expansion**: Series (Taylor/Laurent with point), Taylor (without point)

**Matrix**: Determinant, Transpose, Inverse (symbolic matrices)

**Fallback**: Any of ~2200 Giac commands via automatic lowercase dispatch
"""
struct GiacBackend <: AbstractComputeBackend end

"""
    SymbolicsBackend <: AbstractComputeBackend

Pure Julia symbolic computation backend using Symbolics.jl.

Requires `using Symbolics` to activate. When Symbolics.jl is loaded,
`SymbolicsBackend` becomes the default backend automatically.

## Supported Operations

**All JuliaBackend arithmetic and transcendental operations** plus:

**Algebra**: Expand, Simplify, Substitute

**Calculus**: D (differentiation)

**Equation Solving**: Solve (polynomial and linear)

**Matrix**: Determinant, Transpose, Inverse (symbolic matrices)

**Code Generation**: Build (compile symbolic expression to callable function)

## Not Supported (use GiacBackend)

Integrate, Factor, PartialFractions, Laplace, InverseLaplace,
ZTransform, InverseZTransform, Series, Taylor, Desolve,
Limit, Sum, Product, IntegerFactorization, ModPow
"""
struct SymbolicsBackend <: AbstractComputeBackend end

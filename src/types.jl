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

**Constants**: Pi, ExponentialE

**Meta-operators**: InverseFunction (delegates to inverse of named function)

**Passthrough**: List, Matrix (recursive evaluation)
"""
struct JuliaBackend <: AbstractComputeBackend end

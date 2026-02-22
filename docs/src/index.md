# MathJSONComputeEngineBridge.jl

Evaluate MathJSON expressions via pluggable compute backends.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/s-celles/MathJSONComputeEngineBridge.jl")
```

## Quick Start

```julia
using MathJSON
using MathJSONComputeEngineBridge

# Parse a MathJSON expression
expr = MathJSON.parse(MathJSONFormat, """["Add", 1, ["Multiply", 2, 3]]""")

# Evaluate (uses JuliaBackend by default)
result = evaluate(expr)
# Returns NumberExpr(7)
```

## Supported Operations

### Arithmetic

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Add`             | `+`           | Addition (variadic) |
| `Subtract`        | `-`           | Subtraction (variadic) |
| `Multiply`        | `*`           | Multiplication (variadic) |
| `Divide`          | `/`           | Division (variadic) |
| `Negate`          | `-`           | Unary negation |

### Power, Root & Absolute Value

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Power`           | `^`           | Exponentiation |
| `Root`            | `x^(1/n)`     | nth root |
| `Sqrt`            | `sqrt`        | Square root |
| `Square`          | `x^2`         | Square |
| `Abs`             | `abs`         | Absolute value |

### Trigonometric Functions

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Sin`             | `sin`         | Sine |
| `Cos`             | `cos`         | Cosine |
| `Tan`             | `tan`         | Tangent |
| `Cot`             | `cot`         | Cotangent |
| `Sec`             | `sec`         | Secant |
| `Csc`             | `csc`         | Cosecant |

### Inverse Trigonometric Functions

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Arcsin`          | `asin`        | Inverse sine |
| `Arccos`          | `acos`        | Inverse cosine |
| `Arctan`          | `atan`        | Inverse tangent |
| `Arccot`          | `acot`        | Inverse cotangent |
| `Arcsec`          | `asec`        | Inverse secant |
| `Arccsc`          | `acsc`        | Inverse cosecant |

### Hyperbolic Functions

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Sinh`            | `sinh`        | Hyperbolic sine |
| `Cosh`            | `cosh`        | Hyperbolic cosine |
| `Tanh`            | `tanh`        | Hyperbolic tangent |
| `Coth`            | `coth`        | Hyperbolic cotangent |
| `Sech`            | `sech`        | Hyperbolic secant |
| `Csch`            | `csch`        | Hyperbolic cosecant |

### Inverse Hyperbolic Functions (ISO naming)

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Arsinh`          | `asinh`       | Inverse hyperbolic sine |
| `Arcosh`          | `acosh`       | Inverse hyperbolic cosine |
| `Artanh`          | `atanh`       | Inverse hyperbolic tangent |
| `Arcoth`          | `acoth`       | Inverse hyperbolic cotangent |
| `Arsech`          | `asech`       | Inverse hyperbolic secant |
| `Arcsch`          | `acsch`       | Inverse hyperbolic cosecant |

### Exponential & Logarithmic Functions

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Exp`             | `exp`         | Exponential |
| `Ln`              | `log`         | Natural logarithm |
| `Log` (1 arg)     | `log`         | Natural logarithm |
| `Log` (2 args)    | `log(base, x)`| Logarithm with base: `Log(value, base)` |
| `Log2`            | `log2`        | Base-2 logarithm |
| `Log10`           | `log10`       | Base-10 logarithm |

### Special Functions

| MathJSON Operator    | Julia Function | Description |
|----------------------|---------------|-------------|
| `Sinc`               | `sin(x)/x`   | Unnormalized sinc function |
| `Haversine`          | `sin(θ/2)^2` | Haversine function |
| `InverseHaversine`   | `2asin(√y)`  | Inverse haversine |
| `Hypot`              | `hypot`       | Hypotenuse (Euclidean norm of two values) |

### Number Theory

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Factorial`       | `factorial`   | Factorial |
| `Binomial`        | `binomial`    | Binomial coefficient |
| `GCD`             | `gcd`         | Greatest common divisor |
| `LCM`             | `lcm`         | Least common multiple |
| `Mod`             | `mod`         | Modulo operation |
| `IsPrime`         | custom        | Returns `SymbolExpr("True")` or `SymbolExpr("False")` |

### Matrix Operations

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Determinant`     | `det`         | Matrix determinant |
| `Transpose`       | `transpose`   | Matrix transpose |
| `Inverse`         | `inv`         | Matrix inverse |
| `List`            | passthrough   | Recursive evaluation of elements |
| `Matrix`          | passthrough   | Recursive evaluation of row lists |

Matrices are represented as `FunctionExpr(:Matrix, [FunctionExpr(:List, [NumberExpr...]), ...])`.

### Mathematical Constants

| MathJSON Symbol   | Julia Value | Description |
|-------------------|-------------|-------------|
| `Pi`              | `π`         | Pi (3.14159...) |
| `ExponentialE`    | `ℯ`         | Euler's number (2.71828...) |

### InverseFunction Meta-Operator

The `InverseFunction` operator delegates to the inverse of a named function:

```julia
# InverseFunction("Sin", x) is equivalent to Arcsin(x)
expr = FunctionExpr(:InverseFunction, [SymbolExpr("Sin"), NumberExpr(0.5)])
evaluate(expr)  # Same as evaluate(FunctionExpr(:Arcsin, [NumberExpr(0.5)]))
```

Supported inverse mappings: Sin, Cos, Tan, Cot, Sec, Csc, Sinh, Cosh, Tanh, Coth, Sech, Csch, Exp.

## GiacBackend (Symbolic Computation)

When Giac.jl is loaded, `GiacBackend` becomes available for symbolic computation. It automatically becomes the default backend.

### Installation

```julia
using Pkg
Pkg.add(url="https://github.com/s-celles/Giac.jl")
```

### Activation

```julia
using MathJSON
using MathJSONComputeEngineBridge
using Giac  # Activates GiacBackend automatically

# GiacBackend is now the default
result = evaluate(FunctionExpr(:Factor, [
    FunctionExpr(:Subtract, [
        FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
        NumberExpr(1)
    ])
]))
# Returns factored form: (x-1)(x+1)
```

### Symbolic Algebra

| MathJSON Operator    | Giac Command   | Description |
|----------------------|---------------|-------------|
| `Factor`             | `factor`      | Factor polynomials |
| `Expand`             | `expand`      | Expand expressions |
| `Simplify`           | `simplify`    | Simplify expressions |
| `Solve`              | `solve`       | Solve equations |
| `PartialFractions`   | `partfrac`    | Partial fraction decomposition |
| `GCD`                | `gcd`         | GCD of polynomials |
| `LCM`                | `lcm`         | LCM of polynomials |

### Calculus

| MathJSON Operator | Giac Command   | Description |
|-------------------|---------------|-------------|
| `D`               | `diff`        | Differentiation |
| `Integrate`       | `integrate`   | Integration (2 args = indefinite, 4 args = definite) |
| `Limit`           | `limit`       | Limits |
| `Sum`             | `sum`         | Symbolic summation |
| `Product`          | `product`     | Symbolic product |

### Transforms

| MathJSON Operator    | Giac Command   | Description |
|----------------------|---------------|-------------|
| `Laplace`            | `laplace`     | Laplace transform |
| `InverseLaplace`     | `ilaplace`    | Inverse Laplace transform |
| `ZTransform`         | `ztrans`      | Z-transform |
| `InverseZTransform`  | `invztrans`   | Inverse Z-transform |

### Number Theory (GiacBackend)

| MathJSON Operator         | Giac Command   | Description |
|---------------------------|---------------|-------------|
| `IsPrime`                 | `isprime`     | Primality test |
| `Factorial`               | `factorial`   | Factorial |
| `IntegerFactorization`    | `ifactor`     | Integer factorization |
| `ModPow`                  | `powmod`      | Modular exponentiation |

### Series Expansion

| MathJSON Operator | Giac Command   | Description |
|-------------------|---------------|-------------|
| `Series`          | `series`      | Series expansion (4 args: expr, var, point, order) |
| `Taylor`          | `taylor`      | Taylor expansion (3 args: expr, var, order) |

### Symbolic Matrix Operations

GiacBackend supports `Determinant`, `Transpose`, and `Inverse` on symbolic matrices (matrices containing variables).

### Fallback Mechanism

Any MathJSON operator not explicitly mapped is automatically forwarded to Giac by lowercasing the operator name and calling `invoke_cmd`. This provides access to all ~2200 Giac commands.

```julia
# Example: polynomial quotient (not explicitly mapped)
expr = FunctionExpr(:Quo, [poly1, poly2, SymbolExpr("x")])
evaluate(expr; backend=GiacBackend())
```

## Backend Selection

```julia
# Use the default backend
result = evaluate(expr)

# Explicitly specify a backend
result = evaluate(expr; backend=JuliaBackend())
result = evaluate(expr; backend=GiacBackend())

# Change the default backend
set_default_backend!(JuliaBackend())
set_default_backend!(GiacBackend())
```

## API Reference

```@autodocs
Modules = [MathJSONComputeEngineBridge]
```

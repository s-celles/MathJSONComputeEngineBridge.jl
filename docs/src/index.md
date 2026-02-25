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

### Combinatorics

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Fibonacci`       | `Combinatorics.fibonaccinum` | Fibonacci number F(n) for n ≥ 0 |
| `Permutations`    | `P(n, k)`     | Permutation count n!/(n-k)!, returns 0 when k > n |

### Statistics

| MathJSON Operator      | Julia Function | Description |
|------------------------|---------------|-------------|
| `Mean`                 | `Statistics.mean` | Arithmetic mean of a List |
| `Median`               | `Statistics.median` | Median of a List |
| `Variance`             | `Statistics.var(; corrected=false)` | Population variance of a List |
| `StandardDeviation`    | `Statistics.std(; corrected=false)` | Population standard deviation of a List |

### Mathematical Constants

| MathJSON Symbol   | Julia Value | Description |
|-------------------|-------------|-------------|
| `Pi`              | `π`         | Pi (3.14159...) |
| `ExponentialE`    | `ℯ`         | Euler's number (2.71828...) |
| `ImaginaryUnit`   | `im`        | Imaginary unit (√-1) |

### Structural Operators (PlutoMathInput Compatibility)

| MathJSON Operator | Behavior | Description |
|-------------------|----------|-------------|
| `Block`           | passthrough | Evaluates all children, returns last result |
| `Nothing`         | sentinel    | Passes through unchanged (placeholder for absent values) |
| `Function`        | structural  | Binds a variable to an expression body (used with calculus ops) |
| `Limits`          | structural  | Specifies variable with optional bounds (used with calculus ops) |

These operators are produced by [PlutoMathInput](https://github.com/s-celles/PlutoMathInput.jl) during MathJSON canonicalization. For example, `Integrate(Tan(x), x)` is canonicalized as:

```julia
FunctionExpr(:Integrate, [
    FunctionExpr(:Function, [
        FunctionExpr(:Block, [FunctionExpr(:Tan, [SymbolExpr("x")])]),
        SymbolExpr("x")
    ]),
    FunctionExpr(:Limits, [
        SymbolExpr("x"),
        SymbolExpr("Nothing"),  # No lower bound (indefinite)
        SymbolExpr("Nothing")   # No upper bound (indefinite)
    ])
])
```

GiacBackend automatically normalizes this to the direct form before evaluation.

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

## SymbolicsBackend (Pure Julia Symbolic Computation)

When Symbolics.jl is loaded, `SymbolicsBackend` becomes available for symbolic computation. It provides a pure Julia alternative to GiacBackend for common symbolic operations.

### Activation

```julia
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics  # Activates SymbolicsBackend automatically

# SymbolicsBackend is now the default
result = evaluate(FunctionExpr(:Expand, [
    FunctionExpr(:Power, [
        FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
        NumberExpr(2)
    ])
]))
# Returns x^2 + 2x + 1
```

### Symbolic Algebra

| MathJSON Operator | Symbolics.jl Function | Description |
|-------------------|-----------------------|-------------|
| `Expand`          | `expand`              | Expand expressions |
| `Simplify`        | `simplify`            | Simplify expressions |
| `Substitute`      | `substitute`          | Variable substitution |

### Calculus (SymbolicsBackend)

| MathJSON Operator | Symbolics.jl Function | Description |
|-------------------|-----------------------|-------------|
| `D`               | `derivative`          | Differentiation |

### Equation Solving (SymbolicsBackend)

| MathJSON Operator | Symbolics.jl Function | Description |
|-------------------|-----------------------|-------------|
| `Solve`           | `symbolic_solve` / `solve_for` | Solve equations (polynomial and linear) |

### Symbolic Matrix Operations (SymbolicsBackend)

| MathJSON Operator | Julia Function | Description |
|-------------------|---------------|-------------|
| `Determinant`     | `det`         | Matrix determinant (symbolic) |
| `Transpose`       | `transpose`   | Matrix transpose (symbolic) |
| `Inverse`         | `inv`         | Matrix inverse (symbolic) |

### Code Generation

| MathJSON Operator | Symbolics.jl Function | Description |
|-------------------|-----------------------|-------------|
| `Build`           | `build_function`      | Compile symbolic expression to callable function |

```julia
# Generate a compiled function from a symbolic expression
expr = FunctionExpr(:Build, [
    FunctionExpr(:Add, [
        FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
        FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("x")]),
        NumberExpr(1)
    ]),
    SymbolExpr("x")
])
result = evaluate(expr; backend=SymbolicsBackend())
# Returns FunctionExpr(:CompiledFunction, [StringExpr("1 + 2x + x^2")])
```

### Unsupported Operations (use GiacBackend)

The following operations are not supported by SymbolicsBackend and will raise `UnsupportedOperationError` suggesting `GiacBackend` as an alternative:

`Integrate`, `Factor`, `PartialFractions`, `Laplace`, `InverseLaplace`, `ZTransform`, `InverseZTransform`, `Series`, `Taylor`, `Desolve`, `Limit`, `Sum`, `Product`, `IntegerFactorization`, `ModPow`

### Backend Comparison

| Feature | JuliaBackend | SymbolicsBackend | GiacBackend |
|---------|-------------|-----------------|-------------|
| Numeric evaluation | Yes | Yes | Yes |
| ImaginaryUnit | Yes | Yes | Yes |
| Block / Nothing (structural) | Yes | Yes | Yes |
| Function / Limits (PlutoMathInput) | No | No | Yes |
| Combinatorics (Fibonacci, Permutations) | Yes | No | No |
| Statistics (Mean, Median, Variance, StdDev) | Yes | No | No |
| Symbolic variables | No | Yes | Yes |
| Expand / Simplify | No | Yes | Yes |
| Substitute | No | Yes | Yes |
| Differentiation | No | Yes | Yes |
| Integration | No | No | Yes |
| Equation solving | No | Yes (linear/poly) | Yes (general) |
| Factorization | No | No | Yes |
| Laplace/Z-transforms | No | No | Yes |
| Series expansion | No | No | Yes |
| Symbolic matrices | No | Yes | Yes |
| Code generation | No | Yes | No |
| Pure Julia | Yes | Yes | No (requires libgiac) |
| Dependencies | Statistics, Combinatorics.jl | Symbolics.jl | Giac.jl |

## Convenience Methods

String-accepting overloads let you skip the explicit `parse` step:

```julia
using MathJSON
using MathJSONComputeEngineBridge

# Evaluate directly from a MathJSON string
result = evaluate("""["Add", 1, ["Multiply", 2, 3]]""")
# Returns NumberExpr(7)
```

### `evaluate(s::String; backend=default_backend())`

Parses the MathJSON string and evaluates it in one call.

### `to_giac(expr)` / `to_giac(s::String)`

Convert a MathJSON expression (or string) to a Giac expression. Requires `using Giac`.

```julia
using Giac
g = to_giac("""["Add", "x", 1]""")  # Returns a GiacExpr
```

### `to_symbolics(expr)` (from MathJSON.jl)

`to_symbolics` is provided by MathJSON.jl directly. Load Symbolics.jl to activate it:

```julia
using Symbolics
sym = to_symbolics(FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]))
```

## Backend Selection

```julia
# Use the default backend
result = evaluate(expr)

# Explicitly specify a backend
result = evaluate(expr; backend=JuliaBackend())
result = evaluate(expr; backend=SymbolicsBackend())
result = evaluate(expr; backend=GiacBackend())

# Change the default backend
set_default_backend!(JuliaBackend())
set_default_backend!(SymbolicsBackend())
set_default_backend!(GiacBackend())
```

## API Reference

```@autodocs
Modules = [MathJSONComputeEngineBridge]
```

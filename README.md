# MathJSONComputeEngineBridge.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Julia package that evaluates [MathJSON](https://cortexjs.io/math-json/) expressions through pluggable computational backends. It bridges the gap between the standardized MathJSON representation and numeric/symbolic computation in Julia.

## Features

- **Pluggable backends** — switch between numeric and symbolic computation seamlessly
- **60+ supported operations** — arithmetic, trigonometry, calculus, linear algebra, statistics, and more
- **Weak dependencies** — symbolic backends load only when you need them
- **String convenience API** — evaluate MathJSON directly from JSON strings
- **PlutoMathInput integration** — handles `Block`, `Function`, `Limits` structures for interactive notebooks

## Installation

```julia
using Pkg
Pkg.add("MathJSONComputeEngineBridge")
```

For symbolic computation, also install the optional backend(s):

```julia
Pkg.add("Giac")       # GiacBackend — full symbolic (CAS)
Pkg.add("Symbolics")  # SymbolicsBackend — pure Julia symbolic
```

## Quick Start

```julia
using MathJSON, MathJSONComputeEngineBridge

# Numeric evaluation
expr = FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)])
evaluate(expr)  # NumberExpr(3)

# From a JSON string
evaluate("""["Add", 1, 2]""")  # NumberExpr(3)

# Nested expressions
expr = FunctionExpr(:Sqrt, [
    FunctionExpr(:Add, [NumberExpr(9), NumberExpr(16)])
])
evaluate(expr)  # NumberExpr(5.0)
```

### Symbolic computation with Giac

```julia
using Giac  # activates GiacBackend
set_default_backend!(GiacBackend())

# Factor x² - 1
expr = FunctionExpr(:Factor, [
    FunctionExpr(:Subtract, [
        FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
        NumberExpr(1)
    ])
])
evaluate(expr)  # (x-1)(x+1)
```

### Symbolic computation with Symbolics.jl

```julia
using Symbolics  # activates SymbolicsBackend
set_default_backend!(SymbolicsBackend())

# Expand (x + 1)²
expr = FunctionExpr(:Expand, [
    FunctionExpr(:Power, [
        FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
        NumberExpr(2)
    ])
])
evaluate(expr)  # x² + 2x + 1
```

## Backends

| Feature | JuliaBackend | SymbolicsBackend | GiacBackend |
|---|:---:|:---:|:---:|
| Numeric evaluation | Yes | Yes | Yes |
| Complex numbers | Yes | Yes | Yes |
| Combinatorics / Statistics | Yes | — | — |
| Symbolic variables | — | Yes | Yes |
| Expand / Simplify | — | Yes | Yes |
| Differentiation | — | Yes | Yes |
| Integration | — | — | Yes |
| Factorisation | — | — | Yes |
| Laplace / Z-transforms | — | — | Yes |
| Series expansion | — | — | Yes |
| Code generation | — | Yes | — |
| Pure Julia | Yes | Yes | — |

**JuliaBackend** (default) — fast numeric evaluation with no extra dependencies.

**SymbolicsBackend** — pure Julia symbolic via [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl). Supports expand, simplify, differentiation, solving, and code generation.

**GiacBackend** — full CAS powered by [Giac.jl](https://github.com/s-celles/Giac.jl). Supports integration, factorisation, Laplace/Z-transforms, series expansion, ODEs, and ~2200 Giac commands via automatic fallback.

## API

```julia
evaluate(expr; backend=default_backend())   # evaluate a MathJSON expression
evaluate(s::String; backend=default_backend())  # parse JSON string and evaluate
compute(backend, expr)                      # low-level dispatch

default_backend()           # get current default backend
set_default_backend!(b)     # set default backend
```

### Exported types

- `AbstractComputeBackend`, `JuliaBackend`, `GiacBackend`, `SymbolicsBackend`
- `UnsupportedOperationError`, `UnresolvedSymbolError`

## Supported Operations

<details>
<summary><strong>Arithmetic</strong></summary>

`Add`, `Subtract`, `Multiply`, `Divide`, `Negate`, `Abs`

</details>

<details>
<summary><strong>Power & Roots</strong></summary>

`Power`, `Root`, `Sqrt`, `Square`

</details>

<details>
<summary><strong>Trigonometry</strong></summary>

`Sin`, `Cos`, `Tan`, `Cot`, `Sec`, `Csc`
`Arcsin`, `Arccos`, `Arctan`, `Arccot`, `Arcsec`, `Arccsc`

</details>

<details>
<summary><strong>Hyperbolic</strong></summary>

`Sinh`, `Cosh`, `Tanh`, `Coth`, `Sech`, `Csch`
`Arsinh`, `Arcosh`, `Artanh`, `Arcoth`, `Arsech`, `Arcsch`

</details>

<details>
<summary><strong>Exponential & Logarithmic</strong></summary>

`Exp`, `Ln`, `Log`, `Log2`, `Log10`

</details>

<details>
<summary><strong>Special Functions</strong></summary>

`Sinc`, `Haversine`, `InverseHaversine`, `Hypot`, `InverseFunction`

</details>

<details>
<summary><strong>Number Theory</strong></summary>

`Factorial`, `Binomial`, `GCD`, `LCM`, `Mod`, `IsPrime`

</details>

<details>
<summary><strong>Combinatorics & Statistics</strong></summary>

`Fibonacci`, `Permutations`, `Mean`, `Median`, `Variance`, `StandardDeviation`

</details>

<details>
<summary><strong>Linear Algebra</strong></summary>

`Determinant`, `Transpose`, `Inverse`, `List`, `Matrix`

</details>

<details>
<summary><strong>Calculus</strong> (symbolic backends)</summary>

`D`, `Integrate`, `Limit`, `Sum`, `Product`, `Series`, `Taylor`

</details>

<details>
<summary><strong>Algebra</strong> (symbolic backends)</summary>

`Factor`, `Expand`, `Simplify`, `Solve`, `PartialFractions`, `Substitute`

</details>

<details>
<summary><strong>Integral Transforms</strong> (GiacBackend)</summary>

`Laplace`, `InverseLaplace`, `ZTransform`, `InverseZTransform`

</details>

<details>
<summary><strong>Constants</strong></summary>

`Pi`, `ExponentialE`, `ImaginaryUnit`

</details>

## Project Structure

```
MathJSONComputeEngineBridge.jl/
├── src/
│   ├── MathJSONComputeEngineBridge.jl   # main module
│   ├── types.jl                         # backend type hierarchy
│   ├── errors.jl                        # error types
│   ├── evaluate.jl                      # core evaluation API
│   └── backends/
│       └── julia_backend.jl             # JuliaBackend
├── ext/
│   ├── GiacBackendExt/                  # Giac.jl extension
│   └── SymbolicsBackendExt/             # Symbolics.jl extension
├── test/                                # 33 test files
├── docs/                                # Documenter.jl documentation
└── notebooks/                           # Pluto.jl examples
```

## Development

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

To run tests with optional backends:

```julia
using Pkg
Pkg.test("MathJSONComputeEngineBridge"; test_args=["giac", "symbolics"])
```

## License

MIT — see [LICENSE](LICENSE) for details.

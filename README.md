# MathJSONComputeEngineBridge.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://s-celles.github.io/MathJSONComputeEngineBridge.jl/stable/)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://s-celles.github.io/MathJSONComputeEngineBridge.jl/dev/)

A Julia package that evaluates [MathJSON](https://cortexjs.io/math-json/) expressions through pluggable computational backends (numeric, symbolic via Symbolics.jl, full CAS via Giac.jl).

## Installation

```julia
using Pkg
Pkg.add("MathJSONComputeEngineBridge")
```

## Quick Start

```julia
using MathJSON, MathJSONComputeEngineBridge

evaluate("""["Add", 1, ["Multiply", 2, 3]]""")  # NumberExpr(7)
```

## Documentation

Full documentation — including backend comparison, supported operations, and API reference — is available at:

**[https://s-celles.github.io/MathJSONComputeEngineBridge.jl/](https://s-celles.github.io/MathJSONComputeEngineBridge.jl/)**

## License

MIT — see [LICENSE](LICENSE) for details.

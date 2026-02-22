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

| MathJSON Operator | Description |
|-------------------|-------------|
| `Add`             | Addition |
| `Subtract`        | Subtraction |
| `Multiply`        | Multiplication |
| `Divide`          | Division |
| `Negate`          | Unary negation |

## Backend Selection

```julia
# Use the default backend
result = evaluate(expr)

# Explicitly specify a backend
result = evaluate(expr; backend=JuliaBackend())

# Change the default backend
set_default_backend!(JuliaBackend())
```

## API Reference

```@autodocs
Modules = [MathJSONComputeEngineBridge]
```

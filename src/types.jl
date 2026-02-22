"""
    AbstractComputeBackend

Abstract supertype for all compute backends.

Any concrete backend MUST implement `compute(::Backend, ::AbstractMathJSONExpr)`.
"""
abstract type AbstractComputeBackend end

"""
    JuliaBackend <: AbstractComputeBackend

Default backend for numeric evaluation using Julia's stdlib.
Supports basic arithmetic: Add, Subtract, Multiply, Divide, Negate.
"""
struct JuliaBackend <: AbstractComputeBackend end

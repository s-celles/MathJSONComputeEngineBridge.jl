const _default_backend = Ref{AbstractComputeBackend}(JuliaBackend())
const _explicit_default = Ref{Bool}(false)

"""
    default_backend() -> AbstractComputeBackend

Return the currently active default backend.
Returns `JuliaBackend()` when no optional backends are loaded
and `set_default_backend!` has not been called.
"""
default_backend() = _default_backend[]

"""
    set_default_backend!(b::AbstractComputeBackend) -> AbstractComputeBackend

Set `b` as the default backend for subsequent `evaluate` calls.
Returns `b`.
"""
function set_default_backend!(b::AbstractComputeBackend)
    _default_backend[] = b
    _explicit_default[] = true
    return b
end

"""
    compute(backend::AbstractComputeBackend, expr::AbstractMathJSONExpr) -> AbstractMathJSONExpr

Internal method that backends MUST implement.
Dispatches evaluation of `expr` to the specific `backend`.

This fallback raises an error for unimplemented backends.
"""
function compute(backend::AbstractComputeBackend, expr::AbstractMathJSONExpr)
    error("compute not implemented for $(nameof(typeof(backend)))")
end

"""
    evaluate(expr::AbstractMathJSONExpr; backend=default_backend()) -> AbstractMathJSONExpr

Evaluate a MathJSON expression using the specified backend.

# Arguments
- `expr`: a MathJSON expression (any `AbstractMathJSONExpr` subtype)
- `backend`: an `AbstractComputeBackend` instance (default: `default_backend()`)

# Returns
The evaluation result as an `AbstractMathJSONExpr`.

# Errors
- `UnsupportedOperationError` if the operator is not supported
- `UnresolvedSymbolError` if symbolic variables are present
"""
function evaluate(expr::AbstractMathJSONExpr; backend::AbstractComputeBackend=default_backend())
    return compute(backend, expr)
end

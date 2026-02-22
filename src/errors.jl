"""
    UnsupportedOperationError <: Exception

Raised when an operation is not supported by the current backend.

# Fields
- `operation::Symbol`: the unsupported operator name
- `backend::AbstractComputeBackend`: the backend that was used
- `suggested_backends::Vector{String}`: backends that support this operation
"""
struct UnsupportedOperationError <: Exception
    operation::Symbol
    backend::AbstractComputeBackend
    suggested_backends::Vector{String}
end

function Base.showerror(io::IO, e::UnsupportedOperationError)
    print(io, "UnsupportedOperationError: Operation '", e.operation,
          "' is not supported by ", nameof(typeof(e.backend)), ".")
    if !isempty(e.suggested_backends)
        print(io, "\nSupported by: ", join(e.suggested_backends, ", "))
    end
end

"""
    UnresolvedSymbolError <: Exception

Raised when symbolic variables are encountered during numeric evaluation.

# Fields
- `symbols::Vector{String}`: names of unresolved symbols
"""
struct UnresolvedSymbolError <: Exception
    symbols::Vector{String}
end

function Base.showerror(io::IO, e::UnresolvedSymbolError)
    print(io, "UnresolvedSymbolError: Unresolved symbols in numeric evaluation: ",
          join(e.symbols, ", "))
    print(io, "\nUse a symbolic backend (GiacBackend, SymbolicsBackend) or ",
          "substitute values before evaluating.")
end

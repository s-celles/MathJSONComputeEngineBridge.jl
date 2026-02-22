module MathJSONComputeEngineBridge

using MathJSON
using LinearAlgebra

include("types.jl")
include("errors.jl")
include("evaluate.jl")
include("backends/julia_backend.jl")

export AbstractComputeBackend, JuliaBackend
export evaluate, default_backend, set_default_backend!, compute
export UnsupportedOperationError, UnresolvedSymbolError

end

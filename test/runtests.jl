using MathJSONComputeEngineBridge
using Aqua
using Test

@testset "MathJSONComputeEngineBridge" begin
    @testset "Aqua quality checks" begin
        Aqua.test_all(MathJSONComputeEngineBridge; deps_compat=(check_extras=false,))
    end
    include("test_julia_backend.jl")
    include("test_evaluate.jl")
    include("test_errors.jl")
end

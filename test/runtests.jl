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
    include("test_power_root.jl")
    include("test_trig.jl")
    include("test_hyperbolic.jl")
    include("test_exp_log.jl")
    include("test_constants.jl")
    include("test_special.jl")
    include("test_number_theory.jl")
    include("test_matrix.jl")
end

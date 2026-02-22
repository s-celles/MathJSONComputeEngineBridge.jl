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

    # GiacBackend tests (require Giac.jl)
    _giac_available = try
        using Giac
        true
    catch
        false
    end
    if _giac_available
        include("test_giac_activation.jl")
        include("test_giac_algebra.jl")
        include("test_giac_calculus.jl")
        include("test_giac_conversion.jl")
        include("test_giac_transforms.jl")
        include("test_giac_matrix.jl")
        include("test_giac_number_theory.jl")
        include("test_giac_ode_series.jl")
        include("test_giac_fallback.jl")
    end

    # SymbolicsBackend tests (require Symbolics.jl)
    _symbolics_available = try
        using Symbolics
        true
    catch
        false
    end
    if _symbolics_available
        include("test_symbolics_activation.jl")
        include("test_symbolics_algebra.jl")
        include("test_symbolics_calculus.jl")
        include("test_symbolics_conversion.jl")
        include("test_symbolics_matrix.jl")
        include("test_symbolics_solve.jl")
        include("test_symbolics_codegen.jl")
    end
end

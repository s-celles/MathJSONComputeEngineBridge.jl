using Giac

@testset "GiacBackend Activation (US1)" begin
    @testset "GiacBackend type is available" begin
        @test GiacBackend <: AbstractComputeBackend
        @test GiacBackend() isa AbstractComputeBackend
    end

    @testset "GiacBackend becomes default when explicitly set" begin
        set_default_backend!(GiacBackend())
        @test default_backend() isa GiacBackend
    end

    @testset "set_default_backend! overrides" begin
        # Save current default
        original = default_backend()

        # Switch to JuliaBackend
        set_default_backend!(JuliaBackend())
        @test default_backend() isa JuliaBackend

        # Restore GiacBackend
        set_default_backend!(GiacBackend())
        @test default_backend() isa GiacBackend
    end

    @testset "Simple numeric evaluation through GiacBackend" begin
        # NumberExpr passthrough
        result = evaluate(NumberExpr(42); backend=GiacBackend())
        @test result isa NumberExpr
        @test result.value == 42

        # Float
        result = evaluate(NumberExpr(3.14); backend=GiacBackend())
        @test result isa NumberExpr
        @test result.value ≈ 3.14

        # Negative
        result = evaluate(NumberExpr(-7); backend=GiacBackend())
        @test result isa NumberExpr
        @test result.value == -7
    end

    @testset "Constants through GiacBackend" begin
        # Pi preserved
        result = evaluate(SymbolExpr("Pi"); backend=GiacBackend())
        @test result isa SymbolExpr
        @test result.name == "Pi"

        # ExponentialE preserved
        result = evaluate(SymbolExpr("ExponentialE"); backend=GiacBackend())
        @test result isa SymbolExpr
        @test result.name == "ExponentialE"

        # ImaginaryUnit preserved
        result = evaluate(SymbolExpr("ImaginaryUnit"); backend=GiacBackend())
        @test result isa SymbolExpr
        @test result.name == "ImaginaryUnit"
    end

    @testset "Symbolic variable preserved" begin
        result = evaluate(SymbolExpr("x"); backend=GiacBackend())
        @test result isa SymbolExpr
        @test result.name == "x"
    end

    @testset "Basic arithmetic through GiacBackend" begin
        # Add(2, 3) = 5
        expr = FunctionExpr(:Add, [NumberExpr(2), NumberExpr(3)])
        result = evaluate(expr; backend=GiacBackend())
        @test result isa NumberExpr
        @test result.value == 5

        # Multiply(4, 5) = 20
        expr = FunctionExpr(:Multiply, [NumberExpr(4), NumberExpr(5)])
        result = evaluate(expr; backend=GiacBackend())
        @test result isa NumberExpr
        @test result.value == 20
    end

    @testset "Explicit backend selection" begin
        expr = FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)])

        # JuliaBackend still works
        result_julia = evaluate(expr; backend=JuliaBackend())
        @test result_julia isa NumberExpr
        @test result_julia.value == 3

        # GiacBackend works
        result_giac = evaluate(expr; backend=GiacBackend())
        @test result_giac isa NumberExpr
        @test result_giac.value == 3
    end
end

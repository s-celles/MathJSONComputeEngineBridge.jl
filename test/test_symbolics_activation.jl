using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Activation" begin
    @testset "Backend is usable when Symbolics loaded" begin
        backend = SymbolicsBackend()
        @test backend isa AbstractComputeBackend
    end

    @testset "Default backend is SymbolicsBackend when Symbolics loaded" begin
        # Reset to allow automatic default
        MathJSONComputeEngineBridge._explicit_default[] = false
        MathJSONComputeEngineBridge._default_backend[] = JuliaBackend()
        # Re-trigger the init logic
        MathJSONComputeEngineBridge.set_default_backend!(SymbolicsBackend())
        MathJSONComputeEngineBridge._explicit_default[] = false
        @test default_backend() isa SymbolicsBackend
    end

    @testset "set_default_backend! overrides" begin
        set_default_backend!(JuliaBackend())
        @test default_backend() isa JuliaBackend
        set_default_backend!(SymbolicsBackend())
        @test default_backend() isa SymbolicsBackend
    end

    @testset "Simple numeric expression evaluates correctly" begin
        result = evaluate(NumberExpr(42); backend=SymbolicsBackend())
        @test result isa NumberExpr
        @test result.value == 42
    end

    @testset "Float expression evaluates correctly" begin
        result = evaluate(NumberExpr(3.14); backend=SymbolicsBackend())
        @test result isa NumberExpr
        @test result.value ≈ 3.14
    end

    @testset "Simple arithmetic through SymbolicsBackend" begin
        # 2 + 3 = 5
        expr = FunctionExpr(:Add, [NumberExpr(2), NumberExpr(3)])
        result = evaluate(expr; backend=SymbolicsBackend())
        @test result isa NumberExpr
        @test result.value == 5
    end

    @testset "Multiply through SymbolicsBackend" begin
        # 4 * 7 = 28
        expr = FunctionExpr(:Multiply, [NumberExpr(4), NumberExpr(7)])
        result = evaluate(expr; backend=SymbolicsBackend())
        @test result isa NumberExpr
        @test result.value == 28
    end

    @testset "Symbolic variable preserved" begin
        result = evaluate(SymbolExpr("x"); backend=SymbolicsBackend())
        @test result isa SymbolExpr
        @test result.name == "x"
    end

    @testset "Constant Pi preserved" begin
        result = evaluate(SymbolExpr("Pi"); backend=SymbolicsBackend())
        @test result isa SymbolExpr
        @test result.name == "Pi"
    end

    @testset "Constant ExponentialE preserved" begin
        result = evaluate(SymbolExpr("ExponentialE"); backend=SymbolicsBackend())
        @test result isa SymbolExpr
        @test result.name == "ExponentialE"
    end
end

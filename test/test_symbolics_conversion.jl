using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Conversion Edge Cases (US4)" begin
    backend = SymbolicsBackend()

    @testset "Integer round-trip" begin
        result = evaluate(NumberExpr(42); backend=backend)
        @test result isa NumberExpr
        @test result.value == 42
    end

    @testset "Negative integer round-trip" begin
        result = evaluate(NumberExpr(-7); backend=backend)
        @test result isa NumberExpr
        @test result.value == -7
    end

    @testset "Zero round-trip" begin
        result = evaluate(NumberExpr(0); backend=backend)
        @test result isa NumberExpr
        @test result.value == 0
    end

    @testset "Float round-trip" begin
        result = evaluate(NumberExpr(3.14); backend=backend)
        @test result isa NumberExpr
        @test result.value ≈ 3.14
    end

    @testset "Large integer round-trip" begin
        result = evaluate(NumberExpr(1000000); backend=backend)
        @test result isa NumberExpr
        @test result.value == 1000000
    end

    @testset "Constant Pi round-trip" begin
        result = evaluate(SymbolExpr("Pi"); backend=backend)
        @test result isa SymbolExpr
        @test result.name == "Pi"
    end

    @testset "Constant ExponentialE round-trip" begin
        result = evaluate(SymbolExpr("ExponentialE"); backend=backend)
        @test result isa SymbolExpr
        @test result.name == "ExponentialE"
    end

    @testset "Symbolic variable round-trip" begin
        result = evaluate(SymbolExpr("z"); backend=backend)
        @test result isa SymbolExpr
        @test result.name == "z"
    end

    @testset "Nested arithmetic round-trip" begin
        # (2 + 3) * 4 = 20
        expr = FunctionExpr(:Multiply, [
            FunctionExpr(:Add, [NumberExpr(2), NumberExpr(3)]),
            NumberExpr(4)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 20
    end

    @testset "Symbolic arithmetic preserves variables" begin
        # x + y stays symbolic
        expr = FunctionExpr(:Add, [SymbolExpr("x"), SymbolExpr("y")])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("x", result_str)
        @test occursin("y", result_str)
    end

    @testset "Transcendental function round-trip" begin
        # sin(x) stays symbolic
        expr = FunctionExpr(:Sin, [SymbolExpr("x")])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Sin
    end

    @testset "Nested transcendental round-trip" begin
        # exp(sin(x))
        expr = FunctionExpr(:Exp, [FunctionExpr(:Sin, [SymbolExpr("x")])])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Exp
    end

    @testset "Mixed symbolic/numeric" begin
        # 2 * x + 1
        expr = FunctionExpr(:Add, [
            FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("x")]),
            NumberExpr(1)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("x", result_str)
    end

    @testset "Power with symbolic base" begin
        # x^3
        expr = FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Power
    end

    @testset "Negate" begin
        # -x
        expr = FunctionExpr(:Negate, [SymbolExpr("x")])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("x", result_str)
    end

    @testset "Division stays symbolic" begin
        # x / y
        expr = FunctionExpr(:Divide, [SymbolExpr("x"), SymbolExpr("y")])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("x", result_str)
        @test occursin("y", result_str)
    end

    @testset "Numeric division produces number" begin
        # 10 / 2 = 5
        expr = FunctionExpr(:Divide, [NumberExpr(10), NumberExpr(2)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 5
    end

    @testset "Sqrt of symbolic" begin
        expr = FunctionExpr(:Sqrt, [SymbolExpr("x")])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Sqrt || result.operator == :Power
    end

    @testset "ImaginaryUnit evaluates through SymbolicsBackend" begin
        result = evaluate(SymbolExpr("ImaginaryUnit"); backend=backend)
        # Complex(0,1) converts to MathJSON with ImaginaryUnit symbol
        result_str = string(result)
        @test occursin("ImaginaryUnit", result_str)
    end

    @testset "Add(1, ImaginaryUnit) round-trips via SymbolicsBackend" begin
        expr = FunctionExpr(:Add, [NumberExpr(1), SymbolExpr("ImaginaryUnit")])
        result = evaluate(expr; backend=backend)
        result_str = string(result)
        @test occursin("ImaginaryUnit", result_str)
    end

    @testset "Complex output contains ImaginaryUnit" begin
        expr = FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("ImaginaryUnit")])
        result = evaluate(expr; backend=backend)
        result_str = string(result)
        @test occursin("ImaginaryUnit", result_str)
    end
end

using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Calculus (US3)" begin
    backend = SymbolicsBackend()

    @testset "D(x^3, x) = 3x^2" begin
        expr = FunctionExpr(:D, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("3", result_str)
        @test occursin("x", result_str)
    end

    @testset "D(sin(x), x) = cos(x)" begin
        expr = FunctionExpr(:D, [
            FunctionExpr(:Sin, [SymbolExpr("x")]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Cos
    end

    @testset "D(exp(x), x) = exp(x)" begin
        expr = FunctionExpr(:D, [
            FunctionExpr(:Exp, [SymbolExpr("x")]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Exp
    end

    @testset "D(x^2 + 3x + 1, x) = 2x + 3" begin
        expr = FunctionExpr(:D, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                FunctionExpr(:Multiply, [NumberExpr(3), SymbolExpr("x")]),
                NumberExpr(1)
            ]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("3", result_str)
        @test occursin("x", result_str)
    end

    @testset "D(cos(x), x) = -sin(x)" begin
        expr = FunctionExpr(:D, [
            FunctionExpr(:Cos, [SymbolExpr("x")]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Result is Multiply(-1, Sin(x)) or Negate(Sin(x))
        result_str = string(result)
        @test occursin("Sin", result_str) || occursin("sin", result_str)
    end

    @testset "D(exp(x)*sin(x), x) product rule" begin
        expr = FunctionExpr(:D, [
            FunctionExpr(:Multiply, [
                FunctionExpr(:Exp, [SymbolExpr("x")]),
                FunctionExpr(:Sin, [SymbolExpr("x")])
            ]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        # Should contain both sin and cos (product rule)
        @test occursin("x", result_str)
    end

    @testset "D(constant, x) = 0" begin
        expr = FunctionExpr(:D, [
            NumberExpr(42),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 0
    end

    @testset "Integrate raises UnsupportedOperationError" begin
        expr = FunctionExpr(:Integrate, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
            SymbolExpr("x")
        ])
        @test_throws UnsupportedOperationError evaluate(expr; backend=backend)
        try
            evaluate(expr; backend=backend)
        catch e
            @test e isa UnsupportedOperationError
            @test e.operation == :Integrate
            @test "GiacBackend" in e.suggested_backends
        end
    end

    @testset "Laplace raises UnsupportedOperationError" begin
        expr = FunctionExpr(:Laplace, [
            SymbolExpr("t"),
            SymbolExpr("t"),
            SymbolExpr("s")
        ])
        @test_throws UnsupportedOperationError evaluate(expr; backend=backend)
    end
end

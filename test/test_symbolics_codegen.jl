using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Code Generation (US7)" begin
    backend = SymbolicsBackend()

    @testset "Build single variable: x^2 + 2x + 1" begin
        # Build(x^2 + 2x + 1, x)
        expr = FunctionExpr(:Build, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("x")]),
                NumberExpr(1)
            ]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :CompiledFunction
        @test length(result.arguments) >= 1
        # First argument is the expression string
        @test result.arguments[1] isa StringExpr
        result_str = result.arguments[1].value
        @test occursin("x", result_str)
    end

    @testset "Build two variables: x^2 + y" begin
        # Build(x^2 + y, x, y)
        expr = FunctionExpr(:Build, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                SymbolExpr("y")
            ]),
            SymbolExpr("x"),
            SymbolExpr("y")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :CompiledFunction
        @test result.arguments[1] isa StringExpr
        result_str = result.arguments[1].value
        @test occursin("x", result_str)
        @test occursin("y", result_str)
    end

    @testset "Build simple expression: 2x + 3" begin
        expr = FunctionExpr(:Build, [
            FunctionExpr(:Add, [
                FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("x")]),
                NumberExpr(3)
            ]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :CompiledFunction
    end

    @testset "Build with transcendental: sin(x)" begin
        expr = FunctionExpr(:Build, [
            FunctionExpr(:Sin, [SymbolExpr("x")]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :CompiledFunction
        result_str = result.arguments[1].value
        @test occursin("sin", result_str) || occursin("x", result_str)
    end
end

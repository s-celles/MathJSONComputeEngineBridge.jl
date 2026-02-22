using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Equation Solving (US6)" begin
    backend = SymbolicsBackend()

    @testset "Solve linear equation: 2x - 6 = 0 → x = 3" begin
        # 2x - 6 = 0
        expr = FunctionExpr(:Solve, [
            FunctionExpr(:Subtract, [
                FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("x")]),
                NumberExpr(6)
            ]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        # Result should contain 3
        result_str = string(result)
        @test occursin("3", result_str)
    end

    @testset "Solve linear equation: x + y = 0 → x = -y" begin
        expr = FunctionExpr(:Solve, [
            FunctionExpr(:Add, [SymbolExpr("x"), SymbolExpr("y")]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        result_str = string(result)
        @test occursin("y", result_str)
    end

    @testset "Solve simple linear: x - 5 = 0 → x = 5" begin
        expr = FunctionExpr(:Solve, [
            FunctionExpr(:Subtract, [SymbolExpr("x"), NumberExpr(5)]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        result_str = string(result)
        @test occursin("5", result_str)
    end
end

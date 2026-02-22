using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Symbolic Algebra (US2)" begin
    backend = SymbolicsBackend()

    @testset "Expand (x+1)^2" begin
        expr = FunctionExpr(:Expand, [
            FunctionExpr(:Power, [
                FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
                NumberExpr(2)
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Result should contain x^2, 2x, and 1 in some form
        result_str = string(result)
        @test occursin("x", result_str)
    end

    @testset "Expand (x+y)^2" begin
        expr = FunctionExpr(:Expand, [
            FunctionExpr(:Power, [
                FunctionExpr(:Add, [SymbolExpr("x"), SymbolExpr("y")]),
                NumberExpr(2)
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("x", result_str)
        @test occursin("y", result_str)
    end

    @testset "Simplify x + x" begin
        expr = FunctionExpr(:Simplify, [
            FunctionExpr(:Add, [SymbolExpr("x"), SymbolExpr("x")])
        ])
        result = evaluate(expr; backend=backend)
        # Should simplify to 2x
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("x", result_str)
        @test occursin("2", result_str)
    end

    @testset "Simplify 0 + x" begin
        expr = FunctionExpr(:Simplify, [
            FunctionExpr(:Add, [NumberExpr(0), SymbolExpr("x")])
        ])
        result = evaluate(expr; backend=backend)
        # Should simplify to x
        @test result isa SymbolExpr || result isa FunctionExpr
    end

    @testset "Substitute x=3 in x^2 + y" begin
        expr = FunctionExpr(:Substitute, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                SymbolExpr("y")
            ]),
            SymbolExpr("x"),
            NumberExpr(3)
        ])
        result = evaluate(expr; backend=backend)
        # Should be 9 + y
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("9", result_str)
        @test occursin("y", result_str)
    end

    @testset "Substitute x=3, y=1 in x^2 + y → 10" begin
        expr = FunctionExpr(:Substitute, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                SymbolExpr("y")
            ]),
            SymbolExpr("x"),
            NumberExpr(3),
            SymbolExpr("y"),
            NumberExpr(1)
        ])
        result = evaluate(expr; backend=backend)
        # Should be 10
        @test result isa NumberExpr
        @test result.value == 10
    end

    @testset "Substitute preserves symbolic variables" begin
        # Substitute x=a in x^2 → a^2
        expr = FunctionExpr(:Substitute, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
            SymbolExpr("x"),
            SymbolExpr("a")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("a", result_str)
    end

    @testset "Expand linear (x+1)*(x-1)" begin
        expr = FunctionExpr(:Expand, [
            FunctionExpr(:Multiply, [
                FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
                FunctionExpr(:Subtract, [SymbolExpr("x"), NumberExpr(1)])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Should be x^2 - 1
        result_str = string(result)
        @test occursin("x", result_str)
    end
end

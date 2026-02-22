using MathJSON
using MathJSONComputeEngineBridge
using Test

@testset "Fibonacci" begin
    @testset "Fibonacci(0) = 0" begin
        expr = FunctionExpr(:Fibonacci, [NumberExpr(0)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 0
    end

    @testset "Fibonacci(1) = 1" begin
        expr = FunctionExpr(:Fibonacci, [NumberExpr(1)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 1
    end

    @testset "Fibonacci(10) = 55" begin
        expr = FunctionExpr(:Fibonacci, [NumberExpr(10)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 55
    end

    @testset "Fibonacci(20) = 6765" begin
        expr = FunctionExpr(:Fibonacci, [NumberExpr(20)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 6765
    end

    @testset "Fibonacci(-1) raises error" begin
        expr = FunctionExpr(:Fibonacci, [NumberExpr(-1)])
        @test_throws ArgumentError evaluate(expr)
    end
end

@testset "Permutations" begin
    @testset "Permutations(5, 3) = 60" begin
        expr = FunctionExpr(:Permutations, [NumberExpr(5), NumberExpr(3)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 60
    end

    @testset "Permutations(5, 0) = 1" begin
        expr = FunctionExpr(:Permutations, [NumberExpr(5), NumberExpr(0)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 1
    end

    @testset "Permutations(5, 5) = 120" begin
        expr = FunctionExpr(:Permutations, [NumberExpr(5), NumberExpr(5)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 120
    end

    @testset "Permutations(3, 5) = 0" begin
        expr = FunctionExpr(:Permutations, [NumberExpr(3), NumberExpr(5)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 0
    end
end

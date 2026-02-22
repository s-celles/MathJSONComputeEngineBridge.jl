using MathJSON
using MathJSONComputeEngineBridge
using Test

@testset "Mean" begin
    @testset "Mean(List(1,2,3,4,5)) = 3.0" begin
        expr = FunctionExpr(:Mean, [
            FunctionExpr(:List, [NumberExpr(1), NumberExpr(2), NumberExpr(3), NumberExpr(4), NumberExpr(5)])
        ])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 3.0
    end

    @testset "Mean(List(10)) = 10.0" begin
        expr = FunctionExpr(:Mean, [
            FunctionExpr(:List, [NumberExpr(10)])
        ])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 10.0
    end

    @testset "Mean(empty list) raises error" begin
        expr = FunctionExpr(:Mean, [
            FunctionExpr(:List, AbstractMathJSONExpr[])
        ])
        @test_throws ArgumentError evaluate(expr)
    end
end

@testset "Median" begin
    @testset "Median(List(1,2,3,4,5)) = 3.0" begin
        expr = FunctionExpr(:Median, [
            FunctionExpr(:List, [NumberExpr(1), NumberExpr(2), NumberExpr(3), NumberExpr(4), NumberExpr(5)])
        ])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 3.0
    end

    @testset "Median(List(1,2,3,4)) = 2.5" begin
        expr = FunctionExpr(:Median, [
            FunctionExpr(:List, [NumberExpr(1), NumberExpr(2), NumberExpr(3), NumberExpr(4)])
        ])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 2.5
    end

    @testset "Median(empty list) raises error" begin
        expr = FunctionExpr(:Median, [
            FunctionExpr(:List, AbstractMathJSONExpr[])
        ])
        @test_throws ArgumentError evaluate(expr)
    end
end

@testset "Variance" begin
    @testset "Variance(List(2,4,4,4,5,5,7,9)) = 4.0" begin
        data = FunctionExpr(:List, [NumberExpr(2), NumberExpr(4), NumberExpr(4), NumberExpr(4),
                                    NumberExpr(5), NumberExpr(5), NumberExpr(7), NumberExpr(9)])
        expr = FunctionExpr(:Variance, [data])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 4.0
    end

    @testset "Variance(List(5)) = 0.0" begin
        expr = FunctionExpr(:Variance, [
            FunctionExpr(:List, [NumberExpr(5)])
        ])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 0.0
    end

    @testset "Variance(empty list) raises error" begin
        expr = FunctionExpr(:Variance, [
            FunctionExpr(:List, AbstractMathJSONExpr[])
        ])
        @test_throws ArgumentError evaluate(expr)
    end
end

@testset "StandardDeviation" begin
    @testset "StandardDeviation(List(2,4,4,4,5,5,7,9)) = 2.0" begin
        data = FunctionExpr(:List, [NumberExpr(2), NumberExpr(4), NumberExpr(4), NumberExpr(4),
                                    NumberExpr(5), NumberExpr(5), NumberExpr(7), NumberExpr(9)])
        expr = FunctionExpr(:StandardDeviation, [data])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 2.0
    end

    @testset "StandardDeviation(List(5)) = 0.0" begin
        expr = FunctionExpr(:StandardDeviation, [
            FunctionExpr(:List, [NumberExpr(5)])
        ])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value ≈ 0.0
    end

    @testset "StandardDeviation(empty list) raises error" begin
        expr = FunctionExpr(:StandardDeviation, [
            FunctionExpr(:List, AbstractMathJSONExpr[])
        ])
        @test_throws ArgumentError evaluate(expr)
    end
end

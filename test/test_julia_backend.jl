using MathJSONComputeEngineBridge
using MathJSON
using Test

@testset "JuliaBackend arithmetic" begin
    @testset "Add" begin
        expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), NumberExpr(2)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 3
    end

    @testset "Add with floats" begin
        expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1.5), NumberExpr(2.5)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 4.0
    end

    @testset "Subtract" begin
        expr = FunctionExpr(:Subtract, AbstractMathJSONExpr[NumberExpr(10), NumberExpr(4)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 6
    end

    @testset "Multiply" begin
        expr = FunctionExpr(:Multiply, AbstractMathJSONExpr[NumberExpr(3), NumberExpr(4)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 12
    end

    @testset "Divide" begin
        expr = FunctionExpr(:Divide, AbstractMathJSONExpr[NumberExpr(10), NumberExpr(2)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 5
    end

    @testset "Divide float result" begin
        expr = FunctionExpr(:Divide, AbstractMathJSONExpr[NumberExpr(7), NumberExpr(2)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 3.5
    end

    @testset "Negate" begin
        expr = FunctionExpr(:Negate, AbstractMathJSONExpr[NumberExpr(5)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == -5
    end

    @testset "Negate negative" begin
        expr = FunctionExpr(:Negate, AbstractMathJSONExpr[NumberExpr(-3)])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 3
    end
end

@testset "JuliaBackend nested expressions" begin
    @testset "Add(1, Multiply(2, 3)) = 7" begin
        inner = FunctionExpr(:Multiply, AbstractMathJSONExpr[NumberExpr(2), NumberExpr(3)])
        expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), inner])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 7
    end

    @testset "Subtract(Multiply(3, 4), Add(1, 2)) = 9" begin
        left = FunctionExpr(:Multiply, AbstractMathJSONExpr[NumberExpr(3), NumberExpr(4)])
        right = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), NumberExpr(2)])
        expr = FunctionExpr(:Subtract, AbstractMathJSONExpr[left, right])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 9
    end

    @testset "Negate(Add(1, 2)) = -3" begin
        inner = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), NumberExpr(2)])
        expr = FunctionExpr(:Negate, AbstractMathJSONExpr[inner])
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == -3
    end

    @testset "deeply nested (10 levels)" begin
        # Build: Add(1, Add(1, Add(1, ... Add(1, 1)...)))
        expr = NumberExpr(1)
        for _ in 1:10
            expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), expr])
        end
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 11
    end
end

@testset "JuliaBackend NumberExpr passthrough" begin
    @testset "bare integer" begin
        expr = NumberExpr(42)
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 42
    end

    @testset "bare float" begin
        expr = NumberExpr(3.14)
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 3.14
    end

    @testset "bare zero" begin
        expr = NumberExpr(0)
        result = evaluate(expr)
        @test result isa NumberExpr
        @test result.value == 0
    end
end

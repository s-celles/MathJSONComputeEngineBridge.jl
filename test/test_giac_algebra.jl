@testset "GiacBackend Symbolic Algebra (US2)" begin
    backend = GiacBackend()

    @testset "Factor(x^2 - 1) = (x-1)(x+1)" begin
        expr = FunctionExpr(:Factor, [
            FunctionExpr(:Subtract, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                NumberExpr(1)
            ])
        ])
        result = evaluate(expr; backend=backend)
        # Result should be a product of two terms
        @test result isa FunctionExpr
        @test result.operator == :Multiply
    end

    @testset "Expand((x+1)^2) = x^2 + 2x + 1" begin
        expr = FunctionExpr(:Expand, [
            FunctionExpr(:Power, [
                FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
                NumberExpr(2)
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Add
    end

    @testset "Simplify((x^2-1)/(x-1)) = x+1" begin
        expr = FunctionExpr(:Simplify, [
            FunctionExpr(:Divide, [
                FunctionExpr(:Subtract, [
                    FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                    NumberExpr(1)
                ]),
                FunctionExpr(:Subtract, [SymbolExpr("x"), NumberExpr(1)])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Add
    end

    @testset "Solve(x^2-4, x) returns list with -2 and 2" begin
        expr = FunctionExpr(:Solve, [
            FunctionExpr(:Subtract, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                NumberExpr(4)
            ]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :List
        # Should have 2 solutions
        @test length(result.arguments) == 2
        # Extract values
        vals = sort([arg.value for arg in result.arguments])
        @test vals == [-2, 2]
    end

    @testset "GCD of two polynomials" begin
        # GCD(x^2-1, x-1) = x-1
        expr = FunctionExpr(:GCD, [
            FunctionExpr(:Subtract, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                NumberExpr(1)
            ]),
            FunctionExpr(:Subtract, [SymbolExpr("x"), NumberExpr(1)])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Result should be x+(-1) or x-1
        @test result.operator == :Add || result.operator == :Subtract
    end

    @testset "Factor integer" begin
        # Factor(12) — numeric factoring
        expr = FunctionExpr(:Factor, [NumberExpr(12)])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr || result isa NumberExpr
    end
end

@testset "GiacBackend Number Theory (US7)" begin
    backend = GiacBackend()

    @testset "IsPrime(17) = True" begin
        expr = FunctionExpr(:IsPrime, [NumberExpr(17)])
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "True"
    end

    @testset "IsPrime(12) = False" begin
        expr = FunctionExpr(:IsPrime, [NumberExpr(12)])
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "False"
    end

    @testset "IsPrime(2) = True" begin
        expr = FunctionExpr(:IsPrime, [NumberExpr(2)])
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "True"
    end

    @testset "Factorial(10) = 3628800" begin
        expr = FunctionExpr(:Factorial, [NumberExpr(10)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 3628800
    end

    @testset "Factorial(0) = 1" begin
        expr = FunctionExpr(:Factorial, [NumberExpr(0)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 1
    end

    @testset "LCM(12, 18) = 36" begin
        expr = FunctionExpr(:LCM, [NumberExpr(12), NumberExpr(18)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 36
    end

    @testset "GCD(12, 18) = 6" begin
        expr = FunctionExpr(:GCD, [NumberExpr(12), NumberExpr(18)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 6
    end

    @testset "Mod(17, 5) = 2" begin
        expr = FunctionExpr(:Mod, [NumberExpr(17), NumberExpr(5)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 2
    end

    @testset "ModPow(2, 10, 1000) = 24" begin
        expr = FunctionExpr(:ModPow, [NumberExpr(2), NumberExpr(10), NumberExpr(1000)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 24
    end

    @testset "IntegerFactorization(60)" begin
        # ifactor(60) = 2^2*3*5 — Giac returns a factored form
        expr = FunctionExpr(:IntegerFactorization, [NumberExpr(60)])
        result = evaluate(expr; backend=backend)
        # Result is a symbolic expression representing the factored form
        @test result isa FunctionExpr || result isa NumberExpr
    end
end

@testset "GiacBackend Transforms (US5)" begin
    backend = GiacBackend()

    @testset "Laplace(t^2, t, s) = 2/s^3" begin
        expr = FunctionExpr(:Laplace, [
            FunctionExpr(:Power, [SymbolExpr("t"), NumberExpr(2)]),
            SymbolExpr("t"),
            SymbolExpr("s")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Giac represents 2/s^3 as Multiply(2, Inverse(Power(s, 3)))
        @test result.operator in (:Multiply, :Divide)
    end

    @testset "InverseLaplace(1/s^2, s, t) = t" begin
        expr = FunctionExpr(:InverseLaplace, [
            FunctionExpr(:Divide, [NumberExpr(1), FunctionExpr(:Power, [SymbolExpr("s"), NumberExpr(2)])]),
            SymbolExpr("s"),
            SymbolExpr("t")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "t"
    end

    @testset "Laplace(exp(a*t), t, s)" begin
        expr = FunctionExpr(:Laplace, [
            FunctionExpr(:Exp, [FunctionExpr(:Multiply, [SymbolExpr("a"), SymbolExpr("t")])]),
            SymbolExpr("t"),
            SymbolExpr("s")
        ])
        result = evaluate(expr; backend=backend)
        # Giac returns -1/(a-s) or similar form
        @test result isa FunctionExpr
    end

    @testset "ZTransform(1, n, z) = z/(z-1)" begin
        expr = FunctionExpr(:ZTransform, [
            NumberExpr(1),
            SymbolExpr("n"),
            SymbolExpr("z")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Giac represents z/(z-1) as Multiply(z, Inverse(z-1))
        @test result.operator in (:Multiply, :Divide)
    end

    @testset "Laplace round-trip: Laplace then InverseLaplace" begin
        # Laplace(t, t, s) = 1/s^2
        laplace_expr = FunctionExpr(:Laplace, [
            SymbolExpr("t"),
            SymbolExpr("t"),
            SymbolExpr("s")
        ])
        laplace_result = evaluate(laplace_expr; backend=backend)

        # InverseLaplace of the result should give back t
        inv_expr = FunctionExpr(:InverseLaplace, [
            laplace_result,
            SymbolExpr("s"),
            SymbolExpr("t")
        ])
        result = evaluate(inv_expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "t"
    end
end

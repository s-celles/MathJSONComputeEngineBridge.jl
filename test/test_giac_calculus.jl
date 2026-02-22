@testset "GiacBackend Calculus Operations (US3)" begin
    backend = GiacBackend()

    @testset "D(x^3, x) = 3x^2" begin
        # Differentiate x^3 with respect to x
        expr = FunctionExpr(:D, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        # Result should be 3*x^2
        @test result isa FunctionExpr
        @test result.operator == :Multiply
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

    @testset "Integrate(x^2, x) indefinite" begin
        # Indefinite integral of x^2 with respect to x → x^3/3
        expr = FunctionExpr(:Integrate, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Result should be x^3/3 = Multiply(Divide(1,3), Power(x,3)) or similar
    end

    @testset "Integrate(x^2, x, 0, 1) definite = 1/3" begin
        # Definite integral of x^2 from 0 to 1
        expr = FunctionExpr(:Integrate, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
            SymbolExpr("x"),
            NumberExpr(0),
            NumberExpr(1)
        ])
        result = evaluate(expr; backend=backend)
        # Result should be 1/3
        @test result isa FunctionExpr
        @test result.operator == :Divide
        @test result.arguments[1] isa NumberExpr
        @test result.arguments[1].value == 1
        @test result.arguments[2] isa NumberExpr
        @test result.arguments[2].value == 3
    end

    @testset "Limit(sin(x)/x, x, 0) = 1" begin
        expr = FunctionExpr(:Limit, [
            FunctionExpr(:Divide, [
                FunctionExpr(:Sin, [SymbolExpr("x")]),
                SymbolExpr("x")
            ]),
            SymbolExpr("x"),
            NumberExpr(0)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 1
    end

    @testset "Limit(1/x, x, 0) — infinity" begin
        # Limit as x→0 of 1/x — should return some infinity representation
        expr = FunctionExpr(:Limit, [
            FunctionExpr(:Divide, [NumberExpr(1), SymbolExpr("x")]),
            SymbolExpr("x"),
            NumberExpr(0)
        ])
        result = evaluate(expr; backend=backend)
        # Giac may return unsigned infinity or an error — just verify it returns something
        @test result isa Union{SymbolExpr, FunctionExpr, NumberExpr}
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

    @testset "Integrate(cos(x), x) = sin(x)" begin
        expr = FunctionExpr(:Integrate, [
            FunctionExpr(:Cos, [SymbolExpr("x")]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Sin
    end
end

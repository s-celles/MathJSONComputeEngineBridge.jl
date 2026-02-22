@testset "GiacBackend ODEs and Series (US8)" begin
    backend = GiacBackend()

    @testset "Series expansion of sin(x) around 0 to order 5" begin
        # series(sin(x), x, 0, 5) = x - x^3/6 + x^5/120 + O(x^6)
        expr = FunctionExpr(:Series, [
            FunctionExpr(:Sin, [SymbolExpr("x")]),
            SymbolExpr("x"),
            NumberExpr(0),
            NumberExpr(5)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # The result is a polynomial expression (Add of terms)
        @test result.operator == :Add
    end

    @testset "Taylor expansion of exp(x) to order 3" begin
        # taylor(exp(x), x, 3) = 1 + x + x^2/2 + x^3/6 + O(x^4)
        expr = FunctionExpr(:Taylor, [
            FunctionExpr(:Exp, [SymbolExpr("x")]),
            SymbolExpr("x"),
            NumberExpr(3)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Add
    end

    @testset "Taylor expansion of cos(x) to order 4" begin
        # taylor(cos(x), x, 4) = 1 - x^2/2 + x^4/24 + O(x^5)
        expr = FunctionExpr(:Taylor, [
            FunctionExpr(:Cos, [SymbolExpr("x")]),
            SymbolExpr("x"),
            NumberExpr(4)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Add
    end

    @testset "Series of 1/(1-x) around 0 to order 3" begin
        # series(1/(1-x), x, 0, 3) = 1 + x + x^2 + x^3 + O(x^4)
        expr = FunctionExpr(:Series, [
            FunctionExpr(:Divide, [
                NumberExpr(1),
                FunctionExpr(:Subtract, [NumberExpr(1), SymbolExpr("x")])
            ]),
            SymbolExpr("x"),
            NumberExpr(0),
            NumberExpr(3)
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Add
    end
end

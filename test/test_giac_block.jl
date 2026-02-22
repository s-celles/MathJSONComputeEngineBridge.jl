using MathJSON

@testset "GiacBackend Block/Function/Limits" begin
    backend = GiacBackend()

    @testset "Block passthrough on GiacBackend" begin
        expr = FunctionExpr(:Block, [FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)])])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 3
    end

    @testset "Nothing sentinel on GiacBackend" begin
        expr = SymbolExpr("Nothing")
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "Nothing"
    end

    @testset "Indefinite Integrate with Function/Limits (PlutoMathInput form)" begin
        # PlutoMathInput form: Integrate(Function(Block(Tan(x)), x), Limits(x, Nothing, Nothing))
        plutomathinput_form = FunctionExpr(:Integrate, [
            FunctionExpr(:Function, [
                FunctionExpr(:Block, [FunctionExpr(:Tan, [SymbolExpr("x")])]),
                SymbolExpr("x")
            ]),
            FunctionExpr(:Limits, [
                SymbolExpr("x"),
                SymbolExpr("Nothing"),
                SymbolExpr("Nothing")
            ])
        ])

        # Direct form: Integrate(Tan(x), x)
        direct_form = FunctionExpr(:Integrate, [
            FunctionExpr(:Tan, [SymbolExpr("x")]),
            SymbolExpr("x")
        ])

        result_pluto = evaluate(plutomathinput_form; backend=backend)
        result_direct = evaluate(direct_form; backend=backend)

        # Both forms should produce equivalent results
        @test string(result_pluto) == string(result_direct)
    end

    @testset "Definite Integrate with Function/Limits and numeric bounds" begin
        # PlutoMathInput form: Integrate(Function(Block(x^2), x), Limits(x, 0, 1))
        plutomathinput_form = FunctionExpr(:Integrate, [
            FunctionExpr(:Function, [
                FunctionExpr(:Block, [FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)])]),
                SymbolExpr("x")
            ]),
            FunctionExpr(:Limits, [
                SymbolExpr("x"),
                NumberExpr(0),
                NumberExpr(1)
            ])
        ])

        # Direct form: Integrate(x^2, x, 0, 1)
        direct_form = FunctionExpr(:Integrate, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
            SymbolExpr("x"),
            NumberExpr(0),
            NumberExpr(1)
        ])

        result_pluto = evaluate(plutomathinput_form; backend=backend)
        result_direct = evaluate(direct_form; backend=backend)

        @test string(result_pluto) == string(result_direct)
    end

    @testset "Differentiation with Function/Limits form" begin
        # PlutoMathInput form: D(Function(Block(x^2), x), Limits(x, Nothing, Nothing))
        plutomathinput_form = FunctionExpr(:D, [
            FunctionExpr(:Function, [
                FunctionExpr(:Block, [FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)])]),
                SymbolExpr("x")
            ]),
            FunctionExpr(:Limits, [
                SymbolExpr("x"),
                SymbolExpr("Nothing"),
                SymbolExpr("Nothing")
            ])
        ])

        # Direct form: D(x^2, x)
        direct_form = FunctionExpr(:D, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
            SymbolExpr("x")
        ])

        result_pluto = evaluate(plutomathinput_form; backend=backend)
        result_direct = evaluate(direct_form; backend=backend)

        @test string(result_pluto) == string(result_direct)
    end

    @testset "Function with fewer than 2 args raises error" begin
        expr = FunctionExpr(:Integrate, [
            FunctionExpr(:Function, [
                FunctionExpr(:Block, [SymbolExpr("x")])
            ]),
            FunctionExpr(:Limits, [
                SymbolExpr("x"),
                SymbolExpr("Nothing"),
                SymbolExpr("Nothing")
            ])
        ])
        @test_throws ArgumentError evaluate(expr; backend=backend)
    end

    @testset "Limits with fewer than 3 args raises error" begin
        expr = FunctionExpr(:Integrate, [
            FunctionExpr(:Function, [
                FunctionExpr(:Block, [SymbolExpr("x")]),
                SymbolExpr("x")
            ]),
            FunctionExpr(:Limits, [
                SymbolExpr("x"),
                SymbolExpr("Nothing")
            ])
        ])
        @test_throws ArgumentError evaluate(expr; backend=backend)
    end

    @testset "Non-Function/Limits args pass through unchanged" begin
        # Standard direct form should still work
        direct_form = FunctionExpr(:Integrate, [
            FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]),
            SymbolExpr("x")
        ])
        result = evaluate(direct_form; backend=backend)
        # Should succeed without error (already works)
        @test result isa AbstractMathJSONExpr
    end
end

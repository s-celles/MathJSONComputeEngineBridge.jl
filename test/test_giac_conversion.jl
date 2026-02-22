@testset "GiacBackend Conversion Edge Cases (US4)" begin
    backend = GiacBackend()

    @testset "Numbers" begin
        @testset "Integer passthrough" begin
            result = evaluate(NumberExpr(42); backend=backend)
            @test result isa NumberExpr
            @test result.value == 42
        end

        @testset "Negative integer" begin
            result = evaluate(NumberExpr(-7); backend=backend)
            @test result isa NumberExpr
            @test result.value == -7
        end

        @testset "Float passthrough" begin
            result = evaluate(NumberExpr(3.14); backend=backend)
            @test result isa NumberExpr
            @test result.value ≈ 3.14
        end

        @testset "Zero" begin
            result = evaluate(NumberExpr(0); backend=backend)
            @test result isa NumberExpr
            @test result.value == 0
        end

        @testset "Large integer" begin
            result = evaluate(NumberExpr(1000000); backend=backend)
            @test result isa NumberExpr
            @test result.value == 1000000
        end
    end

    @testset "Constants preserved" begin
        @testset "Pi" begin
            result = evaluate(SymbolExpr("Pi"); backend=backend)
            @test result isa SymbolExpr
            @test result.name == "Pi"
        end

        @testset "ExponentialE" begin
            result = evaluate(SymbolExpr("ExponentialE"); backend=backend)
            @test result isa SymbolExpr
            @test result.name == "ExponentialE"
        end

        @testset "ImaginaryUnit" begin
            result = evaluate(SymbolExpr("ImaginaryUnit"); backend=backend)
            @test result isa SymbolExpr
            @test result.name == "ImaginaryUnit"
        end
    end

    @testset "Symbolic variables preserved" begin
        @testset "Simple variable x" begin
            result = evaluate(SymbolExpr("x"); backend=backend)
            @test result isa SymbolExpr
            @test result.name == "x"
        end

        @testset "Variable y" begin
            result = evaluate(SymbolExpr("y"); backend=backend)
            @test result isa SymbolExpr
            @test result.name == "y"
        end
    end

    @testset "Rational results" begin
        @testset "1/3 from computation" begin
            # Integrate(x^2, x, 0, 1) = 1/3
            expr = FunctionExpr(:Integrate, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                SymbolExpr("x"),
                NumberExpr(0),
                NumberExpr(1)
            ])
            result = evaluate(expr; backend=backend)
            @test result isa FunctionExpr
            @test result.operator == :Divide
        end
    end

    @testset "Nested expressions" begin
        @testset "sin(x^2 + 1) differentiates correctly" begin
            # D(sin(x^2 + 1), x) = cos(x^2+1) * 2x
            expr = FunctionExpr(:D, [
                FunctionExpr(:Sin, [
                    FunctionExpr(:Add, [
                        FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                        NumberExpr(1)
                    ])
                ]),
                SymbolExpr("x")
            ])
            result = evaluate(expr; backend=backend)
            @test result isa FunctionExpr
            # Result should be a product: 2*x*cos(x^2+1) or similar
            @test result.operator == :Multiply
        end

        @testset "Deeply nested arithmetic" begin
            # ((2+3)*4 - 1) = 19
            expr = FunctionExpr(:Subtract, [
                FunctionExpr(:Multiply, [
                    FunctionExpr(:Add, [NumberExpr(2), NumberExpr(3)]),
                    NumberExpr(4)
                ]),
                NumberExpr(1)
            ])
            result = evaluate(expr; backend=backend)
            @test result isa NumberExpr
            @test result.value == 19
        end
    end

    @testset "Mixed symbolic/numeric" begin
        @testset "x + 0 simplifies to x" begin
            expr = FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(0)])
            result = evaluate(expr; backend=backend)
            @test result isa SymbolExpr
            @test result.name == "x"
        end

        @testset "x * 1 simplifies to x" begin
            expr = FunctionExpr(:Multiply, [SymbolExpr("x"), NumberExpr(1)])
            result = evaluate(expr; backend=backend)
            @test result isa SymbolExpr
            @test result.name == "x"
        end

        @testset "0 * x simplifies to 0" begin
            expr = FunctionExpr(:Multiply, [NumberExpr(0), SymbolExpr("x")])
            result = evaluate(expr; backend=backend)
            @test result isa NumberExpr
            @test result.value == 0
        end
    end

    @testset "Round-trip consistency" begin
        @testset "Factor then Expand returns equivalent" begin
            # Factor(x^2-1) → (x-1)(x+1), then Expand back → x^2-1
            orig = FunctionExpr(:Subtract, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]),
                NumberExpr(1)
            ])
            factored = evaluate(FunctionExpr(:Factor, [orig]); backend=backend)
            expanded = evaluate(FunctionExpr(:Expand, [factored]); backend=backend)
            @test expanded isa FunctionExpr
            @test expanded.operator == :Add || expanded.operator == :Subtract
        end
    end

    @testset "Fallback for unmapped operators" begin
        # Unknown function names go through fallback via invoke_cmd
        # Giac treats unknown commands as symbolic function calls
        result = evaluate(FunctionExpr(:CompletelyUnknownGiacCommand12345, [NumberExpr(1)]); backend=backend)
        @test result isa FunctionExpr
    end
end

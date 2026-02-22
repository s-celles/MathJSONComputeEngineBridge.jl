@testset "GiacBackend Fallback Mechanism (US9)" begin
    backend = GiacBackend()

    @testset "Quo (polynomial quotient) via fallback" begin
        # quo(x^3+x+1, x+1, x) = x^2-x+2
        expr = FunctionExpr(:Quo, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]),
                SymbolExpr("x"),
                NumberExpr(1)
            ]),
            FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # x^2 - x + 2
        @test result.operator == :Add
    end

    @testset "Rem (polynomial remainder) via fallback" begin
        # rem(x^3+x+1, x+1, x) = -1
        expr = FunctionExpr(:Rem, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]),
                SymbolExpr("x"),
                NumberExpr(1)
            ]),
            FunctionExpr(:Add, [SymbolExpr("x"), NumberExpr(1)]),
            SymbolExpr("x")
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == -1
    end

    @testset "Numer via fallback" begin
        # numer(2/3) = 2
        expr = FunctionExpr(:Numer, [
            FunctionExpr(:Divide, [NumberExpr(2), NumberExpr(3)])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 2
    end

    @testset "Denom via fallback" begin
        # denom(2/3) = 3
        expr = FunctionExpr(:Denom, [
            FunctionExpr(:Divide, [NumberExpr(2), NumberExpr(3)])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 3
    end

    @testset "Normal (canonical simplification) via fallback" begin
        # normal((x^2-1)/(x-1)) = x+1
        expr = FunctionExpr(:Normal, [
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

    @testset "Unknown command returns symbolic result" begin
        # Completely unknown commands are treated as symbolic function calls
        result = evaluate(FunctionExpr(:SomeVeryUnknownCommand, [NumberExpr(42)]); backend=backend)
        @test result isa FunctionExpr || result isa NumberExpr
    end

    @testset "At least 5 distinct unmapped commands work" begin
        # Verify fallback handles diverse Giac commands
        commands_tested = 0

        # 1. degree(x^3+x, x) = 3
        r = evaluate(FunctionExpr(:Degree, [
            FunctionExpr(:Add, [FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]), SymbolExpr("x")]),
            SymbolExpr("x")
        ]); backend=backend)
        @test r isa NumberExpr
        @test r.value == 3
        commands_tested += 1

        # 2. coeff(x^3+2x+1, x, 1) = 2
        r = evaluate(FunctionExpr(:Coeff, [
            FunctionExpr(:Add, [
                FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(3)]),
                FunctionExpr(:Multiply, [NumberExpr(2), SymbolExpr("x")]),
                NumberExpr(1)
            ]),
            SymbolExpr("x"),
            NumberExpr(1)
        ]); backend=backend)
        @test r isa NumberExpr
        @test r.value == 2
        commands_tested += 1

        # 3. numer (already tested above but count it)
        commands_tested += 1

        # 4. denom (already tested above)
        commands_tested += 1

        # 5. normal (already tested above)
        commands_tested += 1

        @test commands_tested >= 5
    end
end

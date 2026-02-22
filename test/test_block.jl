using MathJSON

@testset "Block passthrough (JuliaBackend)" begin
    backend = JuliaBackend()

    @testset "Block with single child" begin
        expr = FunctionExpr(:Block, [FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)])])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 3
    end

    @testset "Block with multiple children returns last" begin
        expr = FunctionExpr(:Block, [
            FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)]),
            FunctionExpr(:Multiply, [NumberExpr(3), NumberExpr(4)])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 12
    end

    @testset "Nested Block" begin
        expr = FunctionExpr(:Block, [
            FunctionExpr(:Block, [FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)])])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 3
    end

    @testset "Block with single number" begin
        expr = FunctionExpr(:Block, [NumberExpr(42)])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == 42
    end

    @testset "Empty Block raises ArgumentError" begin
        expr = FunctionExpr(:Block, AbstractMathJSONExpr[])
        @test_throws ArgumentError evaluate(expr; backend=backend)
    end
end

@testset "Nothing sentinel (JuliaBackend)" begin
    backend = JuliaBackend()

    @testset "Nothing passes through unchanged" begin
        expr = SymbolExpr("Nothing")
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "Nothing"
    end

    @testset "Nothing in arithmetic raises error" begin
        expr = FunctionExpr(:Add, [NumberExpr(1), SymbolExpr("Nothing")])
        @test_throws Exception evaluate(expr; backend=backend)
    end

    @testset "Nothing inside Block passes through" begin
        expr = FunctionExpr(:Block, [SymbolExpr("Nothing")])
        result = evaluate(expr; backend=backend)
        @test result isa SymbolExpr
        @test result.name == "Nothing"
    end
end

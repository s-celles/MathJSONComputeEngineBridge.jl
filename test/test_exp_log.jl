using MathJSON

@testset "Exponential functions" begin
    @test evaluate(FunctionExpr(:Exp, [NumberExpr(0)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Exp, [NumberExpr(1)])).value ≈ ℯ
    @test evaluate(FunctionExpr(:Exp, [NumberExpr(-1)])).value ≈ 1/ℯ
end

@testset "Natural logarithm (Ln)" begin
    @test evaluate(FunctionExpr(:Ln, [NumberExpr(1)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Ln, [NumberExpr(Float64(ℯ))])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Ln, [NumberExpr(Float64(ℯ^2))])).value ≈ 2.0
end

@testset "Log with 1 arg (natural log)" begin
    @test evaluate(FunctionExpr(:Log, [NumberExpr(1)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Log, [NumberExpr(Float64(ℯ))])).value ≈ 1.0
end

@testset "Log with 2 args (value, base)" begin
    # Log(8, 2) = log base 2 of 8 = 3
    @test evaluate(FunctionExpr(:Log, [NumberExpr(8), NumberExpr(2)])).value ≈ 3.0
    # Log(100, 10) = log base 10 of 100 = 2
    @test evaluate(FunctionExpr(:Log, [NumberExpr(100), NumberExpr(10)])).value ≈ 2.0
    # Log(27, 3) = log base 3 of 27 = 3
    @test evaluate(FunctionExpr(:Log, [NumberExpr(27), NumberExpr(3)])).value ≈ 3.0
end

@testset "Log2" begin
    @test evaluate(FunctionExpr(:Log2, [NumberExpr(1)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Log2, [NumberExpr(8)])).value ≈ 3.0
    @test evaluate(FunctionExpr(:Log2, [NumberExpr(1024)])).value ≈ 10.0
end

@testset "Log10" begin
    @test evaluate(FunctionExpr(:Log10, [NumberExpr(1)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Log10, [NumberExpr(1000)])).value ≈ 3.0
    @test evaluate(FunctionExpr(:Log10, [NumberExpr(100)])).value ≈ 2.0
end

@testset "Exp/Ln round-trip" begin
    # Ln(Exp(2.5)) ≈ 2.5
    expr = FunctionExpr(:Ln, [FunctionExpr(:Exp, [NumberExpr(2.5)])])
    @test evaluate(expr).value ≈ 2.5
end

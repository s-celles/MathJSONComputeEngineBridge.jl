using MathJSON

@testset "Hyperbolic functions" begin
    @test evaluate(FunctionExpr(:Sinh, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Sinh, [NumberExpr(1)])).value ≈ sinh(1)
    @test evaluate(FunctionExpr(:Cosh, [NumberExpr(0)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Cosh, [NumberExpr(1)])).value ≈ cosh(1)
    @test evaluate(FunctionExpr(:Tanh, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Tanh, [NumberExpr(1)])).value ≈ tanh(1)
    @test evaluate(FunctionExpr(:Coth, [NumberExpr(1)])).value ≈ coth(1)
    @test evaluate(FunctionExpr(:Sech, [NumberExpr(0)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Sech, [NumberExpr(1)])).value ≈ sech(1)
    @test evaluate(FunctionExpr(:Csch, [NumberExpr(1)])).value ≈ csch(1)
end

@testset "Inverse hyperbolic functions (ISO naming)" begin
    @test evaluate(FunctionExpr(:Arsinh, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Arsinh, [NumberExpr(1)])).value ≈ asinh(1)
    @test evaluate(FunctionExpr(:Arcosh, [NumberExpr(1)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Arcosh, [NumberExpr(2)])).value ≈ acosh(2)
    @test evaluate(FunctionExpr(:Artanh, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Artanh, [NumberExpr(0.5)])).value ≈ atanh(0.5)
    @test evaluate(FunctionExpr(:Arcoth, [NumberExpr(2)])).value ≈ acoth(2)
    @test evaluate(FunctionExpr(:Arsech, [NumberExpr(0.5)])).value ≈ asech(0.5)
    @test evaluate(FunctionExpr(:Arcsch, [NumberExpr(1)])).value ≈ acsch(1)
end

@testset "Hyperbolic round-trip" begin
    # Arsinh(Sinh(1.5)) ≈ 1.5
    expr = FunctionExpr(:Arsinh, [FunctionExpr(:Sinh, [NumberExpr(1.5)])])
    @test evaluate(expr).value ≈ 1.5
end

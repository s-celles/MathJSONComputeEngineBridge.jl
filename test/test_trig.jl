using MathJSON

@testset "Trigonometric functions" begin
    @test evaluate(FunctionExpr(:Sin, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Sin, [NumberExpr(π/2)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Sin, [NumberExpr(π/6)])).value ≈ 0.5
    @test evaluate(FunctionExpr(:Cos, [NumberExpr(0)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Cos, [NumberExpr(Float64(π))])).value ≈ -1.0
    @test evaluate(FunctionExpr(:Cos, [NumberExpr(π/3)])).value ≈ 0.5
    @test evaluate(FunctionExpr(:Tan, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Tan, [NumberExpr(π/4)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Cot, [NumberExpr(π/4)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Cot, [NumberExpr(π/2)])).value ≈ 0.0 atol=1e-15
    @test evaluate(FunctionExpr(:Sec, [NumberExpr(0)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Sec, [NumberExpr(π/3)])).value ≈ 2.0
    @test evaluate(FunctionExpr(:Csc, [NumberExpr(π/2)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Csc, [NumberExpr(π/6)])).value ≈ 2.0
end

@testset "Inverse trigonometric functions" begin
    @test evaluate(FunctionExpr(:Arcsin, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Arcsin, [NumberExpr(1)])).value ≈ π/2
    @test evaluate(FunctionExpr(:Arcsin, [NumberExpr(0.5)])).value ≈ π/6
    @test evaluate(FunctionExpr(:Arccos, [NumberExpr(1)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Arccos, [NumberExpr(0)])).value ≈ π/2
    @test evaluate(FunctionExpr(:Arccos, [NumberExpr(0.5)])).value ≈ π/3
    @test evaluate(FunctionExpr(:Arctan, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Arctan, [NumberExpr(1)])).value ≈ π/4
    @test evaluate(FunctionExpr(:Arccot, [NumberExpr(1)])).value ≈ π/4
    @test evaluate(FunctionExpr(:Arcsec, [NumberExpr(2)])).value ≈ π/3
    @test evaluate(FunctionExpr(:Arccsc, [NumberExpr(2)])).value ≈ π/6
end

@testset "Trig round-trip" begin
    # Arcsin(Sin(0.5)) ≈ 0.5
    expr = FunctionExpr(:Arcsin, [FunctionExpr(:Sin, [NumberExpr(0.5)])])
    @test evaluate(expr).value ≈ 0.5
end

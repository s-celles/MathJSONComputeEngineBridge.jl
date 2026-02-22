using MathJSON

@testset "Power operations" begin
    @test evaluate(FunctionExpr(:Power, [NumberExpr(2), NumberExpr(3)])).value == 8
    @test evaluate(FunctionExpr(:Power, [NumberExpr(2), NumberExpr(10)])).value == 1024
    @test evaluate(FunctionExpr(:Power, [NumberExpr(3), NumberExpr(0)])).value == 1
    @test evaluate(FunctionExpr(:Power, [NumberExpr(5), NumberExpr(-1)])).value ≈ 0.2
    @test evaluate(FunctionExpr(:Power, [NumberExpr(8), NumberExpr(0.5)])).value ≈ sqrt(8)
    @test evaluate(FunctionExpr(:Power, [NumberExpr(2.5), NumberExpr(2)])).value ≈ 6.25
end

@testset "Root operations" begin
    @test evaluate(FunctionExpr(:Root, [NumberExpr(27), NumberExpr(3)])).value ≈ 3.0
    @test evaluate(FunctionExpr(:Root, [NumberExpr(16), NumberExpr(4)])).value ≈ 2.0
    @test evaluate(FunctionExpr(:Root, [NumberExpr(9), NumberExpr(2)])).value ≈ 3.0
    @test evaluate(FunctionExpr(:Root, [NumberExpr(256), NumberExpr(8)])).value ≈ 2.0
end

@testset "Sqrt operations" begin
    @test evaluate(FunctionExpr(:Sqrt, [NumberExpr(9)])).value ≈ 3.0
    @test evaluate(FunctionExpr(:Sqrt, [NumberExpr(2)])).value ≈ sqrt(2)
    @test evaluate(FunctionExpr(:Sqrt, [NumberExpr(0)])).value == 0.0
    @test evaluate(FunctionExpr(:Sqrt, [NumberExpr(144)])).value ≈ 12.0
end

@testset "Square operations" begin
    @test evaluate(FunctionExpr(:Square, [NumberExpr(5)])).value == 25
    @test evaluate(FunctionExpr(:Square, [NumberExpr(-3)])).value == 9
    @test evaluate(FunctionExpr(:Square, [NumberExpr(0)])).value == 0
    @test evaluate(FunctionExpr(:Square, [NumberExpr(1.5)])).value ≈ 2.25
end

@testset "Abs operations" begin
    @test evaluate(FunctionExpr(:Abs, [NumberExpr(-7)])).value == 7
    @test evaluate(FunctionExpr(:Abs, [NumberExpr(7)])).value == 7
    @test evaluate(FunctionExpr(:Abs, [NumberExpr(0)])).value == 0
    @test evaluate(FunctionExpr(:Abs, [NumberExpr(-3.14)])).value ≈ 3.14
end

@testset "Power/Root nested" begin
    # Sqrt(Power(3, 2)) = Sqrt(9) = 3
    expr = FunctionExpr(:Sqrt, [FunctionExpr(:Power, [NumberExpr(3), NumberExpr(2)])])
    @test evaluate(expr).value ≈ 3.0
end

using MathJSON
using MathJSONComputeEngineBridge

@testset "Sinc (unnormalized sin(x)/x)" begin
    @test evaluate(FunctionExpr(:Sinc, [NumberExpr(0)])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Sinc, [NumberExpr(Float64(π))])).value ≈ 0.0 atol=1e-15
    @test evaluate(FunctionExpr(:Sinc, [NumberExpr(1)])).value ≈ sin(1) / 1
    @test evaluate(FunctionExpr(:Sinc, [NumberExpr(0.5)])).value ≈ sin(0.5) / 0.5
end

@testset "Haversine" begin
    @test evaluate(FunctionExpr(:Haversine, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:Haversine, [NumberExpr(Float64(π))])).value ≈ 1.0
    @test evaluate(FunctionExpr(:Haversine, [NumberExpr(π/2)])).value ≈ 0.5
end

@testset "InverseHaversine" begin
    @test evaluate(FunctionExpr(:InverseHaversine, [NumberExpr(0)])).value ≈ 0.0
    @test evaluate(FunctionExpr(:InverseHaversine, [NumberExpr(1)])).value ≈ π
    @test evaluate(FunctionExpr(:InverseHaversine, [NumberExpr(0.5)])).value ≈ π/2
end

@testset "Hypot" begin
    @test evaluate(FunctionExpr(:Hypot, [NumberExpr(3), NumberExpr(4)])).value ≈ 5.0
    @test evaluate(FunctionExpr(:Hypot, [NumberExpr(5), NumberExpr(12)])).value ≈ 13.0
    @test evaluate(FunctionExpr(:Hypot, [NumberExpr(0), NumberExpr(7)])).value ≈ 7.0
end

@testset "Haversine/InverseHaversine round-trip" begin
    expr = FunctionExpr(:InverseHaversine, [FunctionExpr(:Haversine, [NumberExpr(1.0)])])
    @test evaluate(expr).value ≈ 1.0
end

@testset "InverseFunction meta-operator" begin
    # InverseFunction("Sin", x) == Arcsin(x)
    inv_expr = FunctionExpr(:InverseFunction, [SymbolExpr("Sin"), NumberExpr(0.5)])
    arc_expr = FunctionExpr(:Arcsin, [NumberExpr(0.5)])
    @test evaluate(inv_expr).value ≈ evaluate(arc_expr).value

    # InverseFunction("Cos", x) == Arccos(x)
    inv_expr = FunctionExpr(:InverseFunction, [SymbolExpr("Cos"), NumberExpr(0.5)])
    arc_expr = FunctionExpr(:Arccos, [NumberExpr(0.5)])
    @test evaluate(inv_expr).value ≈ evaluate(arc_expr).value

    # InverseFunction("Tan", x) == Arctan(x)
    inv_expr = FunctionExpr(:InverseFunction, [SymbolExpr("Tan"), NumberExpr(1)])
    arc_expr = FunctionExpr(:Arctan, [NumberExpr(1)])
    @test evaluate(inv_expr).value ≈ evaluate(arc_expr).value

    # InverseFunction("Exp", x) == Ln(x)
    inv_expr = FunctionExpr(:InverseFunction, [SymbolExpr("Exp"), NumberExpr(2.0)])
    ln_expr = FunctionExpr(:Ln, [NumberExpr(2.0)])
    @test evaluate(inv_expr).value ≈ evaluate(ln_expr).value

    # InverseFunction("Sinh", x) == Arsinh(x)
    inv_expr = FunctionExpr(:InverseFunction, [SymbolExpr("Sinh"), NumberExpr(1)])
    arc_expr = FunctionExpr(:Arsinh, [NumberExpr(1)])
    @test evaluate(inv_expr).value ≈ evaluate(arc_expr).value

    # InverseFunction("Cosh", x) == Arcosh(x)
    inv_expr = FunctionExpr(:InverseFunction, [SymbolExpr("Cosh"), NumberExpr(2)])
    arc_expr = FunctionExpr(:Arcosh, [NumberExpr(2)])
    @test evaluate(inv_expr).value ≈ evaluate(arc_expr).value
end

@testset "InverseFunction unknown function throws error" begin
    @test_throws UnsupportedOperationError evaluate(
        FunctionExpr(:InverseFunction, [SymbolExpr("Unknown"), NumberExpr(1)])
    )
end

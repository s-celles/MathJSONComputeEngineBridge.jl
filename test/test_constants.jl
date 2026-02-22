using MathJSON
using MathJSONComputeEngineBridge

@testset "Mathematical constants" begin
    @test evaluate(SymbolExpr("Pi")).value ≈ π
    @test evaluate(SymbolExpr("ExponentialE")).value ≈ ℯ
end

@testset "Constants in compound expressions" begin
    # Multiply(Pi, 2) = 2π
    @test evaluate(FunctionExpr(:Multiply, [SymbolExpr("Pi"), NumberExpr(2)])).value ≈ 2π
    # Add(ExponentialE, 1) = ℯ + 1
    @test evaluate(FunctionExpr(:Add, [SymbolExpr("ExponentialE"), NumberExpr(1)])).value ≈ ℯ + 1
    # Sin(Pi) ≈ 0
    @test evaluate(FunctionExpr(:Sin, [SymbolExpr("Pi")])).value ≈ 0.0 atol=1e-15
    # Exp(1) ≈ ℯ (via constant)
    @test evaluate(FunctionExpr(:Ln, [SymbolExpr("ExponentialE")])).value ≈ 1.0
end

@testset "Unknown symbol throws UnresolvedSymbolError" begin
    @test_throws UnresolvedSymbolError evaluate(SymbolExpr("UnknownSymbol"))
end

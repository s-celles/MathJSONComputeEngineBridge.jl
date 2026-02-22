using MathJSON
using MathJSONComputeEngineBridge

@testset "Factorial" begin
    @test evaluate(FunctionExpr(:Factorial, [NumberExpr(0)])).value == 1
    @test evaluate(FunctionExpr(:Factorial, [NumberExpr(5)])).value == 120
    @test evaluate(FunctionExpr(:Factorial, [NumberExpr(10)])).value == 3628800
end

@testset "Binomial" begin
    @test evaluate(FunctionExpr(:Binomial, [NumberExpr(5), NumberExpr(2)])).value == 10
    @test evaluate(FunctionExpr(:Binomial, [NumberExpr(10), NumberExpr(3)])).value == 120
    @test evaluate(FunctionExpr(:Binomial, [NumberExpr(6), NumberExpr(0)])).value == 1
    @test evaluate(FunctionExpr(:Binomial, [NumberExpr(6), NumberExpr(6)])).value == 1
end

@testset "GCD" begin
    @test evaluate(FunctionExpr(:GCD, [NumberExpr(12), NumberExpr(8)])).value == 4
    @test evaluate(FunctionExpr(:GCD, [NumberExpr(48), NumberExpr(18)])).value == 6
    @test evaluate(FunctionExpr(:GCD, [NumberExpr(7), NumberExpr(13)])).value == 1
end

@testset "LCM" begin
    @test evaluate(FunctionExpr(:LCM, [NumberExpr(4), NumberExpr(6)])).value == 12
    @test evaluate(FunctionExpr(:LCM, [NumberExpr(3), NumberExpr(5)])).value == 15
    @test evaluate(FunctionExpr(:LCM, [NumberExpr(7), NumberExpr(7)])).value == 7
end

@testset "Mod" begin
    @test evaluate(FunctionExpr(:Mod, [NumberExpr(10), NumberExpr(3)])).value == 1
    @test evaluate(FunctionExpr(:Mod, [NumberExpr(7), NumberExpr(2)])).value == 1
    @test evaluate(FunctionExpr(:Mod, [NumberExpr(9), NumberExpr(3)])).value == 0
end

@testset "IsPrime" begin
    @test evaluate(FunctionExpr(:IsPrime, [NumberExpr(7)])) == SymbolExpr("True")
    @test evaluate(FunctionExpr(:IsPrime, [NumberExpr(2)])) == SymbolExpr("True")
    @test evaluate(FunctionExpr(:IsPrime, [NumberExpr(13)])) == SymbolExpr("True")
    @test evaluate(FunctionExpr(:IsPrime, [NumberExpr(4)])) == SymbolExpr("False")
    @test evaluate(FunctionExpr(:IsPrime, [NumberExpr(1)])) == SymbolExpr("False")
    @test evaluate(FunctionExpr(:IsPrime, [NumberExpr(0)])) == SymbolExpr("False")
end

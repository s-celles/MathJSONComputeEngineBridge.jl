using MathJSONComputeEngineBridge
using MathJSON
using Test

@testset "default_backend" begin
    @test default_backend() isa JuliaBackend
end

@testset "set_default_backend!" begin
    original = default_backend()
    new_backend = JuliaBackend()
    result = set_default_backend!(new_backend)
    @test result === new_backend
    @test default_backend() === new_backend
    # Reset to original
    set_default_backend!(original)
end

@testset "explicit backend keyword" begin
    expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), NumberExpr(2)])
    result = evaluate(expr; backend=JuliaBackend())
    @test result isa NumberExpr
    @test result.value == 3
end

@testset "evaluate uses default_backend" begin
    expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(10), NumberExpr(20)])
    result = evaluate(expr)
    @test result isa NumberExpr
    @test result.value == 30
end

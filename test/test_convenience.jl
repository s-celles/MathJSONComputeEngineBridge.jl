using MathJSON

@testset "Convenience methods" begin
    @testset "evaluate(String)" begin
        @test evaluate("""["Add", 1, 2]""") == NumberExpr(3)
        @test evaluate("""["Multiply", 3, 4]""") == NumberExpr(12)
    end

    @testset "to_giac fallback (no Giac loaded)" begin
        @test_throws ErrorException("to_giac requires Giac.jl. Run `using Giac` to activate it.") to_giac(NumberExpr(1))
        @test_throws ErrorException("to_giac requires Giac.jl. Run `using Giac` to activate it.") to_giac("""["Add", 1, 2]""")
    end
end

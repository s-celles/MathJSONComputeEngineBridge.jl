using Test
using MathJSON
using MathJSONComputeEngineBridge
using Symbolics

@testset "SymbolicsBackend Symbolic Matrix Operations (US5)" begin
    backend = SymbolicsBackend()

    @testset "Symbolic determinant 2x2: det([[a,b],[c,d]]) = ad - bc" begin
        expr = FunctionExpr(:Determinant, [
            FunctionExpr(:Matrix, [
                FunctionExpr(:List, [SymbolExpr("a"), SymbolExpr("b")]),
                FunctionExpr(:List, [SymbolExpr("c"), SymbolExpr("d")])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        result_str = string(result)
        @test occursin("a", result_str)
        @test occursin("d", result_str)
        @test occursin("b", result_str)
        @test occursin("c", result_str)
    end

    @testset "Numeric determinant 2x2" begin
        # det([[1,2],[3,4]]) = 1*4 - 2*3 = -2
        expr = FunctionExpr(:Determinant, [
            FunctionExpr(:Matrix, [
                FunctionExpr(:List, [NumberExpr(1), NumberExpr(2)]),
                FunctionExpr(:List, [NumberExpr(3), NumberExpr(4)])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value ≈ -2
    end

    @testset "Symbolic transpose 2x2" begin
        expr = FunctionExpr(:Transpose, [
            FunctionExpr(:Matrix, [
                FunctionExpr(:List, [SymbolExpr("a"), SymbolExpr("b")]),
                FunctionExpr(:List, [SymbolExpr("c"), SymbolExpr("d")])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
        # Transposed: [[a,c],[b,d]]
        # First row should contain a and c
        row1 = result.arguments[1]
        @test row1 isa FunctionExpr
        row1_str = string(row1)
        @test occursin("a", row1_str)
        @test occursin("c", row1_str)
    end

    @testset "Numeric transpose" begin
        expr = FunctionExpr(:Transpose, [
            FunctionExpr(:Matrix, [
                FunctionExpr(:List, [NumberExpr(1), NumberExpr(2)]),
                FunctionExpr(:List, [NumberExpr(3), NumberExpr(4)])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
    end

    @testset "Symbolic inverse 2x2" begin
        expr = FunctionExpr(:Inverse, [
            FunctionExpr(:Matrix, [
                FunctionExpr(:List, [SymbolExpr("a"), SymbolExpr("b")]),
                FunctionExpr(:List, [SymbolExpr("c"), SymbolExpr("d")])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
        result_str = string(result)
        @test occursin("a", result_str)
        @test occursin("d", result_str)
    end

    @testset "Numeric inverse 2x2" begin
        # inv([[2,1],[1,1]]) = [[1,-1],[-1,2]]
        expr = FunctionExpr(:Inverse, [
            FunctionExpr(:Matrix, [
                FunctionExpr(:List, [NumberExpr(2), NumberExpr(1)]),
                FunctionExpr(:List, [NumberExpr(1), NumberExpr(1)])
            ])
        ])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
    end
end

@testset "GiacBackend Symbolic Matrix Operations (US6)" begin
    backend = GiacBackend()

    # Helper: 2x2 symbolic matrix [[a,b],[c,d]]
    sym_mat = FunctionExpr(:Matrix, [
        FunctionExpr(:List, [SymbolExpr("a"), SymbolExpr("b")]),
        FunctionExpr(:List, [SymbolExpr("c"), SymbolExpr("d")])
    ])

    @testset "Determinant of symbolic 2x2 = a*d - b*c" begin
        expr = FunctionExpr(:Determinant, [sym_mat])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        # Result should be Add(Multiply(a,d), Subtract(Multiply(b,c))) or similar
        @test result.operator == :Add || result.operator == :Subtract
    end

    @testset "Transpose of symbolic matrix" begin
        expr = FunctionExpr(:Transpose, [sym_mat])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
        # Transposed matrix should have 2 rows
        @test length(result.arguments) == 2
        # First row should be [a, c] (columns become rows)
        first_row = result.arguments[1]
        @test first_row isa FunctionExpr
        @test first_row.operator == :List
        @test first_row.arguments[1] isa SymbolExpr
        @test first_row.arguments[1].name == "a"
        @test first_row.arguments[2] isa SymbolExpr
        @test first_row.arguments[2].name == "c"
    end

    @testset "Inverse of symbolic matrix" begin
        expr = FunctionExpr(:Inverse, [sym_mat])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
        # 2x2 inverse should still be 2x2
        @test length(result.arguments) == 2
    end

    @testset "Determinant of numeric 2x2 matrix" begin
        # [[1,2],[3,4]] → det = 1*4 - 2*3 = -2
        num_mat = FunctionExpr(:Matrix, [
            FunctionExpr(:List, [NumberExpr(1), NumberExpr(2)]),
            FunctionExpr(:List, [NumberExpr(3), NumberExpr(4)])
        ])
        expr = FunctionExpr(:Determinant, [num_mat])
        result = evaluate(expr; backend=backend)
        @test result isa NumberExpr
        @test result.value == -2
    end

    @testset "Transpose of numeric matrix" begin
        num_mat = FunctionExpr(:Matrix, [
            FunctionExpr(:List, [NumberExpr(1), NumberExpr(2)]),
            FunctionExpr(:List, [NumberExpr(3), NumberExpr(4)])
        ])
        expr = FunctionExpr(:Transpose, [num_mat])
        result = evaluate(expr; backend=backend)
        @test result isa FunctionExpr
        @test result.operator == :Matrix
        # [[1,3],[2,4]]
        first_row = result.arguments[1]
        @test first_row.arguments[1] isa NumberExpr
        @test first_row.arguments[1].value == 1
        @test first_row.arguments[2] isa NumberExpr
        @test first_row.arguments[2].value == 3
    end
end

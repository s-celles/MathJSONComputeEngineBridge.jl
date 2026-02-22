using MathJSON
using MathJSONComputeEngineBridge

# Helper to build a MathJSON matrix from a Julia matrix
function mathjson_matrix(m::AbstractMatrix)
    rows = [FunctionExpr(:List, [NumberExpr(m[i, j]) for j in 1:size(m, 2)]) for i in 1:size(m, 1)]
    return FunctionExpr(:Matrix, rows)
end

# Helper to extract Julia matrix from a MathJSON matrix result
function extract_matrix(expr::FunctionExpr)
    return [expr.arguments[i].arguments[j].value for i in 1:length(expr.arguments), j in 1:length(expr.arguments[1].arguments)]
end

@testset "Determinant" begin
    # 2x2: det([1 2; 3 4]) = -2
    m = mathjson_matrix([1.0 2.0; 3.0 4.0])
    @test evaluate(FunctionExpr(:Determinant, [m])).value ≈ -2.0

    # 3x3: det([1 2 3; 4 5 6; 7 8 10]) = -3
    m = mathjson_matrix([1.0 2.0 3.0; 4.0 5.0 6.0; 7.0 8.0 10.0])
    @test evaluate(FunctionExpr(:Determinant, [m])).value ≈ -3.0

    # Singular matrix: det([1 2; 2 4]) = 0
    m = mathjson_matrix([1.0 2.0; 2.0 4.0])
    @test evaluate(FunctionExpr(:Determinant, [m])).value ≈ 0.0 atol=1e-14
end

@testset "Transpose" begin
    # 2x2 transpose
    m = mathjson_matrix([1.0 2.0; 3.0 4.0])
    result = evaluate(FunctionExpr(:Transpose, [m]))
    r = extract_matrix(result)
    @test r ≈ [1.0 3.0; 2.0 4.0]

    # 2x3 → 3x2 transpose
    m = mathjson_matrix([1.0 2.0 3.0; 4.0 5.0 6.0])
    result = evaluate(FunctionExpr(:Transpose, [m]))
    r = extract_matrix(result)
    @test r ≈ [1.0 4.0; 2.0 5.0; 3.0 6.0]
end

@testset "Inverse" begin
    # Diagonal matrix inverse: inv([2 0; 0 4]) = [0.5 0; 0 0.25]
    m = mathjson_matrix([2.0 0.0; 0.0 4.0])
    result = evaluate(FunctionExpr(:Inverse, [m]))
    r = extract_matrix(result)
    @test r ≈ [0.5 0.0; 0.0 0.25]

    # 2x2 inverse: inv([1 2; 3 4]) = [-2 1; 1.5 -0.5]
    m = mathjson_matrix([1.0 2.0; 3.0 4.0])
    result = evaluate(FunctionExpr(:Inverse, [m]))
    r = extract_matrix(result)
    @test r ≈ [-2.0 1.0; 1.5 -0.5]
end

@testset "List passthrough" begin
    # List should recursively evaluate its elements
    list_expr = FunctionExpr(:List, [
        FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)]),
        NumberExpr(3),
        FunctionExpr(:Multiply, [NumberExpr(2), NumberExpr(5)])
    ])
    result = evaluate(list_expr)
    @test result.operator == :List
    @test result.arguments[1].value == 3
    @test result.arguments[2].value == 3
    @test result.arguments[3].value == 10
end

@testset "Matrix passthrough" begin
    # Matrix with expressions should recursively evaluate
    m = FunctionExpr(:Matrix, [
        FunctionExpr(:List, [FunctionExpr(:Add, [NumberExpr(1), NumberExpr(1)]), NumberExpr(0)]),
        FunctionExpr(:List, [NumberExpr(0), FunctionExpr(:Multiply, [NumberExpr(3), NumberExpr(3)])])
    ])
    result = evaluate(m)
    r = extract_matrix(result)
    @test r ≈ [2.0 0.0; 0.0 9.0]
end

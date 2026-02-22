using MathJSONComputeEngineBridge
using MathJSON
using Test

@testset "UnsupportedOperationError" begin
    @testset "symbolic op raises error with suggestions" begin
        expr = FunctionExpr(:Factor, AbstractMathJSONExpr[NumberExpr(42)])
        err = try
            evaluate(expr)
            nothing
        catch e
            e
        end
        @test err isa UnsupportedOperationError
        @test err.operation == :Factor
        @test err.backend isa JuliaBackend
        @test "GiacBackend" in err.suggested_backends
        @test "SymbolicsBackend" in err.suggested_backends
    end

    @testset "Integrate raises UnsupportedOperationError" begin
        expr = FunctionExpr(:Integrate, AbstractMathJSONExpr[NumberExpr(1)])
        @test_throws UnsupportedOperationError evaluate(expr)
    end

    @testset "error message contains op and backend name" begin
        expr = FunctionExpr(:Factor, AbstractMathJSONExpr[NumberExpr(1)])
        err = try
            evaluate(expr)
            nothing
        catch e
            e
        end
        msg = sprint(showerror, err)
        @test occursin("Factor", msg)
        @test occursin("JuliaBackend", msg)
        @test occursin("GiacBackend", msg)
    end

    @testset "unknown op (not symbolic) has empty suggestions" begin
        expr = FunctionExpr(:Frobnicate, AbstractMathJSONExpr[NumberExpr(1)])
        err = try
            evaluate(expr)
            nothing
        catch e
            e
        end
        @test err isa UnsupportedOperationError
        @test err.operation == :Frobnicate
        @test isempty(err.suggested_backends)
    end
end

@testset "UnresolvedSymbolError" begin
    @testset "symbol raises error" begin
        expr = SymbolExpr("x")
        err = try
            evaluate(expr)
            nothing
        catch e
            e
        end
        @test err isa UnresolvedSymbolError
        @test "x" in err.symbols
    end

    @testset "symbol in expression raises error" begin
        inner = SymbolExpr("y")
        expr = FunctionExpr(:Add, AbstractMathJSONExpr[NumberExpr(1), inner])
        @test_throws UnresolvedSymbolError evaluate(expr)
    end

    @testset "error message contains symbol name" begin
        expr = SymbolExpr("myvar")
        err = try
            evaluate(expr)
            nothing
        catch e
            e
        end
        msg = sprint(showerror, err)
        @test occursin("myvar", msg)
        @test occursin("symbolic backend", msg)
    end
end

@testset "SymbolicsBackend without Symbolics loaded" begin
    # These tests run in the main test process BEFORE Symbolics is loaded,
    # so they test the fallback compute methods in evaluate.jl.
    # Note: runtests.jl loads Symbolics later in a conditional block,
    # so we need a separate process to test this properly.
    code = """
    using MathJSON
    using MathJSONComputeEngineBridge
    using Test

    @testset "SymbolicsBackend error fallbacks" begin
        backend = SymbolicsBackend()

        @testset "NumberExpr raises error mentioning Symbolics" begin
            err = try
                compute(backend, NumberExpr(1))
                nothing
            catch e
                e
            end
            @test err isa ErrorException
            @test occursin("Symbolics", err.msg)
        end

        @testset "SymbolExpr raises error mentioning Symbolics" begin
            err = try
                compute(backend, SymbolExpr("x"))
                nothing
            catch e
                e
            end
            @test err isa ErrorException
            @test occursin("Symbolics", err.msg)
        end

        @testset "FunctionExpr raises error mentioning Symbolics" begin
            err = try
                compute(backend, FunctionExpr(:Add, [NumberExpr(1), NumberExpr(2)]))
                nothing
            catch e
                e
            end
            @test err isa ErrorException
            @test occursin("Symbolics", err.msg)
        end
    end
    """
    # Run in a separate process without Symbolics
    cmd = `$(Base.julia_cmd()) --project -e $code`
    result = run(cmd; wait=true)
    @test result.exitcode == 0
end

@testset "Edge cases" begin
    @testset "empty arguments raises ArgumentError" begin
        expr = FunctionExpr(:Add, AbstractMathJSONExpr[])
        @test_throws ArgumentError evaluate(expr)
    end

    @testset "unknown operator raises UnsupportedOperationError" begin
        expr = FunctionExpr(:Frobnicate, AbstractMathJSONExpr[NumberExpr(1)])
        @test_throws UnsupportedOperationError evaluate(expr)
    end
end

const JULIA_OPS = Dict{Symbol,Function}(
    :Add => +,
    :Subtract => -,
    :Multiply => *,
    :Divide => /,
    :Negate => -,
)

const SYMBOLIC_OPS = Set{Symbol}([
    :Factor, :Expand, :Simplify, :Solve,
    :Integrate, :D, :Limit, :PartialFractions,
    :Sum, :Product, :Laplace, :InverseLaplace,
    :ZTransform, :InverseZTransform,
])

function compute(backend::JuliaBackend, expr::NumberExpr)
    return expr
end

function compute(backend::JuliaBackend, expr::SymbolExpr)
    throw(UnresolvedSymbolError([expr.name]))
end

function compute(backend::JuliaBackend, expr::FunctionExpr)
    op = expr.operator
    args = expr.arguments

    if isempty(args)
        throw(ArgumentError("Empty arguments for operator '$op'"))
    end

    if !haskey(JULIA_OPS, op)
        suggested = if op in SYMBOLIC_OPS
            ["GiacBackend", "SymbolicsBackend"]
        else
            String[]
        end
        throw(UnsupportedOperationError(op, backend, suggested))
    end

    evaluated = [compute(backend, arg) for arg in args]

    # Collect any unresolved symbols from recursive evaluation
    # (handled by SymbolExpr method above)

    values = [e.value for e in evaluated]
    f = JULIA_OPS[op]

    result = if op == :Negate
        f(values[1])
    elseif length(values) == 2
        f(values[1], values[2])
    else
        # Variadic: Add(1,2,3) = 1+2+3
        reduce(f, values)
    end

    return NumberExpr(result)
end

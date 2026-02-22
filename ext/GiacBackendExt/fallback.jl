# Fallback mechanism for unmapped operators
# Attempts invoke_cmd with lowercase operator name for any Giac command

"""
    giac_fallback(op::Symbol, args::Vector{<:AbstractMathJSONExpr}) -> GiacExpr

Attempt to invoke a Giac command by lowercasing the MathJSON operator name.
This provides access to all ~2200 Giac commands without explicit mapping.

Throws UnsupportedOperationError if the command fails.
"""
function giac_fallback(op::Symbol, args::Vector{<:AbstractMathJSONExpr})
    giac_cmd_name = Symbol(lowercase(string(op)))
    giac_args = [convert_to_giac(arg) for arg in args]
    try
        return Giac.invoke_cmd(giac_cmd_name, giac_args...)
    catch e
        if e isa Giac.GiacError
            throw(MathJSONComputeEngineBridge.UnsupportedOperationError(
                op, MathJSONComputeEngineBridge.GiacBackend(), String[]))
        end
        rethrow()
    end
end

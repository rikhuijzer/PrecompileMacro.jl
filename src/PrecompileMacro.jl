module PrecompileMacro

export @precompile

function _precompile(func::Expr)
    func_signature = func.args[1]::Expr
    func_signature.head == :where && error("PrecompileMacro.@precompile is not implemented for methods with type parameters")

    signature_args = func_signature.args::Vector{Any}
    func_name = signature_args[1]::Symbol

    # Drop function name and kwargs.
    args = convert(Vector{Expr}, filter(x -> x isa Expr && x.head != :parameters, signature_args))
    types = Tuple(eval(last(arg.args))::DataType for arg in args)
    for type in types
        if !isconcretetype(type)
            error("The type $type in the signature $(func_name)$(types) is not concrete")
        end
    end

    precompile_ex = :(precompile($func_name, $types))

    # Note that `precompile` returns a boolean to indicate whether a statement is active.
    # Might be useful at some point.
    return esc(quote
        Base.@__doc__($func)
        $precompile_ex
    end)
end
precompile(_precompile, (Expr,))

"""
    @precompile(func)

Define function `func` and define a precompile statement for `func`, see `precompile` for more info.
Return whether a precompile statement is active.
"""
macro precompile(func)
    return _precompile(func)
end

end # module

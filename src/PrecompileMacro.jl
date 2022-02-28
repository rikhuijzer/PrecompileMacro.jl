module PrecompileMacro

export @precompile

function _precompile(func::Expr)
    func.args[1].head == :where && error("@precompile is not implemented for methods with type parameters")

    sig = func.args[1].args
    func_name = sig[1]::Symbol
    # Drop function name and kwargs.
    args = filter(x -> x isa Expr && x.head != :parameters, sig)
    types = Tuple(eval(last(arg.args)) for arg in args)
    if !all(isconcretetype.(types))
        nonconcrete = filter(!isconcretetype, types)
        multiple = 1 < length(nonconcrete)
        msg = "The type$(multiple ? 's' : "") $nonconcrete in the signature $(func_name)$(types) $(multiple ? "are" : "is") not concrete."
        error(msg)
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

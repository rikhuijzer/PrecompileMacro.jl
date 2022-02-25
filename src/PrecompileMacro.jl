module PrecompileMacro

using MacroTools: combinedef, splitarg, splitdef

export @precompile

"""
Return tuple of types which can be passed as `args` into `precompile(f, args)`.
"""
function _types_tuple(def_dict)::Tuple{Vararg{Any}}
    splitted = map(splitarg, def_dict[:args])
    typesyms = Tuple(tup[2] for tup in splitted)::Tuple{Vararg{Symbol}}
    # Convert, for example, `(:String, :Int)` to `(String, Int)`.
    types = eval.(typesyms)
    if !all(isconcretetype.(collect(types)))
        nonconcrete = filter(!isconcretetype, types)
        mult = 1 < length(nonconcrete)
        msg = "The type$(mult ? 's' : "") $nonconcrete in the signature $types $(mult ? "are" : "is") not concrete."
        error(msg)
    end
    return types
end

"""
    @precompile(func)

Define function `func` and define a precompile statement for `func`, see `precompile` for more info.
Return whether a precompile statement is active.
"""
macro precompile(func)
    def_dict = try
        splitdef(func)
    catch
        error("@precompile must be applied to a method definition")
    end

    name = def_dict[:name]
    precompile_args = _types_tuple(def_dict)
    precompile_ex = :(precompile($name, $precompile_args))

    # Note that `precompile` returns a boolean to indicate whether a statement is active.
    # Might be useful at some point.
    return esc(quote
        Base.@__doc__($func)
        $precompile_ex
    end)
end

end # module

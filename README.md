# PrecompileMacro.jl

A `@precompile` decorator to trigger precompilation.

## Installation

```julia
pkg> add PrecompileMacro
```

## Usage

Given a function with concrete type parameters, such as

```julia
function run_application(path::String, id::Int)
    do_something(path, id)
end
```

This package defines a `@precompile` macro (function decorator) which can be used as follows:

```julia
using PrecompileMacro: @precompile

@precompile function run_application(path::String, id::Int)
    do_something(path, id)
end
```

This macro is the same as writing

```julia
function run_application(path::String, id::Int)
    do_something(path)
end
precompile(run_application, (String, Int))
```

## Concrete types

A concrete type is a type which can have a direct instance.
For example, a `String` is conrete and an `AbstractString` is not:

```julia
julia> isconcretetype(String)
true

julia> isconcretetype(AbstractString)
false
```

Other examples of concrete types are `Int`, `Float64` and `Vector{String}`.
Other examples of non-concrete types are `Number` and `Real`.

## About

This package defines a convenient macro around the `precompile` function from Julia base.
The `precompile` function compiles a given function without executing it which can be very beneficial for the time to first X for certain applications.
**However**, do note that there is a tradeoff between setting concrete types and abstract types or no types in the function signature.
Having more loose types allows for people to pass in their own objects which, in turn, has great benefits in terms of composability.
In other words, less type restrictions on functions mean that more packages can work together to do great things.

Having said that, there are certain cases where concrete types are okay.
For example, when creating applications such as a web framework or notebook environment, or when a method is for internal use only.

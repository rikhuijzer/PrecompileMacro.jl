using MethodAnalysis: methodinstances
using PrecompileMacro
using Test

@testset "PrecompileMacro" begin
    @precompile g(path::String, id::Int) = string(path, id)

    # Verify that one methodinstance is ready even though we didn't call the function yet.
    @test length(methodinstances(g)) == 1

    # To be sure that the method works.
    @test g("lorem", 1) == "lorem1"

    @precompile h(a::Int, b::Int; c=3) = string(a, b, c)
    @test length(methodinstances(h)) == 1

    @test_throws LoadError eval(:(@precompile f(path::AbstractString) = 1))

    "Some doc"
    @precompile k() = 3
    @test length(methodinstances(k)) == 1
    @test contains(string(@doc k), "Some doc")
end

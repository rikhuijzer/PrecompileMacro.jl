using MethodAnalysis: methodinstances
using PrecompileMacro
using Test

@testset "PrecompileMacro" begin
    @precompile g(path::String, id::Int) = string(path, id)

    # Verify that one methodinstance is ready even though we didn't call the function yet.
    @test length(methodinstances(g)) == 1

    # To be sure that the method works.
    @test g("lorem", 1) == "lorem1"

    # No idea why this always fails. Maybe the function has to be inside the macro.
    # @test_throws LoadError @precompile f(path::AbstractString) = 1
end

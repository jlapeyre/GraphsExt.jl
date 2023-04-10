using GraphsExt
using Aqua: Aqua

@testset "aqua deps compat" begin
    Aqua.test_deps_compat(GraphsExt)
end

# This often gives false positive
@testset "aqua project toml formatting" begin
    Aqua.test_project_toml_formatting(GraphsExt)
end

@testset "aqua unbound_args" begin
    Aqua.test_unbound_args(GraphsExt)
end

@testset "aqua undefined exports" begin
    Aqua.test_undefined_exports(GraphsExt)
end

# Perhaps some of these should be fixed. Some are for combinations of types
# that make no sense.
@testset "aqua test ambiguities" begin
    Aqua.test_ambiguities([GraphsExt, Core, Base])
end

@testset "aqua piracy" begin
    Aqua.test_piracy(GraphsExt)
end

@testset "aqua project extras" begin
    Aqua.test_project_extras(GraphsExt)
end

@testset "aqua state deps" begin
    Aqua.test_stale_deps(GraphsExt)
end

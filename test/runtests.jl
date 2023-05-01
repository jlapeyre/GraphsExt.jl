using GraphsExt
using Graphs
using Test

@testset "remove_vertices!" begin
    g = path_graph(10)
    vmap = remove_vertices!(g, [3, 4, 5])
    remove_vertices!(g, [6, 7, 8], vmap)
    @test collect(edges(g)) == [Edge(1, 2), Edge(3, 4)]
    g = path_graph(10)
    remove_vertices!(g, [3, 4, 5])
    remove_vertices!(g, [6, 7, 8])
    # Incorrect result as expected. Better would be to throw exception
    @test collect(edges(g)) == [Edge(1, 2), Edge(3, 4), Edge(4, 5)]
end

if VERSION > v"1.7"
    include("jet_test.jl")
end
include("aqua_test.jl")
include("dag_longest_path_test.jl")

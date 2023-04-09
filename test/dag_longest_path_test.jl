using Graphs.SimpleGraphs: DiGraph
using Graphs: add_vertices!, add_edge!, topological_sort

# path graph
function testdag(nvert=10)
    g = DiGraph()
    add_vertices!(g, nvert)
    for i in 1:nvert-1
        add_edge!(g, i, i+1)
    end
    for i in 1:nvert-2
        add_edge!(g, i, i+2)
    end
    for i in 1:nvert-3
        add_edge!(g, i, i+3)
    end
    for i in 1:nvert-4
        add_edge!(g, i, i+4)
    end
    return g
end

# Right to left
function testdag2(nvert=10)
    g = DiGraph()
    add_vertices!(g, nvert)
    for i in 1:nvert-1
        add_edge!(g, i+1, i)
    end
    for i in 1:nvert-2
        add_edge!(g, i+2, i)
    end
    for i in 1:nvert-3
        add_edge!(g, i+3, i)
    end
    for i in 1:nvert-4
        add_edge!(g, i+4, i)
    end
    return g
end

# Multiple longest paths
function testdag3(nvert=12)
    g = DiGraph()
    add_vertices!(g, nvert)
    # add_edge!(g, 1, 2)
    # add_edge!(g, 1, 3)
    _nvert = nvert - 2
    for i in 1:_nvert-1
        add_edge!(g, i, i+1)
    end
    add_edge!(g, _nvert, _nvert + 1)
    add_edge!(g, _nvert, _nvert + 2)
    return g
end

@testset "dag_longest_path" begin
    @test dag_longest_path(testdag(10)) == 1:10
    @test dag_longest_path(testdag2(10)) == 10:-1:1
    @test dag_longest_path(testdag(6)) == 1:6
    @test dag_longest_path(testdag2(6)) == 6:-1:1
end

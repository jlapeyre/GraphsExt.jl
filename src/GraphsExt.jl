module GraphsExt

using Graphs: Graphs, AbstractGraph,  rem_edge!, add_edge!, topological_sort,
    inneighbors, outneighbors, edgetype
using Graphs.SimpleGraphs: AbstractSimpleGraph, DiGraph, SimpleDiGraph
using Dictionaries: Dictionary

export split_edge!, EdgesOrdered, edges_topological, dag_longest_path, remove_vertices!

include("remove_vertices.jl")
using .RemoveVertices: RemoveVertices, remove_vertices!

RemoveVertices.index_type(::SimpleDiGraph{IntT}) where {IntT} = IntT
RemoveVertices.num_vertices(g::AbstractGraph) = Graphs.nv(g)

"""
    split_edge!(g, vfrom, vto, vmid)

Remove edge `vfrom -> vto` and replace with two edges `vfrom  -> vmid -> vto`.

Remove the edge `(vfrom, vto)` and replace with two edges, `(vfrom, vmid)`
and `(vmid, vto)`.
"""
function split_edge!(
    g::AbstractGraph, vfrom::Integer, vto::Integer, vmid::Integer
)
    rem_edge!(g, vfrom, vto)
    add_edge!(g, vfrom, vmid)
    add_edge!(g, vmid, vto)
    return nothing
end

###
### EdgesOrdered
###

struct EdgesOrdered{Order,GT,VT}
    graph::GT
    verts::VT
end

EdgesOrdered(graph, verts) = EdgesOrdered{nothing,typeof(graph),typeof(verts)}(graph, verts)

"""
    EdgesOrdered([order=nothing], graph, verts)

An iterator of edges in `graph` ordered such that the first vertex in the edges appears
in the order given by `verts`, which must be a permutation of the vertex indices.

The parameter `order` is a label to identify and dispatch on a particular order. For example,
topological.

Note: This should probably be restricted to graphs that support the assumptions made in the
implementation.
"""
function EdgesOrdered(order, graph, verts)
    return EdgesOrdered{order,typeof(graph),typeof(verts)}(graph, verts)
end

function Base.show(io::IO, eos::EdgesOrdered{GT,VT,Order}) where {GT,VT,Order}
    if isnothing(Order)
        print(
            io,
            "EdgesOrdered{$GT, $VT}(nv=$(Graphs.nv(eos.graph)), ne=$(Graphs.ne(eos.graph)))",
        )
    else
        print(
            io,
            "EdgesOrdered{$GT, $VT, $Order}(nv=$(Graphs.nv(eos.graph)), ne=$(Graphs.ne(eos.graph)))",
        )
    end
end

Base.IteratorSize(et::Type{<:EdgesOrdered}) = Base.HasLength()
Base.length(et::EdgesOrdered) = Graphs.ne(et.graph)

function Base.iterate(et::EdgesOrdered, (i, j)=(1, 1))
    overts = outneighbors(et.graph, et.verts[i])
    while j > length(overts)
        j = 1
        i += 1
        i > length(et.verts) && return nothing
        overts = outneighbors(et.graph, et.verts[i])
    end
    return (edgetype(et.graph)(et.verts[i], overts[j]), (i, j + 1))
end

function edges_from(graph::AbstractSimpleGraph, vertex)
    return edges_from!(edgetype(graph)[], graph, vertex)
end

function edges_from!(_edges, graph::AbstractSimpleGraph, vertex)
    for v in outneighbors(graph, vertex)
        push!(_edges, edgetype(graph)(vertex, v))
    end
    return _edges
end

"""
    edges_topological(graph::AbstractSimpleGraph)

An iterator over edges in `graph` such that the first vertex in the edges
appear in a topological order.
"""
function edges_topological(graph::AbstractSimpleGraph)
    verts = topological_sort(graph)
    return EdgesOrdered{:Topological,typeof(graph),typeof(verts)}(graph, verts)
end

# Materialized array. This is probably more efficient
function _edges_topological(graph::AbstractSimpleGraph)
    _edges = edgetype(graph)[]
    for v in topological_sort(graph)
        edges_from!(_edges, graph, v)
    end
    return _edges
end

###
### dag_longest_path
###

## Algorithm borrowed from networkx

## TODO. Allow passing the work arrays from the entry point.
"""
    dag_longest_path(G, topo_order=topological_sort(G), ::Type{IntT}=eltype(G)) where IntT

Return a longest path in the directed acyclic graph (DAG) `G`.

`G` must a DAG. An optimized method for `G::DiGraph` is implemented.
"""
function dag_longest_path(G::DiGraph, topo_order=topological_sort(G), ::Type{IntT}=eltype(G)) where IntT
    _dag_longest_path_ord(G, topo_order, inneighbors, IntT)
end

"""
    dag_longest_path!(dist_length, dist_u, G::DiGraph, topo_order=topological_sort(G), ::Type{IntT}=eltype(G)) where IntT

Compute a longest path in the directed acyclic graph (DAG) `G`. The work arrays `dist_length::Vector{IntT}` and
`dist_u::Vector{IntT}` will be overwritten. See `dag_longest_path`, which allocates the work arrays for you and
dispatches to `dag_longest_path!` in case this is the method chosen by dispatch.
"""
function dag_longest_path!(dist_length, dist_u, G, topo_order=topological_sort(G), ::Type{IntT}=eltype(G)) where IntT
    _dag_longest_path_ord!(dist_length, dist_u, G, topo_order, inneighbors, IntT)
end

function _dag_longest_path_ord(G, topo_order, inneighborfunc::IF, ::Type{IntT}=Int) where {IntT, IF}
    dist_length = Vector{IntT}(undef, length(topo_order))
    dist_u = Vector{IntT}(undef, length(topo_order))
    return _dag_longest_path_ord!(dist_length, dist_u, G, topo_order, inneighborfunc, IntT)
end

## This method is much faster than the more generic one below.
## Assumptions on the structure of the Graph `G`.
## 1. Vertices are integers from 1:vmax where vmax is the number of vertices
## 2. `inneighborfunc(G, v)` returns a iterable collection of inneighbors of `v`.
## 3. vertices returned by `inneighborfunc` of type `IntT`.
##
## dist_length::Vector{IntT}, dist_u::Vector{IntT} are work arrays that will be overwritten.
function _dag_longest_path_ord!(dist_length, dist_u, G, topo_order, inneighborfunc::IF, ::Type{IntT}=Int) where {IntT, IF}
    path = IntT[]
    isempty(topo_order) && return path
    default_weight = 1 # unweighted
    for v in topo_order
        _vinn = inneighborfunc(G, v)
        vinn = isa(_vinn, AbstractVector) || isa(_vinn, Tuple) ? _vinn : collect(_vinn)
        if isempty(vinn)
            maxu = (0, v)
        else
            (_umax, i) = findmax(u -> dist_length[u] + default_weight, vinn)
            maxu = (_umax, vinn[i])
        end
        # us = [(dist_length[u] + default_weight, u) for u in inneighborfunc(G, v)]
        # maxu = isempty(us) ? (0, v) :  maximumby(us; by=first)
        @inbounds if first(maxu) >= 0
            dist_length[v] = first(maxu)
            dist_u[v] = maxu[2]
        else
            dist_length[v] = IntT(0)
            dist_u[v] = v
        end
    end
    (_, v) = findmax(dist_length) # v is the index
    u = typemax(Int)
    while u != v
        push!(path, v)
        (u, v) = (v, dist_u[v])
    end
    return reverse!(path)
end

## This method does not require that vertices by integers from 1 to num_verts.
## It could be optimized further, even for this general case.
function dag_longest_path(G, topo_order=topological_sort(G), ::Type{IntT}=eltype(G)) where IntT
    path = IntT[]
    isempty(topo_order) && return path
    dist = Dictionary{IntT,Tuple{IntT,IntT}}() # stores (v => (length, u))
    default_weight = 1
    for v in topo_order

        # Use the best predecessor if there is one and its distance is
        # non-negative, otherwise terminate.
        _vinn = inneighbors(G, v)
        vinn = isa(_vinn, AbstractVector) || isa(_vinn, Tuple) ? _vinn : collect(_vinn)

        if isempty(vinn)
            maxu = (0, v)
        else
            (_umax, i) = findmax(u -> dist[u][1] + default_weight, vinn)
            maxu = (_umax, vinn[i])
        end

        # us = [(dist[u][1] + default_weight, u) for u in inneighbors(G, v)]
        # maxu = isempty(us) ? (0, v) :  maximumby(us; by=first)

        Dictionaries.set!(dist, v, first(maxu) >= 0 ? maxu : (0, v))
    end
    (_, v) = findmax(first, dist) # 'v' is the dict key
    u = typemax(Int)
    while u != v
        push!(path, v)
        (u, v) = (v, dist[v][2])
    end
    return reverse!(path)
end

end # module GraphsExt

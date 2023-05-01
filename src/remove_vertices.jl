"""
    module RemoveVertices

Provides `remove_vertices!`.

This module makes no reference to, and is independent of, Graphs.jl. This is because I find it
useful with similar structures that use swap-and-pop for removing vertices, but that are not
subtypes of `AbstractGraph`. The interface to `Graphs.jl` is in the file [`GraphsExt.jl`](@ref).
"""
module RemoveVertices

using Dictionaries: Dictionaries, Dictionary

export VertexMap, remove_vertices!, num_vertices, index_type

# This is a very generic util. Used in unionfind, I think. In fact it may exist somewhere.
# TODO: Document. Maybe clean it up.
# TODO: Find why compression did not seem to be neccessary.
"""
    _follow_map(dict, ind)

Do `outind = get(dict, ind, ind)` and repeat, replacing `ind` with `outind` until
a fixed point is reached and return the result. It is assumed there are no cycles.
If more than the minimum number (for the worst case) of iterations is performed an
error is thrown.
"""
function _follow_map(dict, ind)
    new1 = ind
    ct = 0
    loopmax = length(values(dict)) + 2
    new2 = new1 # value thrown away
    for i = 1:loopmax
        ct += 1
        new2 = get(dict, new1, new1)
        new2 == new1 && break
        # Following should help compress
        # Dictionaries.unset!(dict, new1)
        # Dictionaries.set!(dict, ind, new2)
        new1 = new2
    end
    if ct == loopmax
        @show ind, ct
        throw(ArgumentError("Map does not have required structure."))
    end
    return new2
end

function index_type end
function num_vertices end

# Examples
# index_type(::SimpleDiGraph{IntT}) where {IntT} = IntT
# index_type(::StructVector{<:Node{IntT}}) where {IntT} = IntT
# num_vertices(g::AbstractGraph) = Graphs.nv(g)
# num_vertices(nodes::StructVector{<:Node{IntT}})  =
# num_vertices(nodes::StructVector{<:Node{<:Integer}}) = length(nodes)

"""
    VertexMap{T}

A bidrectional map, typically on integers.

Typically `T <: Dict{IntT, IntT}` where `IntT <: Integer`. The map is meant to be one-to-one and
onto on ``(1, \\ldots, n)``. But, in fact will act as the identity map for any argument that has not
been explicitly mapped. There is no interface for building the map. Applying the map is
implemented by making `vmap::VertexMap` callable.  `vmap(i)` maps `i` forward and `vmap(i,
Val(:Reverse))` gives the reverse (or backward) map.
"""
struct VertexMap{T}
    fmap::T
    imap::T
end

"""
    VertexMap(::Type{IntT})

Create an empty `VertexMap` forward and reverse maps of type `Dictionary{IntT,IntT}`.
"""
function VertexMap(::Type{IntT}) where {IntT}
    return VertexMap(Dictionary{IntT,IntT}(), Dictionary{IntT,IntT}())
end

# Both directions have proven useful in practice.
(vmap::VertexMap)(i::Integer) = vmap(i, Val(:Forward))
(vmap::VertexMap)(i::Integer, ::Val{:Forward}) = get(vmap.fmap, i, i)
(vmap::VertexMap)(i::Integer, ::Val{:Reverse}) = get(vmap.imap, i, i)

"""
    remove_vertices!(graph, vertices, remove_func!, [vmap::VertexMap])::VertexMap

Remove `vertices` from `graph` by calling `remove_func!(graph, v)` on each vertex `v` after mapping.

For `graph::SimpleGraph`, `remove_func!` should be `Graphs.rem_vertex!`. If `vmap` is not
supplied, a new `VertexMap` is created and populated and returned.
"""
function remove_vertices!(
    graph,
    vertices,
    remove_func!::F,
    vmap::VertexMap = VertexMap(index_type(graph)),
) where {F}
    for v in vertices
        n = num_vertices(graph)
        rv = get(vmap.fmap, v, v)
        # Following line must not be active
        #        Dictionaries.unset!(vmap.fmap, v)
        remove_func!(graph, rv)
        if rv != n # If not last vertex, then swap and pop was done
            nval = get(vmap.fmap, rv, rv)
            nn = _follow_map(vmap.imap, n) # find inv map for current last vertex
            Dictionaries.set!(vmap.fmap, nn, nval)
            Dictionaries.set!(vmap.imap, nval, nn)
        end
    end
    return vmap
end

end # module RemoveVertices

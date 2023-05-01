# GraphsExt

[![Build Status](https://github.com/jlapeyre/GraphsExt.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jlapeyre/GraphsExt.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jlapeyre/GraphsExt.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jlapeyre/GraphsExt.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![JET QA](https://img.shields.io/badge/JET.jl-%E2%9C%88%EF%B8%8F-%23aa4444)](https://github.com/aviatesk/JET.jl)


The package contains types and functions that could be in [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) but are not. Some of these will likely be moved into `Graphs.jl` or another package in the Graphs org.

Some of the functions provided are

* `remove_vertices!`
The function `rem_vertices!` in the `Graphs.jl` package is not less than $O(|V|)$ in time complexity. The performance of `remove_vertices!` is
more or less independent of $|V|$. This is essential for using the standard implementation in `Graphs.jl` for large graphs that require frequently removing vertices.
A vertex is an integer in $1,\ldots,|V|$. Removing a vertex  consists of swapping it's place with the last vertex and then popping the removed vertex.
This means that the identity of the previous last vertex has changed, so any external references, including the vertices remaining to be removed in
the call to `remove_vertices!` need to be updated. Furthermore, I find that one sometimes needs to collect groups of vertices to operate on, where some
operations include removing vertices. For this reason, `remove_vertices!` returns both forward and backward maps for the renumbering that occurs. These maps
are also needed internally in `remove_vertices!`. At the moment I did not include examples of how to use these maps in a real workflow, where both maps are needed. I have such an application and will link it in the future.

* `dag_longest_path` -- compute a longest path in a directed acyclic graph (DAG)
* `edges_topological` -- iterate over edges in a topological order
* `split_edge!` -- Replace `v1` $\to$ `v2` with `v1` $\to$ `vmid` $\to$ `v2`.

<!--  LocalWords:  GraphsExt QA jl ldots workflow acyclic v1 v2 vmid
 -->

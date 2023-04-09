# GraphsExt

[![Build Status](https://github.com/jlapeyre/GraphsExt.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jlapeyre/GraphsExt.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jlapeyre/GraphsExt.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jlapeyre/GraphsExt.jl)

The package contains types and functions that coule be in [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) but are not.

Some of the functions provided are

* `remove_vertices!`
The function `rem_vertices!` in the `Graphs.jl` package is not less than $O(|V|)$ in time complexity. The performance of `remove_vertice!` is
more or less independent of $|V|$. Some facilities for managing removed indices and reindexing are provided.

* `dag_longest_path` -- compute a longest path in a directed acyclic graph (DAG)
* `edges_topological` -- iterate over edges in a topological order
* `split_edge!` -- Replace `v1` $\to$ `v2` with `v1` $\to$ `vmid` $\to$ `v2`.

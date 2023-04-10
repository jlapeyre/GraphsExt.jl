using GraphsExt
using Test

if VERSION > v"1.7"
    include("jet_test.jl")
end
include("aqua_test.jl")
include("dag_longest_path_test.jl")

#
# AUTHOR: Guido Masella <guido.masella@gmail.com>
#

push!(LOAD_PATH, "$(ENV["HOME"])/Code/JuliaModules")

# load current directory configurations from _init.jl
if isfile("_init.jl")
    include(joinpath(pwd(), "_init.jl"))
end

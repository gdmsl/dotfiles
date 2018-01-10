#
# AUTHOR: Guido Masella <guido.masella@gmail.com>
#

push!(LOAD_PATH, "$(ENV["HOME"])/src/julia")
ENV["MPLBACKEND"]="tkagg"

isfile("_init.jl") && include(joinpath(pwd(), "_init.jl"))

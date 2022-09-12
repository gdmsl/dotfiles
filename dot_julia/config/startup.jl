# Julia startup file

# use revise by default
try
    using Revise
catch e
    @warn "Error initializing Revise" exception=(e, catch_backtrace())
end

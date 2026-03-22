# Julia startup file

# use revise by default
try
  using Revise
catch e
  @warn "Error initializing Revise" exception = (e, catch_backtrace())
end

atreplinit() do repl
  try
    @eval begin
      using Logging: global_logger
      using TerminalLoggers: TerminalLogger
      global_logger(TerminalLogger())
    end
  catch
  end
end

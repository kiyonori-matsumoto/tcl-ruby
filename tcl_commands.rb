module TclCommands
  def ___list(arg)
    arg.join(' ')
  end

  def ___llength(arg)
    raise TclCommandError.new('wrong \# args: should be "llength list"') if arg.size != 1
    # l = Tclp.new.parse(arg[0])
    l = arg[0].split(/\s+/)
    l.size
  end
end

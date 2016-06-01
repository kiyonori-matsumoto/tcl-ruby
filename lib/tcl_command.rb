class TclField
  def command(arg)
    return @prev if arg[0][0] == '#'
    # return previous command result when comment statement executed
    arg = arg.map { |e| replace(e) }
    if (@hooks.key?(arg[0]))
      @hooks[arg[0]].call(arg[1..-1])
    elsif respond_to?("___#{arg[0]}")
      @prev = send("___#{arg[0]}", arg[1..-1])
    else
      raise(CommandError, "command not found, #{arg[0]}")
    end
  end

  def replace(list)
    return list if list[0] == '{'
    # replace variable
    list.gsub!(/\$\{(.+?)\}|\$(\w+)/) do
      @variables[Regexp.last_match(Regexp.last_match(1) ? 1 : 2)]
    end
    # replace commands
    list.gsub!(/\[(.+)\]/) { parse(Regexp.last_match(1)) }
    list
  end
end

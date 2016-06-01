class TclField
  def initialize
    @variables = {}
    @hooks = {}
  end

  def delete_parenthesis(str)
    if str[0] == '{' && str[-1] == '}'
      str = str[1..-2]
    elsif str[0] == '"' && str[-1] == '"'
      str = str[1..-2]
    else
      return str
    end
    str
  end

  def variables(arg)
    raise(TclError, "can't read $#{arg}, no such variables") unless @variables.key?(arg)
    delete_parenthesis(@variables[arg])
  end

  def add_hook(name, block)
    @hooks[name] = block
  end
end

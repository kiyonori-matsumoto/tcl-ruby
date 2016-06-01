class TclField
  def initialize
    @variables = {}
  end

  def delete_parenthesis(str)
    # loop do
    if str[0] == '{' && str[-1] == '}'
      str = str[1..-2]
    elsif str[0] == '"' && str[-1] == '"'
      str = str[1..-2]
    else
      return str
    end
    str
    # end
  end

  def variables(arg)
    raise(TclError, "can't read $#{arg}, no such variables") unless @variables.key?(arg)
    delete_parenthesis(@variables[arg])
  end
end

class String
  def brace?
    @brace ||= self[0] == '{'
  end

  def bracket?
    @bracket ||= self[0] == '['
  end

  def quote?
    @quote ||= self[0] == '"'
  end

  def parenthesis?
    brace? || bracket? || quote?
  end

  def to_tcl_string
    if parenthesis?
      if (brace? && self[-1] == '}') || (quote? && self[-1] == '"')
        b = self[1..-2]
        clear << b
      end
    end
    self
  end

  def to_tcl_list
    if self == '' || match(/\s/)
      "{#{self}}"
    else
      self
    end
  end

  def init
    @brace = @bracket = @quote = nil
  end
end

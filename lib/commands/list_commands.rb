class TclField
  def ___llength(arg)
    raise(CommandError, 'llength list') if arg.size != 1
    parse(delete_parenthesis(arg[0]), true).size
  end

  def ___list(arg)
    "#{arg.join(' ')}"
  end

  def ___lindex(arg)
    if arg[1].nil?
      arg[0]
    elsif arg[1] == '{}'
      arg[0]
    else
      l = arg[0]
      arg[1..-1].each do |as|
        parse(delete_parenthesis(as), true).each do |a|
          l = parse(delete_parenthesis(l), true)
          a.gsub!(/end/, (l.size - 1).to_s)
          pos = eval(a)
          if (0...l.size).cover?(pos)
            l = l[pos]
          else
            return ''
          end
        end
      end
      l
    end
  end

  def ___join(arg)
    raise(CommandError, 'join list joinString?') unless (1..2).cover? arg.size
    separator = arg[1] || ' '
    parse(delete_parenthesis(arg[0]), true).join(delete_parenthesis(separator))
  end

  def ___linsert(arg)
    raise(CommandError, 'linsert list insertposition elements') unless arg.size >= 3
    l = parse(delete_parenthesis(arg[0]), true)
    l.insert(arg[1].to_i, *arg[2..-1])
    "{#{l.join(' ')}}"
  end

  def ___lrange(arg)
    raise(CommandError, 'lrange list first last') unless arg.size == 3
    first = arg[1].to_i
    first = 0 if first < 0
    last = arg[2].to_i
    l = parse(delete_parenthesis(arg[0]), true)
    if first <= last
      "{#{l[first..last].join(' ')}}"
    else
      ''
    end
  end

  def ___lappend(arg)
    l = parse(variables(arg[0]), true)
    l.push(*arg[1..-1])
    @variables[arg[0]] = "{#{l.join(' ')}}"
  end
end

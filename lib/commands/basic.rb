class TclField
  def ___set(arg)
    raise(CommandError, 'set variable [val]') unless (1..2).cover? arg.size
    @variables[arg[0]] = arg[1] if arg.size == 2
    @variables[arg[0]]
  end

  def ___expr(arg)
    eval arg.join('')
  end

  def ___if(arg)
    arg.delete('then')
    arg.delete('else')
    arg.delete('elseif')
    while arg[1]
      r = eval(replace(delete_parenthesis(arg[0])))
      return parse(delete_parenthesis(arg[1])) if r
      arg.shift(2)
    end
    return parse(delete_parenthesis(arg[0])) if arg[0]
    nil
  end

  def ___for(arg)
    raise(CommandError, 'for start test next body') unless arg.size == 4
    parse(delete_parenthesis(arg[0]))
    catch(:break) {
      while eval(replace(delete_parenthesis(arg[1])))
        catch(:continue) {
          parse(delete_parenthesis(arg[3]))
        }
        parse(delete_parenthesis(arg[2]))
      end
    }
  end

  def ___foreach(arg)
    varlist = []
    list = []
    while arg[2]
      varlist << parse(delete_parenthesis(arg[0]), true)
      list << parse(delete_parenthesis(arg[1]), true)
      arg.shift(2)
    end
    body = delete_parenthesis(arg[0])
    catch(:break) {
      while list.any? { |e| e.any? }
        # assign variables
        varlist.each_with_index do |v, idx|
          v.each do |vv|
            @variables[vv] = list[idx].shift || '{}'
          end
        end
        catch(:continue) {
          parse(body)
        }
      end
    }
  end

  def ___break(_arg)
    throw :break
  end

  def ___continue(_arg)
    throw :continue
  end

  def ___incr(arg)
    raise(CommandError, 'incr varName ?increment?') unless (1..2).include?(arg.size)
    incr = (arg[1]) ? arg[1].to_i : 1
    @variables[delete_parenthesis(arg[0])] =
    (variables(delete_parenthesis(arg[0])).to_i + incr).to_s
  end

  def ___puts(arg)
    puts arg[0]
  end

  # define_method('___#') { |_p| nil }
end

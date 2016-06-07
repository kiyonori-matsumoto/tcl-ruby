module Tcl
  module Ruby
    class Interpreter
      private

      def ___set(var_name, value = nil)
        if (m = var_name.match(/(\w+)\((\S+?)\)/))
          ___array_set(m[1], "{#{m[2]}} {#{value}}") if value
          ___array_get(m[1], "{#{m[2]}}")
        else
          @variables[var_name] = value if value
          @variables[var_name]
        end
      end

      def ___expr(*arg)
        eval arg.join('')
      end

      def ___if(*arg)
        arg.delete('then')
        arg.delete('else')
        arg.delete('elseif')
        while arg[1]
          r = eval(replace(arg[0]))
          return parse(arg[1]) if r && r != 0
          arg.shift(2)
        end
        return parse(arg[0]) if arg[0]
        nil
      end

      def ___for(start, tst, nxt, body)
        parse(start)
        catch(:break) do
          while eval(replace(tst))
            catch(:continue) do
              parse(body)
            end
            parse(nxt)
          end
        end
      end

      def ___foreach(*arg)
        varlist = []
        list = []
        while arg[2]
          varlist << parse(arg[0], true)
          list << parse(arg[1], true)
          arg.shift(2)
        end
        catch(:break) do
          while list.any?(&:any?)
            # assign variables
            varlist.each_with_index do |v, idx|
              v.each { |vv| @variables[vv] = list[idx].shift || '' }
            end
            catch(:continue) do
              parse(arg[0])
            end
          end
        end
      end

      def ___while(tst, body)
        catch(:break) do
          while eval(replace(tst))
            catch(:continue) do
              parse(body)
            end
          end
        end
      end

      def ___break()
        throw :break
      end

      def ___continue()
        throw :continue
      end

      def ___return(val = nil)
        throw(:return, val)
      end

      def ___incr(var_name, increment = 1)
        @variables[var_name] = ((@variables[var_name] || 0).to_i +
          increment.to_i).to_s
      end

      def ___puts(*arg)
        opts = {}
        if arg.size != 1
          opts = OptionParser.parse(['nonewline'], arg)
        end
        __puts_body(*arg, opts)
      end

      def __puts_body(val, opts)
        if opts['nonewline']
          print val
        else
          puts val
        end
      end

      def ___proc(name, args, body)
        @proc[name] = [args, body]
      end

      def ___global(*arg)
        @variables[:___global] ||= []
        arg.each do |v|
          @variables[:___global] << v
          @variables[v] = @global[v] if @global
        end
      end
    end
  end
end

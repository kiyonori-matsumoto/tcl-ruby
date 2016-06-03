module Tcl
  module Ruby
    class Interpreter
      private

      def ___set(arg)
        raise(TclArgumentError, 'set variable ?newValue?') unless
          (1..2).cover? arg.size
        if (m = arg[0].match(/(\w+)\((\S+?)\)/))
          ___array_set([m[1], "{#{m[2]}} {#{arg[1]}}"])
        else
          @variables[arg[0]] = arg[1] if arg.size == 2
          @variables[arg[0]]
        end
      end

      def ___expr(arg)
        eval arg.join('')
      end

      def ___if(arg)
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

      def ___for(arg)
        raise(TclArgumentError, 'for start test next body') unless arg.size == 4
        parse(arg[0])
        catch(:break) do
          while eval(replace(arg[1]))
            catch(:continue) do
              parse(arg[3])
            end
            parse(arg[2])
          end
        end
      end

      def ___foreach(arg)
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

      def ___while(arg)
        body = arg[1]
        catch(:break) do
          while eval(replace(arg[0]))
            catch(:continue) do
              parse(body)
            end
          end
        end
      end

      def ___break(_arg)
        throw :break
      end

      def ___continue(_arg)
        throw :continue
      end

      def ___return(arg)
        throw(:return, arg[0])
      end

      def ___incr(arg)
        raise(TclArgumentError, 'incr varName ?increment?') unless
          (1..2).cover?(arg.size)
        incr = (arg[1]) ? arg[1].to_i : 1
        @variables[arg[0]] = ((@variables[arg[0]] || 0).to_i + incr).to_s
      end

      def ___puts(arg)
        puts arg[0]
      end

      def ___proc(arg)
        raise(TclArgumentError, 'proc name args body') unless arg.size == 3
        @proc[arg[0]] = arg[1..2]
      end

      def ___global(arg)
        @variables[:___global] ||= []
        arg.each do |v|
          @variables[:___global] << v
          @variables[v] = @global[v] if @global
        end
      end
      # define_method('___#') { |_p| nil }
    end
  end
end

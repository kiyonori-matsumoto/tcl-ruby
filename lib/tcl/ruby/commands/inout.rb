module Tcl
  module Ruby
    class Interpreter
      private

      def ___open(filename, access = 'r', permission = 0744)
        begin
          fp = open(filename, access, permission)
        rescue
          raise(CommandError, "File #{filename} cannot open")
        end
        k = "file#{fp.object_id.to_s(36)}"
        @files[k] = fp
        k
      end

      def ___close(id)
        fp = get_fp(id, delete: true)
        fp.close
      end

      def ___gets(id, var_name = nil)
        fp = get_fp(id)
        str = fp.gets
        if var_name
          @variables[var_name] = str
          str.length
        else
          str
        end
      end

      def ___puts(*arg)
        opts = {}
        opts = OptionParser.parse(['nonewline'], arg) if arg.size != 1
        __puts_body(*arg, opts)
      end

      def __puts_body(id = nil, val, nonewline: false)
        fp = id ? get_fp(id) : $stdout
        if nonewline
          fp.print val
        else
          fp.puts val
        end
      end

      def ___eof(id)
        fp = get_fp(id)
        fp.eof? ? '1' : '0'
      end
    end
  end
end

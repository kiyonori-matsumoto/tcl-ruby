module Tcl
  module Ruby
    class TclError < StandardError; end
    class ParseError < TclError; end
    class CommandError < TclError; end
    class TclArgumentError < TclError
      def initialize(msg)
        super("wrong \# args: should be\"#{msg}\"")
      end
    end
    class TclVariableNotFoundError < TclError
      def initialize(var, type = '')
        super("can't read \"#{var}\": #{type}")
      end
    end
  end
end

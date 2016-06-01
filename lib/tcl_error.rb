class TclField
  class TclError < StandardError; end
  class ParseError < TclError; end
  class CommandError < TclError; end
end

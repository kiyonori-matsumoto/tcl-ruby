module Tcl
  module Ruby
    class OptionParser
      # options_format
      # array of string
      # xxxx or xxxx?
      # ? indicates that value has one argument
      def self.parse(options, args)
        ops = options.map do |e|
          v = e.sub(/\?/, '')
          ["-#{v}", v, e[-1] == '?']
        end
        ret = {}
        loop do
          r = ops.each do |o|
            next unless args[0] == o[0]
            args.shift
            ret[o[1]] = true
            ret[o[1]] = args.shift if o[2]
            break false
          end
          break if r
        end
        ret
      end
    end
  end
end

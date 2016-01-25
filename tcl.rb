#! /usr/bin/env ruby

class Tcl

  class TclList < String

    attr_accessor :replacable

    def initialize(str = "")
      @replacable = true
      @val = Hash.new
      super
    end

    def split_into_words
      r = []
      pstack = []
      is_escape = false
      cmd = TclList.new
      self.each_char do |b|
        if is_escape then
          if b == "\n" then
            cmd << " "
          else
            cmd << "\\#{b}"
          end
          is_escape = false
        else
          case b
          when "\\"
            is_escape = true
          when "\n", ";"
            r.push(cmd)
            return r
          when " "
            if pstack.empty? then
              r.push(cmd) unless cmd == ""
              cmd = TclList.new
            else
              cmd << b
            end
          when "{", "["
            cmd << b
            if pstack.empty? then
              pstack.push(b)
            elsif pstack[-1] == b then
              pstack.push(b)
            end
          when "\""
            cmd << b
            if pstack.empty? then
              pstack.push(b)
            elsif pstack[-1] == b then
              pstack.pop
              r.push(cmd)
              cmd = TclList.new
            end
          when "}", "]"
            cmd << b
            if !pstack.empty? && pstack[-1] == b then
              pstack.pop
            end
            if pstack.empty? then
              cmd.replacable = false if b == "}"
              r.push(cmd)
              cmd = TclList.new
            end
          else
            cmd << b
          end
        end
      end
      r.push(cmd)
      r
    end

    def replace (ar)
      r = ar.map do |a|
        if a.replacable then
          #変数置換
          s = a.gsub(/\$([a-zA-Z0-9_:]+)/) { @val[$1] }
          .gsub(/\$\{([^}]+)\}/) { @val[$1]}
          #コマンド置き換え
          regex = /\[(.*?[^\\])\]/
          while regex.match(s)
            s = s.gsub(regex) { exec $1 }
          end
          s
        else
          a
        end
      end
      r
    end

    def exec (val)
      p val
      "test"
    end

  end
end

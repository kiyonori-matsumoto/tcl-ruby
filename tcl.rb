#! /usr/bin/env ruby
require ('forwardable')
require ('stringio')

module Tcl

  class TclError < StandardError; end
  class CommandFailError < TclError; end

  class List
    extend(Forwardable)
    attr_accessor :parenthesis, :val

    def initialize(str = "", lp = "")
      @str = StringIO.new(str)
      @parenthesis = lp
      @val =  {}
    end

    def to_a
      r = get_words
      @str.seek(0)
      r
    end

    def [] (val)
      to_a[val]
    end

    def to_s
      @str.string
    end

    def to_i
      to_s.to_i
    end

    def inspect
      @str.string.inspect
    end

    def gsub(a, &s)
      List.new(@str.string.gsub(a, &s))
    end

    def match(s)
      @str.string.match(s)
    end

    def parse
      res = ""
      loop {
        r = get_words
        break if r.size == 0
        res = exec r
      }
      res
    end

    def get_words
      r = []
      pstack = []
      is_escape = false
      cmd = ""

      #str = (@str.match(/^(\{|\[|\")/)) ? @str[1..-2] : @str

      #str.each_char do |b|
      while true
        begin
          b = @str.readchar
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
              r.push(List.new(cmd)) unless cmd == ""
              return r
              cmd = ""
              r  = []
            when " "
              if pstack.empty? then
                r.push(List.new(cmd)) unless cmd == ""
                cmd = ""
              else
                cmd << b
              end
            when "{", "["
              cmd << b unless pstack.empty? #はじめのカッコは取る
              if pstack.empty? then
                pstack.push(b)
              elsif pstack[-1] == b then
                pstack.push(b)
              end
            when "\""
              if pstack.empty? then
                pstack.push(b)
              elsif pstack[-1] == b then
                pstack.pop
                r.push(List.new(cmd, "\""))
                cmd = ""
              else
                cmd << b
              end
            when "}", "]"
              if (!pstack.empty? && pstack[-1] == "{" && b == "}") ||
                (!pstack.empty? && pstack[-1] == "[" && b == "]") then
                lastparenthesis = pstack.pop
              end
              if pstack.empty? then
                #cmd.replacable = false if b == "}"
                r.push(List.new(cmd, lastparenthesis))
                cmd = ""
              else
                cmd << b
              end
            else
              cmd << b
            end
          end
        rescue EOFError => e
          r.push(List.new(cmd)) unless cmd == ""
          return r
        end
      end
    end

    def exec(ar)
      cmd = preexec(ar)
      c = cmd.shift
      send(c.to_s.to_sym, cmd)
    end

    def preexec (ar)
      r = ar.map do |a|
        if a.parenthesis != "{" then
          #変数置換
          s = a.gsub(/\$([a-zA-Z0-9_:]+)/) { @val[$1] }
          .gsub(/\$\{([^}]+)\}/) { @val[$1]}
          #コマンド置き換え
          if a.parenthesis == "[" then
            r = s.get_words
            s = exec(r)
          else
            s = s.gsub(/\[(.*)\]/) { p $1; t = List.new($1); t = t.get_words; t = exec(t); t }
          end
          # regex = /\[(.*?[^\\])\]/
          # while regex.match(s)
          #   s = s.gsub(regex) { exec $1 }
          # end
          s
        else
          a
        end
      end
      r
    end

    def set(val)
      p val
      if val.size == 1 then
        puts @val[val[0].to_s]
      elsif val.size == 2 then
        @val[val[0].to_s] = val[1]
      else
        raize CommandFailError("set")
      end
    end
    def expr(val)
      List.new((eval(val.join(" "))).to_s)
    end
    def list(val)
      List.new(val.join(" "))
    end
    def lindex(val)
      raise CommandFailError("lindex") unless val.size == 2
      val[0][val[1].to_i]
    end
  end
end

  # class TclListx < String
  #
  #   attr_accessor :replacable
  #
  #   def initialize(str = "")
  #     @replacable = true
  #     @val = Hash.new
  #     super
  #   end
  #
  #   def split_into_words
  #     r = []
  #     pstack = []
  #     is_escape = false
  #     cmd = TclList.new
  #     self.each_char do |b|
  #       if is_escape then
  #         if b == "\n" then
  #           cmd << " "
  #         else
  #           cmd << "\\#{b}"
  #         end
  #         is_escape = false
  #       else
  #         case b
  #         when "\\"
  #           is_escape = true
  #         when "\n", ";"
  #           r.push(cmd)
  #           return r
  #         when " "
  #           if pstack.empty? then
  #             r.push(cmd) unless cmd == ""
  #             cmd = TclList.new
  #           else
  #             cmd << b
  #           end
  #         when "{", "["
  #           cmd << b
  #           if pstack.empty? then
  #             pstack.push(b)
  #           elsif pstack[-1] == b then
  #             pstack.push(b)
  #           end
  #         when "\""
  #           cmd << b
  #           if pstack.empty? then
  #             pstack.push(b)
  #           elsif pstack[-1] == b then
  #             pstack.pop
  #             r.push(cmd)
  #             cmd = TclList.new
  #           end
  #         when "}", "]"
  #           cmd << b
  #           if !pstack.empty? && pstack[-1] == b then
  #             pstack.pop
  #           end
  #           if pstack.empty? then
  #             cmd.replacable = false if b == "}"
  #             r.push(cmd)
  #             cmd = TclList.new
  #           end
  #         else
  #           cmd << b
  #         end
  #       end
  #     end
  #     r.push(cmd)
  #     r
  #   end
  #
  #   def replace (ar)
  #     r = ar.map do |a|
  #       if a.replacable then
  #         #変数置換
  #         s = a.gsub(/\$([a-zA-Z0-9_:]+)/) { @val[$1] }
  #         .gsub(/\$\{([^}]+)\}/) { @val[$1]}
  #         #コマンド置き換え
  #         regex = /\[(.*?[^\\])\]/
  #         while regex.match(s)
  #           s = s.gsub(regex) { exec $1 }
  #         end
  #         s
  #       else
  #         a
  #       end
  #     end
  #     r
  #   end
  #
  #   def exec (val)
  #     p val
  #     "test"
  #   end
  #
  # end
#end

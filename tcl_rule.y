class Tclp

rule
  target: command arguments { result << val[1] }
  arguments: argument arguments { result = val[0] + Array(val[1])}
           | /* none */ { result }
  command: identifier
  argument: identifier
  identifier: IDENTIFIER { result = [val[0]] }

end

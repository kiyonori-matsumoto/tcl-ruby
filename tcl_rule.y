class Tclp

rule
  target: sentences { result = val[0] }
  sentences: sentence sentences { result = val[0] }
           | /* none */ { result }
  sentence: command arguments EOL { result << val[1] }
  arguments: argument arguments { result = val[0] + Array(val[1])}
           | /* none */ { result }
  command: identifier
  argument: identifier
  identifier: IDENTIFIER { result = [val[0]] }

end

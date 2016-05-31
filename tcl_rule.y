class Tclp

rule
  target: sentences { result = val[0] }
  sentences: sentence sentences { result = val[0] }
           | /* none */ { result }
  sentence: command arguments EOL { result = tcl_exec(val[0].concat val[1]) }
  arguments: argument arguments { result = val[0] + Array(val[1])}
           | /* none */ { result }
  command: identifier
  argument: identifier
  identifier: IDENTIFIER { result = [val[0]] }

end

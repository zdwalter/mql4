readline = require 'readline'

rl = readline.createInterface
    input: process.stdin
    output: process.stderr

array = []
rl.on 'line', (line) ->
    console.log line, line.match('Inputs'), line.match('Threshold')
    if line.match('Inputs') > 0
        console.log array.join(',') if array.length
        array = []
    if line.match('Threshold') > 0 or line.match('Attrib')
        s = line.split(' ')
        array.push(s[s.length - 1])
        

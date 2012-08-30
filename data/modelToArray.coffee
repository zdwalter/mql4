readline = require 'readline'

rl = readline.createInterface
    input: process.stdin
    output: process.stderr

array = []
flag = false
rl.on 'line', (line) ->
    #console.log line, line.indexOf('Inputs'), line.indexOf('Threshold')
    if line.indexOf('Inputs') >= 0
        flag = true
        console.log array.join(',') if array.length
        array = []
    if line.indexOf('Class') >= 0
        flag = false
        return
    if flag and (line.indexOf('Threshold') >= 0 or line.indexOf('Attrib') >= 0 or line.indexOf('Node') >= 0)
        return if line.indexOf('Sigmoid') >= 0
        s = line.split(' ')
        x = s[s.length - 1].replace('\n','')
        array.push(x)
        
rl.on 'close', () ->
    console.log array.join(',') if array.length

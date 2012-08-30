readline = require 'readline'

rl = readline.createInterface
    input: process.stdin
    output: process.stderr

AttrNum = 63
max = (0 for i in [0..AttrNum-1])
min = (0 for i in [0..AttrNum-1])
flag = false
rl.on 'line', (line) ->
    #console.log line, line.indexOf('Inputs'), line.indexOf('Threshold')
    if line.indexOf('@data') >= 0
        flag = true
        return
    if flag
        s = line.split(',')
        for i in [0..AttrNum-1]
            x = parseInt(s[i])
            max[i] = x if max[i] < x
            min[i] = x if min[i] > x
        
rl.on 'close', () ->
    console.log 'int Maxs[] = {',max.join(',','}'
    console.log 'int Mins[] = {',min.join(',','}'

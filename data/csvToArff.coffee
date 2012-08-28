fs = require "fs"
file = process.argv[2]

Left = 6
Right = 3
pos = Left + 1
Profit = 20
fs.readFile file, (err, data) ->
    if err
        return console.log err
    array = data.toString().split('\r\n')
    max  = array.length - Right - 1
    extract = (d) ->
        s = d.split(',')
        r =
            #time: s[0]
            #open: s[1]
            close: s[2]*100000
            #high: s[3]
            #low: s[4]
        

    data = (extract i for i in array)
    #console.log data[0]
    #console.log data[1]
    #console.log data[2]
    value = (delta) ->
        if (delta > Profit)
            return 1
        if (Math.abs(delta) < Profit)
            return 0
        return -1
    while pos < max
        close = (data[i].close for i in [pos-Left..pos])
        left = (close[i]-close[i-1] for i in [1..close.length-1])
        mid = data[pos].close
        delta = (data[pos+Right].close - mid)
        v = value(delta)
        left.push(v)
        console.log left.join(',')
        pos++

    


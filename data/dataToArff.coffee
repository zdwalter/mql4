fs = require "fs"
file = process.argv[2]

Left = 62
Right = 37
Profit = 20
fs.readFile file, (err, data) ->
    if err
        return console.log err
    array = data.toString().split(';')
    for day in array
        d = day.split(' ')
        d.shift()
        prices = (parseInt(x*100000) for x in d)
        #console.log prices.length
    pos = Left + 1
    max = prices.length - Right
    while pos < max
        left = (prices[i]-prices[i-1] for i in [pos-Left..pos])
        #console.log left.join(',')
        
        cost = min = max = prices[pos]
        for i in [pos+1, pos+Right]
            p = prices[i]
            min = p if min > p
            max = p if max < p
        v = 0
        v = 1 if max - cost > Profit
        v = -1 if cost - min > Profit
        left.push(v)
        #console.log cost, max, min, v
        pos++
        #flag = false
        #for i in [0..Left]
        #    if left[i] > 50 or left[i] < -50
        #        flag = true
        #continue if flag
        console.log left.join(',')

    


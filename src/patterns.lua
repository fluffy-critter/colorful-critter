-- patterns libraries

function plaid(x,y,r,g,b,a)
    return (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)*64 + 32, 32, 32, 255
end

function splotchy(x,y,r,g,b,a)
    local colors = {{129,1,22}, {158,0,93}, {68,14,98}}
    local color = colors[math.random(1,3)]
    return color[1], color[2], color[3], 255
end

function random(x,y,r,g,b,a)
    return math.random(0,4)*63,math.random(0,4)*63,math.random(0,4)*63,255
end

return {
    plaid=plaid,
    splotchy=splotchy,
    random=random
}
-- patterns libraries

function lerp(x, y, a)
    return x*(1 - a) + y
end

function HSV(h, s, v)
    if s <= 0 then return v,v,v end
    h, s, v = h/256*6, s/255, v/255
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255
end

function genColors(n)
    local colors = {}
    for i=1,n do
        colors[i] = {HSV(math.random(0, 255), 255, math.random(63, 255))}
    end
    return colors
end

function plaid()
    local r0, g0, b0 = HSV(math.random(0, 255), 255, math.random(63, 255))
    local r1, g1, b1 = HSV(math.random(0, 255), 255, math.random(63, 255))

    return function(x,y,r,g,b,a)
        local mix = (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)*0.5
        return lerp(r0, r1, mix), lerp(g0, g1, mix), lerp(b0, b1, mix), 255
    end
end

function argyle()
    local colors = genColors(3)

    return function(x,y,r,g,b,a)
        local mix = (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)
        local color = colors[mix + 1]
        return color[1], color[2], color[3], 255
    end
end

function splotchy()
    local colors = genColors(math.random(2,5))

    return function(x,y,r,g,b,a)
        local color = colors[math.random(#colors)]
        return color[1], color[2], color[3], 255
    end
end

function random()
    return function(x,y,r,g,b,a)
        return math.random(0,4)*63,math.random(0,4)*63,math.random(0,4)*63,255
    end
end

function stripey()
    local colors = genColors(math.random(2,4))
    local amp = math.random(-10.0,10.0)
    local freq = math.random(1.0,5.0)

    return function(x,y,r,g,b,a)
        local yofs = math.cos((x-128)/freq)*amp
        local n = math.floor(((y+yofs)/32)%#colors) + 1
        local color = colors[n]
        return color[1], color[2], color[3], 255
    end
end

choices = {plaid, splotchy, random, argyle, stripey}

return {
    plaid=plaid,
    splotchy=splotchy,
    random=random,
    argyle=argyle,
    stripey=stripey,
    choices=choices
}
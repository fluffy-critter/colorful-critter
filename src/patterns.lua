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

function plaid()
    local r0, g0, b0 = HSV(math.random(0, 255), 255, math.random(63, 255))
    local r1, g1, b1 = HSV(math.random(0, 255), 255, math.random(63, 255))

    return function(x,y,r,g,b,a)
        local mix = (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)*0.5
        return lerp(r0, r1, mix), lerp(g0, g1, mix), lerp(g0, g1, mix), 255
    end
end

function splotchy()
    local colors = {}
    for i=1,3 do
        colors[i] = {HSV(math.random(0, 255), 255, math.random(63, 255))}
    end

    return function(x,y,r,g,b,a)
        local color = colors[math.random(1,3)]
        return color[1], color[2], color[3], 255
    end
end

function random()
    return function(x,y,r,g,b,a)
        return math.random(0,4)*63,math.random(0,4)*63,math.random(0,4)*63,255
    end
end

choices = {plaid, splotchy, random}

return {
    plaid=plaid,
    splotchy=splotchy,
    random=random,
    choices=choices
}
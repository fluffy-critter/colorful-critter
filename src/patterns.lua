--[[
Colorful Critter

(c)2017 fluffy @ beesbuzz.biz, all rights reserved

patterns.lua - critter skin generators

]]

local patterns = {}

local function lerp(x, y, a)
    return x*(1 - a) + y
end

local function HSV(h, s, v)
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

local function genColors(n)
    local colors = {}
    for i=1,n do
        colors[i] = {HSV(math.random(0, 255), 255, math.random(63, 255))}
    end
    return colors
end

patterns.plaid = function()
    local r0, g0, b0 = HSV(math.random(0, 255), 255, math.random(63, 255))
    local r1, g1, b1 = HSV(math.random(0, 255), 255, math.random(63, 255))
    local size = math.random(16,64)

    return function(x,y,r,g,b,a)
        local i = x - 128
        local j = y - 128
        local mix = (math.floor((i+j)/size)%2
            + math.floor((j-i)/size)%2)*0.5
        return lerp(r0, r1, mix), lerp(g0, g1, mix), lerp(b0, b1, mix), 255
    end
end

patterns.argyle = function()
    local colors = genColors(3)

    return function(x,y,r,g,b,a)
        local mix = (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)
        local color = colors[mix + 1]
        return color[1], color[2], color[3], 255
    end
end

patterns.splotchy = function()
    local colors = genColors(math.random(2,5))

    return function(x,y,r,g,b,a)
        local color = colors[math.random(#colors)]
        return color[1], color[2], color[3], 255
    end
end

patterns.random = function()
    return function(x,y,r,g,b,a)
        return math.random(0,4)*63,math.random(0,4)*63,math.random(0,4)*63,255
    end
end

patterns.stripey = function()
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

patterns.nm = function()
    local colors = genColors(3)
    local size = math.random(2.0, 5.0)
    local distance = math.random(size*1.5, size*3.0)
    local size2 = size*size

    return function(x,y,r,g,b,a)
        local ra = x
        local rb = x*0.8142 + y*0.5806
        local rc = x*0.8142 - y*0.5806

        local ca = math.floor(ra/distance) % 2
        local cb = math.floor(rb/distance) % 2
        local cc = math.floor(rc/distance) % 2

        local color = colors[(ca + cb + cc)%3 + 1]

        return color[1], color[2], color[3], 255
    end
end

patterns.choices = {patterns.plaid, patterns.splotchy, patterns.random, patterns.argyle, patterns.stripey, patterns.nm}

return patterns

--[[
Colorful Critter

(c)2017 fluffy @ beesbuzz.biz. Please see the LICENSE file for license information.

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
    local m = (v-c)
    local r, g, b
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m),(g+m),(b+m)
end

local function genColors(n)
    local firstHue = math.random(0,255)
    local lastHue = firstHue + math.random(128, 192)/255
    local hue = firstHue
    local hueSpacing = (lastHue - firstHue)*1.0/n

    local colors = {}

    for _=1,n do
        table.insert(colors, {HSV(hue%256, 255, math.random(128, 255))})
        hue = hue + math.random(hueSpacing/2, hueSpacing*2)
    end
    return colors
end

patterns.plaid = function()
    local r0, g0, b0 = HSV(math.random(0, 255), 255, math.random(63, 255))
    local r1, g1, b1 = HSV(math.random(0, 255), 255, math.random(63, 255))
    local size = math.random(16,64)

    return function(x,y)
        local i = x - 128
        local j = y - 128
        local mix = (math.floor((i+j)/size)%2
            + math.floor((j-i)/size)%2)*0.5
        return lerp(r0, r1, mix), lerp(g0, g1, mix), lerp(b0, b1, mix), 1
    end
end

patterns.argyle = function()
    local colors = genColors(3)

    return function(x,y)
        local mix = (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)
        local color = colors[mix + 1]
        return color[1], color[2], color[3], 1
    end
end

patterns.splotchy = function()
    local colors = genColors(math.random(2,4))

    return function()
        local color = colors[math.random(#colors)]
        return color[1], color[2], color[3], 1
    end
end

patterns.random = function()
    return function()
        return math.random(1,4)/4,math.random(1,4)/4,math.random(1,4)/4,1
    end
end

patterns.stripey = function()
    local colors = genColors(math.random(2,4))
    local amp = math.random(-10.0,10.0)
    local freq = math.random(1.0,5.0)

    return function(x,y)
        local yofs = math.cos((x-128)/freq)*amp
        local n = math.floor(((y+yofs)/32)%#colors) + 1
        local color = colors[n]
        return color[1], color[2], color[3], 1
    end
end

patterns.nm = function()
    local colors = genColors(3)
    local distance = math.random(3.0, 15.0)

    return function(x,y)
        local ra = x
        local rb = x*0.8142 + y*0.5806
        local rc = x*0.8142 - y*0.5806

        local ca = math.floor(ra/distance) % 2
        local cb = math.floor(rb/distance) % 2
        local cc = math.floor(rc/distance) % 2

        local color = colors[(ca + cb + cc)%3 + 1]

        return color[1], color[2], color[3], 1
    end
end

patterns.polka = function()
    local colors = genColors(2)

    local size = math.random(3.0, 5.0)
    local size2 = size*size

    local distX = math.random(size*4.0, size*5.0)
    local distY = distX*.9
    local angle = math.random(0, 6.283)
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)

    return function(u,v)
        u = u - 128
        v = v - 128

        local x = u*cosA + v*sinA
        local y = v*cosA - u*sinA

        -- determine the cell number we're in on each axis
        local i = math.floor(x/distX)
        local j = math.floor(y/distY + (i % 2)*0.5)

        -- determine the center point of the cell
        local cx = (i + 0.5)*distX
        local cy = (j + 0.5 - (i % 2)*0.5)*distY

        -- distance from the center point
        local dx = x - cx
        local dy = y - cy

        local color = colors[dx*dx + dy*dy < size2 and 1 or 2]
        return color[1], color[2], color[3], 1
    end
end

patterns.weave = function()
    local colors = genColors(math.random(2,5))
    local wavX, wavY = {}, {}
    for i,_ in pairs(colors) do
        wavX[i] = math.random()/5 + 0.01
        wavY[i] = (math.random()/2 + 0.75)*wavX[i]
    end
    return function(x,y)
        local maxV
        local maxC

        for i,c in pairs(colors) do
            local v = math.sin(x/wavX[i]) + math.sin(y/wavY[i])
            if not maxV or v > maxV then
                maxV = v
                maxC = c
            end
        end
        return maxC[1], maxC[2], maxC[3], 1
    end
end


patterns.choices = {
    patterns.plaid,
    patterns.splotchy,
    patterns.random,
    patterns.argyle,
    patterns.stripey,
    patterns.nm,
    patterns.polka,
    patterns.weave,
}

return patterns

--[[main.lua - main functionality

Colorful Critter

(c)2017 fluffy @ beesbuzz.biz. Please see the LICENSE file for license information.

]]

local piefiller = require('piefiller')
local Pie
if false then
    Pie = piefiller:new()
end

local patterns = require('patterns')
local states = require('states')
local poses = require('poses')
local sound = require('sound')
local bit = require('bit')

local ffi = require('ffi')

local DEBUG = false
local paused = false
local muteButton = {
    muted = false,

    state = "out",  -- "out" "hover" "active"

    colors = {
        out = {0 , 0, 0},
        hover = {192, 192, 0},
        active = {255, 255, 64},
    }
}

local skin = {}

local paintStrokes = {}

local critter = {
    anxiety = 10,   -- pointer movement without being touched
    itchy = 3,      -- not being touched
    estrus = 0,     -- pointer movement while being touched
    saturation = 1,
    hueshift = 0,

    -- render position of the critter
    x = 384 - 256,
    y = 0,

    -- current look-position of the eyes
    eyeX = 0,
    eyeY = 0,

    -- virtual texture size for remapping
    smear = 255,

    state = "default",

    -- behavior when resetting the pattern
    resetFrames = 0,
    resetCount = 1,

    setPattern = function(p)
         skin.front:renderTo(function()
            -- set the initial pattern
            local startState = love.image.newImageData(256, 256)
            local pattern = p or patterns.choices[math.random(#patterns.choices)]
            -- local pattern = patterns.weave
            startState:mapPixel(pattern())
            local startImage = love.graphics.newImage(startState)
            love.graphics.draw(startImage)

            love.graphics.setColor(math.random(128,255),math.random(128,255),math.random(128,255))
            love.graphics.rectangle("fill", 0, 0, 48, 48)
            love.graphics.setColor(math.random(128,255),math.random(128,255),math.random(128,255))
            love.graphics.rectangle("fill", 208, 0, 48, 48)
            love.graphics.setColor(255,255,255)
        end)
    end,

    texCoords = {},
    overlays = {},
    blush = {},
    pupils = {},
    halo = {},
    haloBright = 0,

    eyeMinY = -5,
    eyeMaxY = 2,
}

local canvasPosition = {
    x = 0,
    y = 0,
    srcW = 0,
    srcH = 0,
    destW = 0,
    destH = 0
}

local pen = {
    color = {127,63,255,255},
    opacity = 255,
    size = 5,

    drawing = false,
    x = 0,
    y = 0,
    radius = 5,

    skinX = 0,
    skinY = 0
}

local screen = {}
local shaders = {}

local function blitCanvas(canvas)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local canvasWidth = canvas:getWidth()
    local canvasHeight = canvas:getHeight()

    local blitSize = { screenWidth, screenWidth*canvasHeight/canvasWidth }
    if screenHeight < blitSize[2] then
        blitSize = { screenHeight*canvasWidth/canvasHeight, screenHeight }
    end

    local blitX = (love.graphics.getWidth() - blitSize[1])/2
    local blitY = (love.graphics.getHeight() - blitSize[2])/2
    love.graphics.draw(canvas, blitX, blitY, 0,
        blitSize[1]/canvasWidth, blitSize[2]/canvasHeight)

    -- update positions for the UI
    canvasPosition.x = blitX
    canvasPosition.y = blitY
    canvasPosition.destW = blitSize[1]
    canvasPosition.destH = blitSize[2]
    canvasPosition.srcW = canvasWidth
    canvasPosition.srcH = canvasHeight
end

local imageCache = {}

local function drawThickLine(x0, y0, r0, x1, y1, r1)
    local deltaX = x1 - x0
    local deltaY = y1 - y0
    local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)
    local px, py = deltaY/distance, -deltaX/distance
    love.graphics.polygon("fill",
        x0 + px*r0, y0 + py*r0,
        x0 - px*r0, y0 - py*r0,
        x1 - px*r1, y1 - py*r1,
        x1 + px*r1, y1 + py*r1
        )
end

local function setPose(pose)
    function loadAssets(tbl)
        local out = {}
        for idx,path in pairs(tbl) do
            if not imageCache[path] then
                imageCache[path] = love.graphics.newImage("assets/" .. path)
            end
            out[idx] = imageCache[path]
        end
        return out
    end

    for k,v in pairs(pose) do
        if type(v) == "table" then
            critter[k] = loadAssets(v)
        else
            critter[k] = v
        end
    end

    -- draw the UV map
    critter.pose:renderTo(function()
        love.graphics.setShader(shaders.threshold)
        shaders.threshold:send("threshold", 0.5)
        love.graphics.clear(0,0,0,0)
        love.graphics.setColor(255,255,255)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        for _,tc in pairs(critter.texCoords) do
            love.graphics.draw(tc, critter.x, critter.y)
        end
        love.graphics.setShader()
    end)
    critter.poseMap = critter.pose:newImageData()
end

function love.load()
    math.randomseed(os.time())

    screen.canvas = love.graphics.newCanvas(768, 512)
    screen.canvas:setFilter("nearest", "nearest")

    screen.colorPicker = love.image.newImageData("assets/gradient.png")
    screen.colorPickerImage = love.graphics.newImage(screen.colorPicker)
    screen.colorPickerImage:setFilter("nearest", "nearest")

    shaders.reduce = love.graphics.newShader("reduce.fs")
    shaders.remap = love.graphics.newShader("remap.fs")
    shaders.hueshift = love.graphics.newShader("hueshift.fs")
    shaders.threshold = love.graphics.newShader("threshold.fs")

    critter.canvas = love.graphics.newCanvas(768, 512)
    critter.pose = love.graphics.newCanvas(768, 512)

    -- initialize the skin
    skin.front = love.graphics.newCanvas(256, 256)
    skin.front:setFilter("nearest", "nearest")
    skin.back = love.graphics.newCanvas(256, 256)
    skin.back:setFilter("nearest", "nearest")

    critter.setPattern()
    critter.skin = skin

    -- initialize the jiggler texture
    skin.jigglerData = love.image.newImageData(256, 256)
    skin.jigglerImage = love.graphics.newImage(skin.jigglerData)
    skin.jigglerImage:setFilter("nearest", "nearest")

    skin.jigglerData:mapPixel(function(x,y,r,g,b,a)
        return x,y,255,255
    end)

    -- preload all the poses
    for _,p in pairs(poses) do
        setPose(p)
    end

    setPose(poses.default)

    -- pencil sound loop
    sound.pencil:setVolume(0)
    sound.pencil:setLooping(true)
    sound.pencil:play()

    muteButton.speakerIcon = love.graphics.newImage("assets/speaker-icon.png")
    muteButton.mutedIcon = love.graphics.newImage("assets/muted-icon.png")
end

function love.draw()
    if Pie then Pie:attach() end

    local cx = critter.x
    local cy = critter.y
    if critter.estrus > 1.5 then
        local vib = (critter.estrus - 1.5)*(critter.estrus - 1)*2
        cx = cx + math.random()*2*vib - vib
        cy = cy + math.random()*2*vib - vib
    end

    screen.canvas:renderTo(function()
        local blushAmount = math.max(0, critter.estrus - 0.2)
        local blushColor = {math.min(255, 255*blushAmount),
            math.min(63, 31*blushAmount),
            math.min(127, 31*blushAmount),
            math.min(255, 255*blushAmount)}

        love.graphics.setCanvas(screen.canvas)
        love.graphics.clear(50,70,90)

        -- draw the color picker
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(screen.colorPickerImage, 0, 0, 0, 2, 2)

        -- draw the size selector
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 768 - 96 - 16, 16, 96, 96)
        love.graphics.ellipse("fill", 768 - 48 - 16, 48 + 16, pen.size*2 + 4, pen.size*2 + 4)
        love.graphics.setColor(255, 255, 255)
        love.graphics.ellipse("fill", 768 - 48 - 16, 48 + 16, pen.size*2 + 2, pen.size*2 + 2)
        love.graphics.setColor(unpack(pen.color))
        love.graphics.ellipse("fill", 768 - 48 - 16, 48 + 16, pen.size*2, pen.size*2)

        -- draw the critter's skin preview
        love.graphics.setColor(255 - blushColor[1],
            255 - blushColor[2],
            255 - blushColor[3])
        love.graphics.rectangle("fill", critter.x, critter.y, 512, 512)
        love.graphics.setShader(shaders.hueshift)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        shaders.hueshift:send("basis", {
            critter.saturation * math.cos(critter.hueshift),
            critter.saturation * math.sin(critter.hueshift)
        })
        love.graphics.setColor(255, 255, 255, 63)
        love.graphics.draw(skin.front, critter.x, critter.y, 0, 2, 2)
        love.graphics.setShader()

        -- composite the critter's skin
        love.graphics.setColor(255, 255, 255)
        critter.canvas:renderTo(function()
            love.graphics.clear(0,0,0,0)
        end)
        love.graphics.setShader(shaders.remap)
        love.graphics.setBlendMode("alpha", "premultiplied")
        shaders.remap:send("referred", skin.front)
        critter.canvas:renderTo(function()
            -- skin layers
            -- for _,tc in pairs(critter.texCoords) do
            --     love.graphics.draw(tc, cx, cy)
            -- end
            love.graphics.draw(critter.pose)
        end)

        -- draw the outline
        love.graphics.setColor(0,0,0,255)
        for i=-1,1 do
            for j=-1,1 do
                love.graphics.draw(critter.canvas, i, j)
            end
        end

        -- draw the skin
        love.graphics.setColor(255,255,255)
        love.graphics.setShader(shaders.hueshift)
        shaders.hueshift:send("basis", {
            critter.saturation * math.cos(critter.hueshift),
            critter.saturation * math.sin(critter.hueshift)
        })
        love.graphics.draw(critter.canvas)
        love.graphics.setShader()

        -- overlay layers
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setColor(255,255,255)
        for _,ov in pairs(critter.overlays) do
            love.graphics.draw(ov, cx, cy)
        end
        for _,ov in pairs(critter.pupils) do
            love.graphics.draw(ov, cx + critter.eyeX, cy + critter.eyeY)
        end

        -- aww, it's blushing
        love.graphics.setColor(unpack(blushColor))
        for _,ov in pairs(critter.blush) do
            love.graphics.draw(ov, critter.x, critter.y)
        end

        -- aww, it's.... really blushing
        if critter.halo then
            love.graphics.setBlendMode("alpha", "alphamultiply")
            love.graphics.setColor(255, 255, 255, math.min(255, critter.haloBright*255))
            love.graphics.setShader(shaders.hueshift)
            shaders.hueshift:send("basis", {
                critter.saturation * math.cos(critter.hueshift*5),
                critter.saturation * math.sin(critter.hueshift*5)
            })
            for _,ov in pairs(critter.halo) do
                love.graphics.draw(ov, cx, cy)
            end
            love.graphics.setShader()
        end

        -- draw the paint stroke queue
        local prevInk
        for _,ink in ipairs(paintStrokes) do
            if ink.color then
                love.graphics.setColor(unpack(ink.color))
                love.graphics.ellipse("fill", ink.x, ink.y, ink.radius*2, ink.radius*2)
                if prevInk and prevInk.radius then
                    drawThickLine(ink.x, ink.y, ink.radius*2,
                        prevInk.x, prevInk.y, prevInk.radius*2)
                end
            end
            prevInk = ink
        end
        paintStrokes = {prevInk}

        if DEBUG then
            love.graphics.setColor(255, 255, 255)
            love.graphics.draw(critter.pose, 768 - 256, 512 - 256, 0, 0.5, 0.5)
        end

        -- mute button
        love.graphics.setColor(unpack(muteButton.colors[muteButton.state]))
        love.graphics.rectangle("fill", 768 - 32, 512 - 32, 32, 32)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setColor(255,255,255)
        love.graphics.draw(muteButton.speakerIcon, 768 - 32, 512 - 32)
        if (muteButton.muted) then
            love.graphics.draw(muteButton.mutedIcon, 768 - 32, 512 - 32)
        end
    end)

    love.graphics.setBlendMode("alpha", "alphamultiply")
    love.graphics.setColor(255,255,255)
    blitCanvas(screen.canvas)

    if DEBUG then

        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 0, 0)

        love.graphics.print(
            string.format("state: %s anxiety: %.1f itchy:%.1f estrus:%.1f hue:%.0f",
                critter.state,
                critter.anxiety, critter.itchy, critter.estrus, critter.hueshift*180/math.pi%360),
            love.graphics.getWidth()/2, 0)
    end

    if Pie then Pie:detach(); Pie:draw() end
end

local function reduceChromatophores(front, back, x, y, w, h)
    back:renderTo(function()
        love.graphics.setShader(shaders.reduce)
        shaders.reduce:send("size", {front:getWidth(), front:getHeight()})
        love.graphics.draw(front)
        love.graphics.setShader()
    end)
end

local function pumpStateGraph(critter)
    local curState = states[critter.state]
    local nextState
    local nextPose
    local seenStates = {critter.state}
    local stateChain = {critter.state}
    repeat
        nextState = curState.nextState(critter)

        if nextState then
            table.insert(stateChain, nextState)

            -- detect logic cycles
            if seenStates[nextState] then
                local chain = ""
                for i,s in ipairs(stateChain) do
                    if i > 1 then
                        chain = chain .. " -> "
                    end
                    chain = chain .. string.sub(s,1,3)
                end
                error(string.format("state cycle: %s  ax=%.1f it=%.1f es=%.1f",
                    chain,
                    critter.anxiety, critter.itchy, critter.estrus))
            end
            seenStates[nextState] = true

            if DEBUG then
                print("nextState = "..string.sub(nextState,1,3))
            end

            critter.state = nextState
            curState = states[nextState]
            if curState.pose then
                nextPose = curState.pose
            end

            if curState.onEnterState then
                curState.onEnterState(critter)
            end
        end
    until not nextState

    return nextPose
end

function love.mousepressed(...)
    -- local x, y, button, istouch = ...

    if Pie then Pie:mousepressed(...) end
end

ffi.cdef[[
typedef struct { uint16_t src, dest; } swap_coords;
]]

local ImageData_Pixel = ffi.typeof("uint32_t *")

local function jiggle(count)
    -- store the pixels which need unmangling (faster than remapping the image every frame)
    local toUndo = ffi.new("swap_coords[?]", count)
    local pixels = ffi.cast(ImageData_Pixel, skin.jigglerData:getPointer())

    for i = 0, count - 1 do
        local sp = math.random(0,65535)
        local dx = math.random(-critter.itchy,critter.itchy)
        local dy = math.random(-critter.itchy,critter.itchy)
        local dp = bit.band(sp + dy*256 + dx, 65535)

        pixels[sp], pixels[dp] = pixels[dp], pixels[sp]

        local tu = toUndo[i]
        tu.src, tu.dest = sp, dp
    end
    skin.jigglerImage:refresh()

    skin.back:renderTo(function()
        love.graphics.setShader(shaders.remap)
        shaders.remap:send("referred", skin.front)
        shaders.remap:send("tgtSize", critter.smear)
        love.graphics.setColor(255,255,255)
        love.graphics.draw(skin.jigglerImage)
        love.graphics.setShader()
    end)
    skin.front,skin.back = skin.back,skin.front

    -- unmangle the pixels
    for i = 0, count - 1 do
        local tu = toUndo[i]
        pixels[tu.src], pixels[tu.dest] = pixels[tu.dest], pixels[tu.src]
    end
end

function love.update(dt)
    if Pie then Pie:attach() end

    critter.hueshift = critter.hueshift + math.pow(critter.estrus,4)*dt/10
    critter.haloBright = critter.haloBright*(1 - dt/5) + critter.estrus*dt/5;

    -- jiggle the chromatophores a bit based on critter's anxiety
    if critter.anxiety > 0 then
        jiggle(math.min(critter.anxiety, 256))
    end

    -- reduce front buffer into backbuffer
    reduceChromatophores(skin.front, skin.back, 0, 0, 256, 256)
    skin.front,skin.back = skin.back,skin.front

    -- handle mouse controls
    local mx = (love.mouse.getX() - canvasPosition.x)*canvasPosition.srcW/canvasPosition.destW
    local my = (love.mouse.getY() - canvasPosition.y)*canvasPosition.srcH/canvasPosition.destH

    local prevDrawing = pen.drawing
    pen.drawing = false

    local oldColor = pen.color
    local oldSize = pen.size

    local touched = false
    local prevX, prevY = pen.x, pen.y
    pen.x, pen.y = mx, my
    local deltaX = pen.x - prevX
    local deltaY = pen.y - prevY
    local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)/2

    critter.eyeX = (mx - (critter.x + critter.eyeCX))/20
    critter.eyeY = (my - (critter.y + critter.eyeCY))/20
    -- bias upwards
    if critter.eyeY < 0 then
        critter.eyeY = critter.eyeY * 2
    end
    local eyeD = math.sqrt(critter.eyeX*critter.eyeX + critter.eyeY*critter.eyeY)
    if eyeD > 8 then
        critter.eyeX = critter.eyeX*8 / eyeD
        critter.eyeY = critter.eyeY*8 / eyeD
    end
    critter.eyeX = math.max(-5, math.min(5, critter.eyeX))
    critter.eyeY = math.max(critter.eyeMinY, math.min(critter.eyeMaxY, critter.eyeY))

    muteButton.hovering = false
    if (mx >= 768 - 32) and (mx < 768) and (my >= 512 - 32) and (my < 512) then
        muteButton.hovering = true
    elseif (mx >= 0) and (mx < 96) and (my >= 0) and (my < 512) then
        -- color picker
        if (love.mouse.isDown(1)) then
            pen.color = {screen.colorPicker:getPixel(mx/2, my/2)}
            pen.color[4] = pen.opacity
        end
    elseif (mx >= 768 - 96 - 16) and (mx < 768 - 16)
        and (my > 16) and (my < 96 + 16) then
        -- size adjust
        if love.mouse.isDown(1) then
            local x = mx - (768 - 16 - 48)
            local y = my - (16 + 48)
            pen.size = math.min(24, math.sqrt(x*x + y*y)/2)
            -- pen.size = x/2
            -- pen.opacity = 255 - y*255/32
            -- pen.color[4] = pen.opacity
        end
    elseif love.mouse.isDown(1) then
        -- paint strokes
        pen.drawing = true

        local prevRadius = pen.radius
        pen.radius = pen.size

        if prevDrawing then
            pen.radius = pen.radius/math.max(1,distance/4)
        end

        -- unshift the color for the painting
        local rotU = math.cos(-critter.hueshift)
        local rotV = math.sin(-critter.hueshift)
        local unshiftColor = {
            (
                  (.299+.701*rotU+.168*rotV)*pen.color[1]
                + (.587-.587*rotU+.330*rotV)*pen.color[2]
                + (.114-.114*rotU-.497*rotV)*pen.color[3]
            ),
            (
                  (.299-.299*rotU-.328*rotV)*pen.color[1]
                + (.587+.413*rotU+.035*rotV)*pen.color[2]
                + (.114-.114*rotU+.292*rotV)*pen.color[3]
            ),
            (
                  (.299-.300*rotU+1.25*rotV)*pen.color[1]
                + (.587-.588*rotU-1.05*rotV)*pen.color[2]
                + (.114+.886*rotU-.203*rotV)*pen.color[3]
            ),
            pen.opacity
        }

        -- get the skin location
        local prevSX, prevSY = pen.skinX, pen.skinY
        local remapped

        if (pen.x >= 0) and (pen.x < critter.poseMap:getWidth())
            and (pen.y >= 0) and (pen.y < critter.poseMap:getHeight()) then
            remapped = {critter.poseMap:getPixel(pen.x, pen.y)}
        end

        if remapped and remapped[4] > 192 then
            -- pen was on the critter, so re-draw in object space
            pen.skinX, pen.skinY = remapped[1], remapped[2]
            touched = true
        else
            -- pen wasn't on the critter, so draw in screen space
            pen.skinX, pen.skinY = (pen.x - critter.x)/2, (pen.y - critter.y)/2
        end

        -- if the skin position jumped more than 2x the screen position, treat it as discontinuous
        local dsx, dsy = pen.skinX - prevSX, pen.skinY - prevSY
        if dsx*dsx + dsy*dsy > distance*distance*4 then
            prevDrawing = false
        end

        -- set up the paint overlay
        table.insert(paintStrokes, {
            x = pen.x,
            y = pen.y,
            radius = pen.radius,
            color = pen.color
        })

        -- draw the pen stroke into the skin buffer
        skin.front:renderTo(function()
            love.graphics.setColor(unpack(unshiftColor))

            love.graphics.ellipse("fill", pen.skinX, pen.skinY, pen.radius, pen.radius)
            if prevDrawing then
                drawThickLine(pen.skinX, pen.skinY, pen.radius, prevSX, prevSY, prevRadius)
            end
        end)
    end

    if not pen.drawing then
        table.insert(paintStrokes, {})
    end

    if muteButton.state == "out" then
        if muteButton.hovering then
            muteButton.state = "hover"
        end
    elseif muteButton.state == "hover" then
        if not muteButton.hovering then
            muteButton.state = "out"
        elseif love.mouse.isDown(1) then
            muteButton.state = "active"
        end
    elseif muteButton.state == "active" then
        if not muteButton.hovering then
            muteButton.state = "out"
        elseif not love.mouse.isDown(1) then
            muteButton.muted = not muteButton.muted
            muteButton.state = "hover"

            love.audio.setVolume(muteButton.muted and 0 or 1)
        end
    end

    -- affect the critter's state
    if not paused then
        if touched then
            -- let things calm down a tiny tiny bit
            critter.estrus = math.max(critter.estrus*(1 - dt/10), 0)
            -- as the cursor moves, estrus increases
            critter.estrus = math.min(critter.estrus + math.sqrt(distance + 1)/800, 5)

            critter.itchy = math.max(critter.itchy*(1 - dt/3), 0)
            critter.anxiety = math.max(critter.anxiety*math.sqrt(math.max(1 - dt), 0), 0)
        else
            critter.estrus = math.max(critter.estrus*(1 - dt/8), 0)
            critter.itchy = math.min(critter.itchy + dt/3, 30)
            if distance > 0 then
                critter.anxiety = math.min(critter.anxiety + math.sqrt(distance)/5, 1000)
            else
                critter.anxiety = math.max(critter.anxiety*(1 - dt/10) + critter.itchy*dt/10, 0)
            end
        end
    end

    -- grab the color from the cursor position (slow, should come last)
    if love.mouse.isDown(2) and (mx >= 0) and (mx < 768) and (my >= 0) and (my < 512) then
        local foo = screen.canvas:newImageData()
        pen.color = {foo:getPixel(mx, my)}
        pen.color[4] = pen.opacity
    end

    -- handle the sound stuff
    if pen.drawing and (distance > 0) then
        sound.pencil:setVolume(math.sqrt(distance/255))
    else
        sound.pencil:setVolume(0)
    end

    local colorDistance = (math.abs(pen.color[1] - oldColor[1]) +
        math.abs(pen.color[2] - oldColor[2]) +
        math.abs(pen.color[3] - oldColor[3]))
    if colorDistance > 8 then
        if love.mouse.isDown(2) then
            sound.eyeDropper:rewind()
            sound.eyeDropper:play()
        else
            sound.colorPicker:rewind()
            sound.colorPicker:play()
        end
    end

    if pen.size ~= oldSize then
        sound.radius:rewind()
        sound.radius:play()
    end

    -- finally, evaluate the state transitions
    local nextPose = pumpStateGraph(critter)
    if nextPose then
        if DEBUG then
            print("nextPose=" .. nextPose)
        end
        setPose(poses[nextPose])
    end

    if Pie then Pie:detach() end
end

local _debug = {
    sequence = {"+lctrl", "+lshift", "-lctrl", "+lalt"},
    pos = 1
}

local function _debugLatch(key)
    if key == _debug.sequence[_debug.pos] then
        _debug.pos = _debug.pos + 1
        if _debug.pos > #_debug.sequence then
            DEBUG = not DEBUG
        end
        return true
    else
        _debug.pos = 1
    end
end

function love.keyreleased(key, sc)
    _debugLatch("-" .. key)
end

function love.keypressed(key, sc, isRepeat)
    if Pie then Pie:keypressed(key, sc, isRepeat) end

    _debugLatch("+" .. key)

    if DEBUG then
        print("key pressed: " .. key .. " sc=" .. sc .. " repeat=" .. tostring(isRepeat))
    end

    if key == "space" then
        paused = not paused
    end

    if DEBUG then
        if key == "q" then
            setPose(poses.default)
        elseif key == "w" then
            setPose(poses.anxious)
        elseif key == "e" then
            setPose(poses.frustrated)
        elseif key == "r" then
            setPose(poses.relaxed)
        elseif key == "t" then
            setPose(poses.refractory)
        elseif key == "a" then
            setPose(poses.aroused)
        elseif key == "s" then
            setPose(poses.orgasm)
        elseif key == "d" then
            setPose(poses.hyperorgasm)
        elseif key == "f" then
            setPose(poses.hyperrefractory)
        elseif key == "g" then
            setPose(poses.angry)
        elseif key == "z" then
            setPose(poses.squirm)
        end

        if key == "0" then
            critter.setPattern()
        elseif key == "9" then
            critter.setPattern(patterns.polka)
        end

        -- test all states and their poses
        if key == "7" then
            for n,s in pairs(states) do
                print("state: " .. n)
                local pose = s.pose
                if pose then
                    print("pose: " .. pose)
                    setPose(poses[pose])
                end
            end
        elseif key == "`" then
            -- smoketest the state machine
            local seenStates = {}
            local transitions = {}
            for state,_ in pairs(states) do
                print("testing state " .. state)
                for n = 1,1000 do
                    local e=math.random()*2.1
                    local i=math.random()*20
                    local a=math.random()*200
                    print(state, n, e, i, a)
                    critter.state = state
                    critter.anxiety = a
                    critter.itchy = i
                    critter.estrus = e
                    pumpStateGraph(critter)
                    seenStates[critter.state] = true
                    transitions[state] = transitions[state] or {}
                    transitions[state][critter.state] = true
                end
            end
            for state,_ in pairs(states) do
                print("state " .. state .. ": " .. (seenStates[state] and "found" or "NOT FOUND"))
            end
            for state,tlist in pairs(transitions) do
                print ("start " .. state)
                for dest,_ in pairs(tlist) do
                    print ("    -> " .. dest)
                end
            end
        end
    end
end


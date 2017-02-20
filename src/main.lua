patterns = require('patterns')
states = require('states')
poses = require('poses')

DEBUG = true

critter = {
    anxiety = 10,   -- pointer movement without being touched
    itchy = 3,      -- not being touched
    estrus = 0,     -- pointer movement while being touched
    saturation = 1,
    hueshift = 0,

    -- render position of the critter
    x = (384 - 256)/2,
    y = 0,

    -- current look-position of the eyes
    eyeX = 0,
    eyeY = 0,

    state = "default",

    setPattern = function()
         skin.front:renderTo(function()
            -- set the initial pattern
            local startState = love.image.newImageData(256, 256)
            local pattern = patterns.choices[math.random(#patterns.choices)]
            -- local pattern = patterns.stripey
            startState:mapPixel(pattern())
            local startImage = love.graphics.newImage(startState)
            love.graphics.draw(startImage)

            love.graphics.setColor(math.random(128,255),math.random(128,255),math.random(128,255))
            love.graphics.rectangle("fill", 0, 0, 64, 56)
            love.graphics.setColor(math.random(128,255),math.random(128,255),math.random(128,255))
            love.graphics.rectangle("fill", 192, 0, 64, 56)
            love.graphics.setColor(255,255,255)
        end)
    end
}

canvasPosition = {
    x = 0,
    y = 0,
    srcW = 0,
    srcH = 0,
    destW = 0,
    destH = 0
}

pen = {
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

function blitCanvas(canvas)
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
    love.graphics.draw(screen, blitX, blitY, 0,
        blitSize[1]/canvasWidth, blitSize[2]/canvasHeight)

    -- update positions for the UI
    canvasPosition.x = blitX
    canvasPosition.y = blitY
    canvasPosition.destW = blitSize[1]
    canvasPosition.destH = blitSize[2]
    canvasPosition.srcW = canvasWidth
    canvasPosition.srcH = canvasHeight
end

function love.load()
    math.randomseed(os.time())

    screen = love.graphics.newCanvas(384, 256)
    screen:setFilter("nearest", "nearest")

    paintOverlay = love.graphics.newCanvas(384, 256)

    colorPicker = love.image.newImageData("assets/gradient.png")
    colorPickerImage = love.graphics.newImage(colorPicker)

    critter.texCoords = {}
    critter.overlays = {}
    critter.blush = {}
    critter.pupils = {}

    reduceShader = love.graphics.newShader("reduce.fs")
    remapShader = love.graphics.newShader("remap.fs")
    hueshiftShader = love.graphics.newShader("hueshift.fs")

    critter.canvas = love.graphics.newCanvas(384, 256)
    critter.pose = love.graphics.newCanvas(384, 256)

    -- initialize the skin
    skin = {}

    skin.front = love.graphics.newCanvas(256, 256)
    skin.front:setFilter("nearest", "nearest")
    skin.back = love.graphics.newCanvas(256, 256)
    skin.front:setFilter("nearest", "nearest")

    critter.setPattern()

    -- initialize the jiggler texture
    skin.jigglerData = love.image.newImageData(256, 256)
    skin.jigglerImage = love.graphics.newImage(skin.jigglerData)
    skin.jigglerImage:setFilter("nearest", "nearest")

    setPose(poses.default)
end

function setPose(pose)
    function loadAssets(tbl)
        local out = {}
        for idx,path in pairs(tbl) do
            out[idx] = love.graphics.newImage("assets/" .. path)
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
        love.graphics.clear(0,0,0,0)
        love.graphics.setColor(255,255,255)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        for _,tc in pairs(critter.texCoords) do
            love.graphics.draw(tc, critter.x, critter.y)
        end
    end)
    critter.poseMap = critter.pose:newImageData()
end

function love.draw()
    screen:renderTo(function()
        love.graphics.setCanvas(screen)
        love.graphics.clear(50,70,90)

        -- draw the color picker
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(colorPickerImage, 0, 0)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", colorPicker:getWidth(), 0, 64, 64)
        love.graphics.setColor(unpack(pen.color))
        love.graphics.ellipse("fill", colorPicker:getWidth() + 32, 32, pen.size, pen.size)
        love.graphics.setColor(255,255,255)

        -- draw the critter's skin preview
        love.graphics.setShader(hueshiftShader)
        hueshiftShader:send("basis", {
            critter.saturation * math.cos(critter.hueshift),
            critter.saturation * math.sin(critter.hueshift)
        })
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(skin.front, 384 - 128, 128, 0, 0.5, 0.5)
        love.graphics.setShader()

        -- draw the critter
        critter.canvas:renderTo(function()
            love.graphics.clear(0,0,0,0)
        end)
        love.graphics.setShader(remapShader)
        remapShader:send("referred", skin.front)
        critter.canvas:renderTo(function()
            -- skin layers
            love.graphics.setBlendMode("alpha", "premultiplied")
            for _,tc in pairs(critter.texCoords) do
                love.graphics.draw(tc, critter.x, critter.y)
            end
        end)
        love.graphics.setShader(hueshiftShader)
        hueshiftShader:send("basis", {
            critter.saturation * math.cos(critter.hueshift),
            critter.saturation * math.sin(critter.hueshift)
        })
        love.graphics.draw(critter.canvas)
        love.graphics.setShader()

        -- overlay layers
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setColor(255,255,255)
        for _,ov in pairs(critter.overlays) do
            love.graphics.draw(ov, critter.x, critter.y)
        end
        for _,ov in pairs(critter.pupils) do
            love.graphics.draw(ov, critter.x + critter.eyeX, critter.y + critter.eyeY)
        end

        -- aww, it's blushing
        love.graphics.setColor(math.min(255, 255*critter.estrus),
            math.min(63, 31*critter.estrus),
            math.min(127, 31*critter.estrus),
            math.min(255, 255*math.sqrt(critter.estrus)))
        for _,ov in pairs(critter.blush) do
            love.graphics.draw(ov, critter.x, critter.y)
        end
        love.graphics.setColor(255,255,255)

        -- draw the paint overlay
        love.graphics.draw(paintOverlay)
    end)

    love.graphics.setBlendMode("alpha", "alphamultiply")

    blitCanvas(screen)

    if DEBUG then
        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 0, 0)

        love.graphics.print(
            string.format("state: %s anxiety: %.1f itchy:%.1f estrus:%.1f",
                critter.state,
                critter.anxiety, critter.itchy, critter.estrus),
            love.graphics.getWidth()/2, 0)
    end
end

function reduceChromatophores(front, back, x, y, w, h)
    back:renderTo(function()
        love.graphics.setShader(reduceShader)
        reduceShader:send("size", {front:getWidth(), front:getHeight()})
        love.graphics.draw(front)
        love.graphics.setShader()
    end)
end

function drawThickLine(x0, y0, r0, x1, y1, r1)
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

function love.update(dt)
    critter.hueshift = critter.hueshift + critter.estrus*dt/3

    -- jiggle the chromatophores a bit based on critter's anxiety
    if critter.anxiety > 0 then
        skin.jigglerData:mapPixel(function(x,y,r,g,b,a)
            return x,y,255,255
        end)
        for i=0,critter.anxiety do
            local sx = math.random(0,255)
            local sy = math.random(0,255)
            local dx = math.floor(sx + math.random(-critter.itchy,critter.itchy))%256
            local dy = math.floor(sy + math.random(-critter.itchy,critter.itchy))%256

            local sp = {skin.jigglerData:getPixel(sx, sy)}
            local dp = {skin.jigglerData:getPixel(dx, dy)}
            skin.jigglerData:setPixel(sx, sy, unpack(dp))
            skin.jigglerData:setPixel(dx, dy, unpack(sp))
        end
        skin.jigglerImage:refresh()

        skin.back:renderTo(function()
            love.graphics.setShader(remapShader)
            remapShader:send("referred", skin.front)
            love.graphics.setColor(255,255,255)
            love.graphics.draw(skin.jigglerImage)
            love.graphics.setShader()
        end)
        skin.front,skin.back = skin.back,skin.front
    end

    -- reduce front buffer into backbuffer
    reduceChromatophores(skin.front, skin.back, 0, 0, 256, 256)
    skin.front,skin.back = skin.back,skin.front

    -- clear the paint overlay
    paintOverlay:renderTo(function()
        love.graphics.clear(0,0,0,0)
    end)

    -- handle mouse controls
    local mx = (love.mouse.getX() - canvasPosition.x)*canvasPosition.srcW/canvasPosition.destW
    local my = (love.mouse.getY() - canvasPosition.y)*canvasPosition.srcH/canvasPosition.destH

    local prevDrawing = pen.drawing
    pen.drawing = false

    local touched = false
    local prevX, prevY = pen.x, pen.y
    pen.x, pen.y = mx, my
    local deltaX = pen.x - prevX
    local deltaY = pen.y - prevY
    local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)

    critter.eyeX = (mx - (critter.x + critter.eyeCX))/20
    critter.eyeY = (my - (critter.y + critter.eyeCY))/20
    local eyeD = math.sqrt(critter.eyeX*critter.eyeX + critter.eyeY*critter.eyeY)
    if eyeD > 3 then
        critter.eyeX = critter.eyeX*3 / eyeD
        critter.eyeY = critter.eyeY*3 / eyeD
    end
    critter.eyeY = math.min(2, critter.eyeY)

    if (mx >= 0) and (mx < 48) and (my >= 0) and (my < 256) then
        -- color picker
        if (love.mouse.isDown(1)) then
            pen.color = {colorPicker:getPixel(mx, my)}
            pen.color[4] = pen.opacity
        end
    elseif (mx >= 48) and (mx < 48 + 64) and (my >= 0) and (my < 64) then
        -- size adjust
        if love.mouse.isDown(1) then
            local x = mx - 48 - 32
            local y = my - 32
            pen.size = math.min(32, math.sqrt(x*x + y*y))
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

        -- paint into the paint overlay texture
        paintOverlay:renderTo(function()
            love.graphics.setColor(unpack(pen.color))

            love.graphics.ellipse("fill", pen.x, pen.y, pen.radius, pen.radius)
            if prevDrawing then
                drawThickLine(pen.x, pen.y, pen.radius, prevX, prevY, prevRadius)
            end
        end)

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
        local remapped = {0,0,0.0}

        if (pen.x >= 0) and (pen.x < critter.poseMap:getWidth())
            and (pen.y >= 0) and (pen.y < critter.poseMap:getHeight()) then
            remapped = {critter.poseMap:getPixel(pen.x, pen.y)}
        end

        if remapped[3] > 192 then
            -- pen was on the critter, so re-draw in object space
            pen.skinX, pen.skinY = remapped[1], remapped[2]
            touched = true
        else
            -- pen wasn't on the critter, so draw in screen space
            pen.skinX, pen.skinY = pen.x - 128, pen.y
        end

        -- if the skin position jumped more than 2x the screen position, treat it as discontinuous
        local dsx, dsy = pen.skinX - prevSX, pen.skinY - prevSY
        if math.sqrt(dsx*dsx + dsy*dsy) > distance*2 then
            prevDrawing = false
        end

        -- redraw the pen stroke into the skin buffer
        skin.front:renderTo(function()
            love.graphics.setColor(unpack(unshiftColor))

            love.graphics.ellipse("fill", pen.skinX, pen.skinY, pen.radius, pen.radius)
            if prevDrawing then
                drawThickLine(pen.skinX, pen.skinY, pen.radius, prevSX, prevSY, prevRadius)
            end
        end)

    end

    -- mouse motions should affect the critter's state
    if touched then
        -- let things calm down a tiny tiny bit
        critter.estrus = math.max(critter.estrus*(1 - dt/10), 0)
        -- as the cursor moves, estrus increases
        critter.estrus = math.min(critter.estrus + math.sqrt(distance + 1)/500, 5)

        critter.itchy = math.max(critter.itchy*(1 - dt), 0)
        critter.anxiety = math.max(critter.anxiety*math.sqrt(math.max(1 - dt), 0), 0)
    else
        critter.estrus = math.max(critter.estrus*(1 - dt/8), 0)
        critter.itchy = math.min(critter.itchy + dt/5, 20)
        if distance > 0 then
            critter.anxiety = math.min(critter.anxiety + math.sqrt(distance)/5, 1000)
        else
            critter.anxiety = math.max(critter.anxiety*(1 - dt/10) + critter.itchy*dt/10, 0)
        end
    end

    -- grab the color from the cursor position (slow, should come last)
    if love.mouse.isDown(2) then
        local foo = screen:newImageData()
        pen.color = {foo:getPixel(mx, my)}
        pen.color[4] = pen.opacity
    end

    -- finally, evaluate the state transitions
    local curState = states[critter.state]
    local nextState
    local nextPose
    local seenStates = {}
    repeat
        nextState = curState.nextState(critter)

        if nextState then
            -- detect logic cycles
            if seenStates[nextState] then
                error("state cycle")
            end
            seenStates[nextState] = true

            print("nextState = "..nextState)
            critter.state = nextState
            curState = states[nextState]
            if curState.pose then
                nextPose = curState.pose
            end
        end
    until not nextState

    if nextPose then
        print("nextPose=" .. nextPose)
        setPose(poses[nextPose])
    end

    if curState.onEnterState then
        curState.onEnterState(critter)
    end
end

function love.keypressed(key, sc, isRepeat)
    if DEBUG then
        if key == "q" then
            setPose(poses.default)
        elseif key == "w" then
            setPose(poses.anxious)
        elseif key == "e" then
            setPose(poses.frustrated)
        end

        if key == "0" then
            critter.setPattern()
        end
    end
end

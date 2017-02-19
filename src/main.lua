patterns = require('patterns')

critter = {
    anxiety = 100,
    itchy = 3,
    estrus = 1,
    saturation = 1,
    hueshift = 10
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
    color = {255,255,255,255},
    opacity = 255,
    size = 5,

    drawing = false,
    x = 0,
    y = 0,
    radius = 5
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

    critter.texCoords = {
        love.graphics.newImage("assets/critter-uv1.png"),
        love.graphics.newImage("assets/critter-uv2.png")
    }
    critter.overlays = {
        love.graphics.newImage("assets/critter-overlay.png")
    }

    reduceShader = love.graphics.newShader("reduce.fs")
    remapShader = love.graphics.newShader("remap.fs")
    hueshiftShader = love.graphics.newShader("hueshift.fs")

    critter.canvas = love.graphics.newCanvas(384, 256)

    -- initialize the skin
    skin = {}

    skin.front = love.graphics.newCanvas(256, 256)
    skin.front:setFilter("nearest", "nearest")
    skin.back = love.graphics.newCanvas(256, 256)
    skin.front:setFilter("nearest", "nearest")

    skin.front:renderTo(function()
        -- set the initial pattern
        local startState = love.image.newImageData(256, 256)
        startState:mapPixel(patterns.splotchy)
        local startImage = love.graphics.newImage(startState)
        love.graphics.draw(startImage)

        love.graphics.setColor(math.random(128,255),math.random(128,255),math.random(128,255))
        love.graphics.rectangle("fill", 0, 0, 64, 64)
        love.graphics.setColor(math.random(128,255),math.random(128,255),math.random(128,255))
        love.graphics.rectangle("fill", 192, 0, 64, 64)
        love.graphics.setColor(255,255,255)
    end)

    -- initialize the jiggler texture
    skin.jigglerData = love.image.newImageData(256, 256)
    skin.jigglerImage = love.graphics.newImage(skin.jigglerData)
    skin.jigglerImage:setFilter("nearest", "nearest")
end

function love.draw()
    screen:renderTo(function()
        love.graphics.setCanvas(screen)
        love.graphics.clear(50,70,90)

        -- draw the color picker
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(colorPickerImage, 0, 0)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", colorPicker:getWidth(), 0, 32, 32)
        love.graphics.setColor(unpack(pen.color))
        love.graphics.ellipse("fill", colorPicker:getWidth() + 16, 16, pen.size, pen.size)
        love.graphics.setColor(255,255,255)

        -- draw the critter's skin preview
        love.graphics.setShader(hueshiftShader)
        hueshiftShader:send("basis", {
            critter.saturation * math.cos(critter.hueshift),
            critter.saturation * math.sin(critter.hueshift)
        })
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(skin.front, 128, 0, 0)
        love.graphics.setShader()

        -- draw the critter
        critter.canvas:renderTo(function()
            -- skin layers
            love.graphics.setBlendMode("alpha", "premultiplied")
            love.graphics.setShader(remapShader)
            remapShader:send("referred", skin.front)
            for _,tc in pairs(critter.texCoords) do
                love.graphics.draw(tc, 128, 0)
            end

            -- overlay layers
            love.graphics.setBlendMode("alpha", "alphamultiply")
            love.graphics.setShader()
            for _,ov in pairs(critter.overlays) do
                love.graphics.draw(ov, 128, 0)
            end
        end)
        love.graphics.setShader(hueshiftShader)
        hueshiftShader:send("basis", {
            critter.saturation * math.cos(critter.hueshift),
            critter.saturation * math.sin(critter.hueshift)
        })
        love.graphics.draw(critter.canvas)
        love.graphics.setShader()

        -- draw the paint overlay
        love.graphics.draw(paintOverlay)
    end)

    blitCanvas(screen)

    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 0, 0)
end

function reduceChromatophores(front, back, x, y, w, h)
    back:renderTo(function()
        love.graphics.setShader(reduceShader)
        reduceShader:send("size", {front:getWidth(), front:getHeight()})
        love.graphics.draw(front)
        love.graphics.setShader()
    end)
end

function love.update(dt)
    critter.hueshift = critter.hueshift + critter.estrus*dt

    -- jiggle the chromatophores a bit based on critter's anxiety
    if critter.anxiety > 0 then
        skin.jigglerData:mapPixel(function(x,y,r,g,b,a)
            return x,y,255,255
        end)
        for i=0,critter.anxiety do
            local sx = math.random(0,255)
            local sy = math.random(0,255)
            local dx = (sx + math.random(-critter.itchy,critter.itchy))%256
            local dy = (sy + math.random(-critter.itchy,critter.itchy))%256

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

    if (mx >= 0) and (mx < 48) and (my >= 0) and (my < 256) then
        -- color picker
        if (love.mouse.isDown(1)) then
            pen.color = {colorPicker:getPixel(mx, my)}
            pen.color[4] = pen.opacity
        end
    elseif (mx >= 48) and (mx < 48 + 32) and (my >= 0) and (my < 32) then
        -- size adjust
        if love.mouse.isDown(1) then
            local x = mx - 48 - 16
            local y = my - 16
            pen.size = math.min(16, math.sqrt(x*x + y*y))
            -- pen.size = x/2
            -- pen.opacity = 255 - y*255/32
            -- pen.color[4] = pen.opacity
        end
    elseif love.mouse.isDown(1) then
        -- paint strokes
        pen.drawing = true

        local prevRadius = pen.radius
        pen.radius = pen.size

        local prevX, prevY = pen.x, pen.y
        pen.x, pen.y = mx, my
        local deltaX = pen.x - prevX
        local deltaY = pen.y - prevY
        local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)

        if prevDrawing then
            pen.radius = pen.radius/math.max(1,distance/4)
        end

        -- paint into the paint overlay texture
        paintOverlay:renderTo(function()
            love.graphics.setColor(unpack(pen.color))

            -- draw endcap
            love.graphics.ellipse("fill", pen.x, pen.y, pen.radius, pen.radius)

            -- draw stroke
            if prevDrawing then
                local px, py = deltaY/distance, -deltaX/distance
                love.graphics.polygon("fill",
                    prevX + px*prevRadius, prevY + py*prevRadius,
                    prevX - px*prevRadius, prevY - py*prevRadius,
                    pen.x - px*pen.radius, pen.y - py*pen.radius,
                    pen.x + px*pen.radius, pen.y + py*pen.radius
                    )
            end
        end)

        -- and also copy that into the texture
        skin.front:renderTo(function()
            love.graphics.setShader(hueshiftShader)
            hueshiftShader:send("basis", {
                math.cos(-critter.hueshift),
                math.sin(-critter.hueshift)
            })
            love.graphics.setColor(255,255,255)
            love.graphics.draw(paintOverlay, 256-384, 0)
            love.graphics.setShader()
        end)
    end

    -- grab the color from the cursor position (slow, should come last)
    if love.mouse.isDown(2) then
        local foo = screen:newImageData()
        pen.color = {foo:getPixel(mx, my)}
        pen.color[4] = pen.opacity
    end
end

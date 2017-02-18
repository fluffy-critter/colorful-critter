patterns = require('patterns')

critter = {}

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
    screen = love.graphics.newCanvas(384, 256)
    screen:setFilter("nearest", "nearest")

    colorPicker = love.image.newImageData("assets/gradient.png")
    colorPickerImage = love.graphics.newImage(colorPicker)

    critter.texCoords = love.graphics.newImage("assets/critter-texcoords.png")

    reduceShader = love.graphics.newShader("reduce.fs")
    remapShader = love.graphics.newShader("remap.fs")

    skin = {}

    skin.front = love.graphics.newCanvas(256, 256)
    skin.back = love.graphics.newCanvas(256, 256)

    -- set the initial pattern
    local startState = love.image.newImageData(256, 256)
    startState:mapPixel(patterns.plaid)

    -- fill the pattern into the front buffer
    local startImage = love.graphics.newImage(startState)
    love.graphics.setCanvas(skin.front)
    love.graphics.draw(startImage)
    love.graphics.setCanvas()
end

function love.draw()
    love.graphics.setCanvas(screen)
    love.graphics.clear(50,70,90)

    -- draw the color picker
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(colorPickerImage, 0, 0)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", colorPicker:getWidth(), 0, 16, 16)
    love.graphics.setColor(unpack(pen.color))
    love.graphics.ellipse("fill", colorPicker:getWidth() + 8, 8, pen.size, pen.size)

    -- draw the critter's skin preview
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(skin.front, 128, 0, 0)

    -- draw the critter
    love.graphics.setShader(remapShader)
    remapShader:send("referred", skin.front)
    love.graphics.draw(critter.texCoords, 128, 0)
    love.graphics.setShader()

    -- blit the screen
    love.graphics.setCanvas()
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
    -- reduce front buffer into backbuffer
    reduceChromatophores(skin.front, skin.back, 0, 0, 256, 256)

    -- swap the back and front buffers
    skin.front,skin.back = skin.back,skin.front

    local mx = (love.mouse.getX() - canvasPosition.x)*canvasPosition.srcW/canvasPosition.destW
    local my = (love.mouse.getY() - canvasPosition.y)*canvasPosition.srcH/canvasPosition.destH

    -- color picker
    if (mx >= 0) and (mx < 48) and (my >= 0) and (my < 256) then
        if (love.mouse.isDown(1)) then
            pen.color = {colorPicker:getPixel(mx, my)}
        end
    end

    -- size adjust
    if (mx >= 48) and (mx < 48 + 16) and (my >= 0) and (my < 16) and love.mouse.isDown(1) then
        local x = mx - 48 - 8
        local y = my - 8
        pen.size = math.min(8, math.sqrt(x*x + y*y))
    end

    -- paint strokes
    if (mx >= 128) and (mx < 384)
        and (my >= 0)
        and (my < 256)
        and love.mouse.isDown(1) then
        local prevDrawing = pen.drawing
        pen.drawing = true

        local prevRadius = pen.radius
        pen.radius = pen.size

        local prevX, prevY = pen.x, pen.y
        pen.x, pen.y = mx - 128, my
        local deltaX = pen.x - prevX
        local deltaY = pen.y - prevY
        local distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)

        if prevDrawing then
            pen.radius = pen.radius/math.max(1,distance/4)
        end

        -- paint into the skin texture
        skin.front:renderTo(function()
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
    else
        pen.drawing = false
    end

    -- grab the color from the cursor position (slow, should come last)
    if love.mouse.isDown(2) then
        local foo = screen:newImageData()
        pen.color = {foo:getPixel(mx, my)}
    end
end

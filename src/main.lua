patterns = require('patterns')

canvasPosition = {
    x = 0,
    y = 0,
    srcW = 0,
    srcH = 0,
    destW = 0,
    destH = 0
}

pickedColor = {0,0,0,255}

critter = {
    tense = 100
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

    skin = {}

    skin.front = {}
    skin.front.data = love.image.newImageData(256, 256)
    skin.front.image = love.graphics.newImage(skin.front.data)

    skin.back = {}
    skin.back.data = love.image.newImageData(256, 256)
    skin.back.image = love.graphics.newImage(skin.back.data)

    skin.front.data:mapPixel(patterns.splotchy)
end

function chromatophoreReduce(front, back, x0, y0, w, h)
    -- this can probably be done faster using pointer stuff or maybe on-GPU
    local offsets = {{0,0},{-1,0},{1,0},{0,-1},{0,1}}
    for j = 0, h - 1 do
        for i = 0, w - 1 do
            local counts = {}
            local maxCount = 0
            local maxColor
            for _,pos in pairs(offsets) do
                local dx,dy = unpack(pos)
                local r,g,b,a = front:getPixel((i+dx)%w + x0, (j+dy)%h + y0)
                local c = r*65536 + g*256 + b
                counts[c] = (counts[c] or 0) + 1
                if counts[c] >= maxCount then
                    maxColor = {r,g,b,a}
                    maxCount = counts[c]
                end
            end
            back:setPixel(x0 + i, y0 + j, unpack(maxColor))
        end
    end
end

function love.draw()
    love.graphics.setCanvas(screen)
    love.graphics.clear(50,70,90)

    -- draw the color picker
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(colorPickerImage, 0, 0)

    love.graphics.setColor(unpack(pickedColor))
    love.graphics.rectangle("fill", colorPicker:getWidth(), 0, 16, 16)

    -- draw the critter's skin preview
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(skin.front.image, 128, 0, 0)

    -- blit the screen
    love.graphics.setCanvas()
    blitCanvas(screen)

    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 0, 0)
end

function love.update(dt)
    -- stir up the chromatophores a bit
    for i=1,critter.tense do
        local color = {skin.front.data:getPixel(math.random(0,255), math.random(0,255))}
        skin.front.data:setPixel(math.random(0,255), math.random(0,255), unpack(color))
    end

    -- reduce front buffer into backbuffer
    chromatophoreReduce(skin.front.data, skin.back.data, 0, 0, 256, 256)

    -- swap the back and front buffers
    local temp = skin.front
    skin.front = skin.back
    skin.back = temp

    -- refresh the front buffer
    skin.front.image:refresh()

    local mx = (love.mouse.getX() - canvasPosition.x)*canvasPosition.srcW/canvasPosition.destW
    local my = (love.mouse.getY() - canvasPosition.y)*canvasPosition.srcH/canvasPosition.destH

    -- is the mouse down?
    if love.mouse.isDown(1) then
        if (mx >= 0) and (mx < 48) and (my >= 0) and (my < 256) then
            -- color picker
            pickedColor = {colorPicker:getPixel(mx, my)}
        end

        if (mx >= 128) and (mx < 384) and (my >= 0) and (my < 256) then
            -- paint into the skin texture
            local lx = mx - 128
            for j = -5,5 do
                for i = -5,5 do
                    skin.front.data:setPixel((i + lx)%256, (j + my)%256, unpack(pickedColor))
                end
            end
        end
    end

    -- grab the color from the cursor position (slow)
    if love.mouse.isDown(2) then
        local foo = screen:newImageData()
        pickedColor = {foo:getPixel(mx, my)}
    end
end

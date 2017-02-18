canvasPosition = {
    x = 0,
    y = 0,
    width = 0,
    height = 0
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
end

function love.load()
    screen = love.graphics.newCanvas(384, 256)
    screen:setFilter("nearest", "nearest")

    colorPicker = love.graphics.newImage("assets/gradient.png")

    local skinTexture = love.graphics.newCanvas(256, 256)

    skin = {}

    skin.front = {}
    skin.front.data = skinTexture:newImageData()
    skin.front.image = love.graphics.newImage(skin.front.data)

    skin.back = {}
    skin.back.data = skinTexture:newImageData()
    skin.back.image = love.graphics.newImage(skin.back.data)

    skin.front.data:mapPixel(
        function(x,y,r,g,b,a)
            return (math.floor((x+y)/32)%2 + math.floor((y-x)/32)%2)*64 + 32, 32, 32, 255
        end
    )
end

function chromatophoreReduce(front, back, x0, y0, w, h)
    -- this can probably be done faster using pointer stuff
    for j = 0, h - 1 do
        for i = 0, w - 1 do
            local counts = {}
            local maxCount = 0
            local maxColor
            for dx = -1,1 do
                for dy = -1,1 do
                    local r,g,b,a = front:getPixel((i+dx)%w + x0, (j+dy)%h + y0)
                    local c = r*65536 + g*256 + b
                    counts[c] = (counts[c] or 0) + 1
                    if counts[c] >= maxCount then
                        maxColor = c
                        maxCount = counts[c]
                    end
                end
            end
            back:setPixel(x0 + i, y0 + j,
                (maxColor / 65536) % 256,
                (maxColor / 256) % 256,
                maxColor % 256)
        end
    end
end

function love.draw()
    love.graphics.setCanvas(screen)
    love.graphics.clear(50,70,90)

    -- draw the color picker
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(colorPicker, 0, 0)

    -- draw the critter's skin preview
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(skin.front.image, 64, 0, 0)

    -- blit the screen
    love.graphics.setCanvas()
    blitCanvas(screen)

    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.update(dt)
    -- stir up the chromatophores a bit
    for i=1,100 do
        skin.front.data:setPixel(math.random(0,255), math.random(0,255),
            math.random(0,255), math.random(0,255), math.random(0,255))
    end

    -- reduce front buffer into backbuffer
    chromatophoreReduce(skin.front.data, skin.back.data, 64, 0, 128, 128)

    -- swap the back and front buffers
    local temp = skin.front
    skin.front = skin.back
    skin.back = temp

    -- refresh the front buffer
    skin.front.image:refresh()
end

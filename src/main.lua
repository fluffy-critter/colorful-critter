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
    love.graphics.setCanvas(skinTexture)
    love.graphics.clear(127,0,255)
    for i = 1,100 do
        love.graphics.setColor(math.random(0,255), math.random(0,255), math.random(0,255))
        local x = math.random(0,255)
        local y = math.random(0,255)
        local r = math.random(5,16)
        for xa=-256,256,256 do
            for ya=-256,256,256 do
                love.graphics.ellipse("fill", x + xa, y + ya, r, r)
            end
        end
    end
    love.graphics.setCanvas()

    skinData = skinTexture:newImageData()
    skinImage = love.graphics.newImage(skinData)
end

function love.draw()
    love.graphics.setCanvas(screen)
    love.graphics.clear(50,70,90)

    -- draw the color picker
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(colorPicker, 0, 0)

    -- draw the critter's skin preview
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(skinImage, 64, 0, 0)

    -- blit the screen
    love.graphics.setCanvas()
    blitCanvas(screen)
end

function love.update(dt)
    for i=1,16 do
        skinData:setPixel(math.random(0,255), math.random(0,255),
            math.random(0,255), math.random(0,255), math.random(0,255))
    end

    for x=0,255 do
        for y=0,255 do
            local counts = {}
            local maxCount = 0
            local maxColor
            for dx = -1,1 do
                for dy = -1,1 do
                    local r,g,b,a = skinData:getPixel((x+dx)%256, (y+dy)%256)
                    local c = r*65536 + g*256 + b
                    counts[c] = (counts[c] or 0) + 1
                    if counts[c] >= maxCount then
                        maxColor = c
                        maxCount = counts[c]
                    end
                end
            end
            skinData:setPixel(x, y,
                (maxColor / 65536) % 256,
                (maxColor / 256) % 256,
                maxColor % 256)
        end
    end

    skinImage:refresh()
end

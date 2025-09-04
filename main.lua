local drawing = false
local bgWhite = true
local bgColor = {1, 1, 1}
local penColor = {0, 0, 0}
local canvas
local prevX, prevY

function love.load()
    love.window.setTitle("Love Board")
    love.window.setMode(1200, 800, {resizable = true})
    canvas = love.graphics.newCanvas(1200, 800)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(bgColor)
    love.graphics.setCanvas()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        drawing = true
        prevX, prevY = x, y
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        drawing = false
    end
end

function love.mousemoved(x, y, dx, dy)
    if drawing then
        love.graphics.setCanvas(canvas)
        love.graphics.setColor(penColor)
        love.graphics.setLineWidth(2)
        love.graphics.line(prevX, prevY, x, y)
        love.graphics.setCanvas()
        prevX, prevY = x, y
    end
end

function love.keypressed(key)
    if key == "d" then
        -- clear board
        love.graphics.setCanvas(canvas)
        love.graphics.clear(bgColor)
        love.graphics.setCanvas()

    elseif key == "c" then
        -- toggle background color and invert canvas
        bgWhite = not bgWhite
        if bgWhite then
            bgColor = {1, 1, 1}
            penColor = {0, 0, 0}
        else
            bgColor = {0, 0, 0}
            penColor = {1, 1, 1}
        end

        -- Invert the existing canvas
        local imgData = canvas:newImageData()
        for x = 0, imgData:getWidth()-1 do
            for y = 0, imgData:getHeight()-1 do
                local r, g, b, a = imgData:getPixel(x, y)
                r = 1 - r
                g = 1 - g
                b = 1 - b
                imgData:setPixel(x, y, r, g, b, a)
            end
        end
        canvas:renderTo(function()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(love.graphics.newImage(imgData), 0, 0)
        end)

    elseif key == "x" then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0)

    -- Instructions always contrast with background
    if bgWhite then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print("Draw with left mouse button", 20, 20)
    love.graphics.print("Press 'C' = Toggle background color", 20, 40)
    love.graphics.print("Press 'D' = Clear board | Press 'X' = Exit", 20, 60)
end







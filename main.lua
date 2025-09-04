local lines = {}       -- stores drawn lines
local drawing = false
local bgWhite = true   -- current background: true = white, false = black
local bgColor = {1, 1, 1}
local penColor = {0, 0, 0}

function love.load()
    love.window.setTitle("Love Board")
    love.window.setMode(1200, 800, {resizable = true}) -- bigger, resizable window
end

function love.mousepressed(x, y, button)
    if button == 1 then
        drawing = true
        table.insert(lines, {{x = x, y = y}})
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        drawing = false
    end
end

function love.mousemoved(x, y, dx, dy)
    if drawing then
        local currentLine = lines[#lines]
        table.insert(currentLine, {x = x, y = y})
    end
end

function love.keypressed(key)
    if key == "d" then
        -- clear board
        lines = {}

    elseif key == "c" then
        -- toggle background color
        bgWhite = not bgWhite
        if bgWhite then
            bgColor = {1, 1, 1}
            penColor = {0, 0, 0}
        else
            bgColor = {0, 0, 0}
            penColor = {1, 1, 1}
        end

    elseif key == "x" then
        -- exit program
        love.event.quit()
    end
end

function love.draw()
    love.graphics.clear(bgColor)

    love.graphics.setColor(penColor)
    for _, line in ipairs(lines) do
        for i = 2, #line do
            love.graphics.line(line[i-1].x, line[i-1].y, line[i].x, line[i].y)
        end
    end

    -- Instructions (contrast with background)
    if bgWhite then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print("Draw with left mouse button", 20, 20)
    love.graphics.print("Press 'C' = Toggle background color", 20, 40)
    love.graphics.print("Press 'D' = Clear board | Press 'X' = Exit", 20, 60)
end






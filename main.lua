local lines = {}  -- stores drawn lines
local drawing = false

function love.load()
    love.window.setTitle("Drawing Board")
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(1, 1, 1) -- white background
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- left mouse button
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
    if key == "c" then
        -- clear board
        lines = {}
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 0) -- black pen
    for _, line in ipairs(lines) do
        for i = 2, #line do
            love.graphics.line(line[i-1].x, line[i-1].y, line[i].x, line[i].y)
        end
    end

    love.graphics.setColor(0, 0, 0.5)
    love.graphics.print("Draw with left mouse button. Press 'C' to clear.", 20, 20)
end


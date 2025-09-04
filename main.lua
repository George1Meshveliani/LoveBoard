local tools = {"pen", "chalk", "marker", "line", "vector", "eraser"}
local currentTool = "pen"

local drawing = false
local startX, startY
local bgWhite = true
local bgColor = {1, 1, 1}
local penColor = {0, 0, 0}
local canvas
local prevX, prevY

local headerHeight = 90

-- Initialize canvas
function love.load()
    love.window.setTitle("Love Board")
    love.window.setMode(1200, 800, {resizable=true})
    local w, h = love.graphics.getDimensions()
    canvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(bgColor)
    love.graphics.setCanvas()
end

function love.resize(w, h)
    local oldCanvas = canvas
    canvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(bgColor)
    if oldCanvas then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(oldCanvas, 0, 0)
    end
    love.graphics.setCanvas()
end

local function toCanvasCoords(x, y)
    return x, y
end

-- Mouse pressed
function love.mousepressed(x, y, button)
    if y <= headerHeight then
        -- Tool selection in header
        local xPos = 20
        local font = love.graphics.getFont()
        for _, tool in ipairs(tools) do
            local width = font:getWidth(tool) + 20
            if x >= xPos and x <= xPos + width then
                currentTool = tool
            end
            xPos = xPos + width + 10
        end
        return
    end

    if button == 1 then
        local cx, cy = toCanvasCoords(x, y)
        drawing = true
        startX, startY = cx, cy
        prevX, prevY = cx, cy
    end
end

-- Mouse released
function love.mousereleased(x, y, button)
    if button == 1 and drawing then
        local endX, endY = toCanvasCoords(x, y)
        if currentTool == "line" or currentTool == "vector" then
            love.graphics.setCanvas(canvas)
            love.graphics.setColor(penColor)
            love.graphics.setLineWidth(2)
            love.graphics.line(startX, startY, endX, endY)

            if currentTool == "vector" then
                local dx, dy = endX - startX, endY - startY
                local angle = math.atan2(dy, dx)
                local len = 10
                love.graphics.line(endX - len*math.cos(angle - math.pi/6),
                                   endY - len*math.sin(angle - math.pi/6),
                                   endX, endY)
                love.graphics.line(endX - len*math.cos(angle + math.pi/6),
                                   endY - len*math.sin(angle + math.pi/6),
                                   endX, endY)
            end
            love.graphics.setCanvas()
        end
        drawing = false
    end
end

-- Mouse moved
function love.mousemoved(x, y, dx, dy)
    local cx, cy = toCanvasCoords(x, y)
    if drawing then
        love.graphics.setCanvas(canvas)

        if currentTool == "pen" then
            love.graphics.setColor(penColor)
            love.graphics.setLineWidth(2)
            love.graphics.line(prevX, prevY, cx, cy)
            prevX, prevY = cx, cy

        elseif currentTool == "chalk" then
            love.graphics.setColor(penColor)
            love.graphics.setLineWidth(2)
            for i=1,3 do
                local ox, oy = math.random(-1,1), math.random(-1,1)
                love.graphics.line(prevX+ox, prevY+oy, cx+ox, cy+oy)
            end
            prevX, prevY = cx, cy

        elseif currentTool == "marker" then
            love.graphics.setColor(0.9,0.2,0.2,0.5)
            love.graphics.setLineWidth(12)
            love.graphics.line(prevX, prevY, cx, cy)
            prevX, prevY = cx, cy

        elseif currentTool == "eraser" then
            love.graphics.setColor(bgColor)
            love.graphics.setLineWidth(15)
            love.graphics.line(prevX, prevY, cx, cy)
            prevX, prevY = cx, cy
        end

        love.graphics.setCanvas()
    end
end

-- Key pressed
function love.keypressed(key)
    if key == "d" then
        love.graphics.setCanvas(canvas)
        love.graphics.clear(bgColor)
        love.graphics.setCanvas()
    elseif key == "c" then
        bgWhite = not bgWhite
        if bgWhite then
            bgColor = {1,1,1}
            penColor = {0,0,0}
        else
            bgColor = {0,0,0}
            penColor = {1,1,1}
        end

        local imgData = canvas:newImageData()
        for x = 0, imgData:getWidth()-1 do
            for y = 0, imgData:getHeight()-1 do
                local r,g,b,a = imgData:getPixel(x,y)
                imgData:setPixel(x,y,1-r,1-g,1-b,a)
            end
        end
        canvas:renderTo(function()
            love.graphics.setColor(1,1,1)
            love.graphics.draw(love.graphics.newImage(imgData),0,0)
        end)
    elseif key == "x" then
        love.event.quit()
    end
end

-- Draw function
function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(canvas,0,0)

    -- Fancy gradient header
    local width = love.graphics.getWidth()
    for i=0, headerHeight do
        local t = i/headerHeight
        love.graphics.setColor(0.2 + 0.3*t, 0.4 + 0.3*t, 0.7 - 0.2*t)
        love.graphics.rectangle("fill", 0, i, width, 1)
    end

    -- Tool buttons
    local font = love.graphics.getFont()
    local xPos = 20
    local baseColor = {0.2,0.6,0.9}
    for _, tool in ipairs(tools) do
        local textWidth = font:getWidth(tool) + 20
        if tool == currentTool then
            love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3])
        else
            love.graphics.setColor(baseColor[1]*0.7, baseColor[2]*0.7, baseColor[3]*0.7)
        end
        love.graphics.rectangle("fill", xPos, 20, textWidth, 40)
        love.graphics.setColor(1,1,1)
        love.graphics.print(tool, xPos + 10, 30)
        xPos = xPos + textWidth + 10
    end

    -- Instructions top-right
    local instructions = "D = Clear | C = Toggle BG | X = Exit"
    local textWidth = font:getWidth(instructions)
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.print(instructions, width - textWidth - 20, 30)

    -- Preview line/vector while drawing
    if drawing and (currentTool=="line" or currentTool=="vector") then
        local mx, my = toCanvasCoords(love.mouse.getPosition())
        love.graphics.setColor(penColor)
        love.graphics.setLineWidth(2)
        love.graphics.line(startX, startY, mx, my)

        if currentTool=="vector" then
            local dx = mx - startX
            local dy = my - startY
            local angle = math.atan2(dy, dx)
            local len = 10
            love.graphics.line(mx - len*math.cos(angle - math.pi/6),
                               my - len*math.sin(angle - math.pi/6),
                               mx, my)
            love.graphics.line(mx - len*math.cos(angle + math.pi/6),
                               my - len*math.sin(angle + math.pi/6),
                               mx, my)
        end
    end
end























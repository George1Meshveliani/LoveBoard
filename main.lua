local tools = {"pen", "chalk", "marker", "line", "vector", "eraser"} -- added "marker"
local currentTool = "pen"

local drawing = false
local startX, startY
local bgWhite = true
local bgColor = {1, 1, 1}
local penColor = {0, 0, 0}
local canvas
local prevX, prevY

local headerHeight = 80

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

-- Resize canvas
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

-- Convert screen coordinates to canvas coordinates
local function toCanvasCoords(x, y)
    return x, y
end

-- Mouse pressed
function love.mousepressed(x, y, button)
    if y <= headerHeight then
        local iconSize = 40
        for i, tool in ipairs(tools) do
            local iconX = 20 + (i-1)*(iconSize+10)
            if x >= iconX and x <= iconX + iconSize then
                currentTool = tool
            end
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
                local dx = endX - startX
                local dy = endY - startY
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
    if drawing then
        local cx, cy = toCanvasCoords(x, y)
        love.graphics.setCanvas(canvas)

        if currentTool == "eraser" then
            love.graphics.setColor(bgColor)
            love.graphics.setLineWidth(15)
            love.graphics.line(prevX, prevY, cx, cy)

        elseif currentTool == "chalk" then
            love.graphics.setColor(penColor)
            love.graphics.setLineWidth(2)
            for i=1,3 do
                local offsetX = math.random(-1,1)
                local offsetY = math.random(-1,1)
                love.graphics.line(prevX+offsetX, prevY+offsetY, cx+offsetX, cy+offsetY)
            end

        elseif currentTool == "marker" then
            love.graphics.setColor(penColor[1], penColor[2], penColor[3], 0.5) -- semi-transparent
            love.graphics.setLineWidth(12)
            love.graphics.line(prevX, prevY, cx, cy)

        else -- regular pen
            love.graphics.setColor(penColor)
            love.graphics.setLineWidth(2)
            love.graphics.line(prevX, prevY, cx, cy)
        end

        love.graphics.setCanvas()
        prevX, prevY = cx, cy
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

-- Draw
function love.draw()
    -- Draw canvas
    love.graphics.setColor(1,1,1)
    love.graphics.draw(canvas,0,0)

    -- Fancy header gradient
    local width = love.graphics.getWidth()
    for i=0, headerHeight do
        local t = i/headerHeight
        love.graphics.setColor(0.2 + 0.3*t, 0.4 + 0.3*t, 0.7 - 0.2*t)
        love.graphics.rectangle("fill", 0, i, width, 1)
    end

    -- Tool icons
    local iconSize = 40
    for i, tool in ipairs(tools) do
        local iconX = 20 + (i-1)*(iconSize+10)
        if tool == currentTool then
            love.graphics.setColor(0.1,0.8,1)
        else
            love.graphics.setColor(0.3,0.3,0.3)
        end
        love.graphics.rectangle("fill", iconX, 20, iconSize, iconSize)
        love.graphics.setColor(1,1,1)
        love.graphics.print(tool, iconX+5,30)
    end

    -- Instructions top-right
    local instructions = "D = Clear | C = Toggle BG | X = Exit"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(instructions)
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.print(instructions, width - textWidth - 20, 30)

    -- Preview line/vector
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





















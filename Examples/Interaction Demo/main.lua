local scalify = require "scalify"
local love = require "love"

local buttons = {
    {x = 300, y = 200, width = 200, height = 60, text = "Click Me!", clicked = false}
}

function love.load()
    scalify:setupScreen(800, 600, 1280, 720, {resizable = true})
end

function love.draw()
    scalify:start()

    for _, btn in ipairs(buttons) do
        love.graphics.setColor(btn.clicked and {0, 1, 0} or {1, 0, 0})
        love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(btn.text, btn.x, btn.y + 20, btn.width, "center")
    end

    scalify:finish()
end

function love.mousepressed(x, y, button)
    local gx, gy = scalify:toGame(x, y)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if gx and gy and gx > btn.x and gx < btn.x + btn.width and gy > btn.y and gy < btn.y + btn.height then
                btn.clicked = not btn.clicked
            end
        end
    end
end

function love.resize(w, h)
    scalify:resize(w, h)
end
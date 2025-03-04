local scalify = require "scalify"
local love = require "love"

local ball = {x = 400, y = 300, radius = 20, speedX = 200, speedY = 150}

function love.load()
    scalify:setupScreen(800, 600, 1280, 720, {resizable = true})
end

function love.update(dt)
    ball.x = ball.x + ball.speedX * dt
    ball.y = ball.y + ball.speedY * dt

    -- Wall collision
    if ball.x - ball.radius < 0 or ball.x + ball.radius > scalify:getWidth() then
        ball.speedX = -ball.speedX
    end
    if ball.y - ball.radius < 0 or ball.y + ball.radius > scalify:getHeight() then
        ball.speedY = -ball.speedY
    end
end

function love.draw()
    scalify:start()
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    
    scalify:finish()
end

function love.resize(w, h)
    scalify:resize(w, h)
end
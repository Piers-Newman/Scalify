local scalify = require "scalify"

-- GLSL Shader Code
local shaderCode = [[
    extern float time;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        float wave = sin(texture_coords.y * 10.0 + time) * 0.03; 
        vec4 texColor = Texel(texture, texture_coords + vec2(wave, 0));
        return texColor * color;
    }
]]

local shader

function love.load()
    love.window.Width = 800
    love.window.Height = 600
    scalify:setupScreen(800, 600, 1280, 720, {resizable = true, canvas = true})
    
    -- Load the shader
    shader = love.graphics.newShader(shaderCode)
end

function love.update(dt)
    shader:send("time", love.timer.getTime()) -- Send time to shader
end

function love.draw()
    -- Start rendering with scalify (renders to _render canvas)
    scalify:start()
    love.graphics.setShader(shader)

    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", 200, 150, 400, 300)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Wavy Effect!", 250, 270)

    scalify:finish()

    local renderCanvas = scalify:getCanvasTable("_render").canvas

    love.graphics.draw(renderCanvas, 0, 0)
    love.graphics.setShader() -- Reset shader
end

function love.resize(w, h)
    scalify:resize(w, h)
end
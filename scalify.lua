-- scalify.lua v1.0

-- Copyright (c) 2024 Piers-Newman
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- This project if a fork of "Push" by "Ulysse Ramage" found at: https://github.com/Ulydev/push/tree/master

local love11 = love.getVersion() == 11
local getDPI = love11 and love.window.getDPIScale or love.window.getPixelScale
local windowUpdateMode = love11 and love.window.updateMode or function(width, height, settings)
  local _, _, flags = love.window.getMode()
  for k, v in pairs(settings) do flags[k] = v end
  love.window.setMode(width, height, flags)
end

local scalify = {
  defaults = {
    fullscreen = false,
    resizable = false,
    pixelperfect = false,
    highdpi = true,
    canvas = true,
    stencil = true
  },
  canvases = {},
  _borderColor = {0, 0, 0}
}

function scalify:applySettings(settings)
  for k, v in pairs(settings) do self["_" .. k] = v end
end

function scalify:resetSettings()
  self:applySettings(self.defaults)
end

function scalify:setupScreen(WWIDTH, WHEIGHT, RWIDTH, RHEIGHT, settings)
  settings = settings or {}
  self._WWIDTH, self._WHEIGHT, self._RWIDTH, self._RHEIGHT = WWIDTH, WHEIGHT, RWIDTH, RHEIGHT
  self:resetSettings()
  self:applySettings(settings)
  
  local currentWidth, currentHeight, flags = love.window.getMode()

  if currentWidth ~= self._RWIDTH or currentHeight ~= self._RHEIGHT
    or flags.fullscreen ~= self._fullscreen
    or flags.resizable ~= self._resizable then

    love.window.setMode(self._RWIDTH, self._RHEIGHT, {
    fullscreen = self._fullscreen,
    resizable = self._resizable,
    highdpi = self._highdpi
    })
  end
  
  self:initValues()
  if self._canvas then self:setupCanvas({ "default" }) end
  return self
end

function scalify:setupCanvas(canvases)
  self._canvas = true
  self.canvases = {}
  table.insert(canvases, { name = "_render", private = true })
  for _, params in ipairs(canvases) do self:addCanvas(params) end
end

function scalify:addCanvas(params)
  self.canvases[#self.canvases + 1] = {
    name = params.name,
    private = params.private,
    shader = params.shader,
    canvas = love.graphics.newCanvas(self._WWIDTH, self._WHEIGHT),
    stencil = params.stencil or self._stencil,
    retain = params.retain
  }
end

function scalify:setCanvas(name)
  if not self._canvas then return true end
  local canvasTable = self:getCanvasTable(name)
  if not canvasTable then return false end
  return love.graphics.setCanvas({ canvasTable.canvas, stencil = canvasTable.stencil })
end

function scalify:getCanvasTable(name)
  for _, canvas in ipairs(self.canvases) do
    if canvas.name == name then return canvas end
  end
  return nil
end

function scalify:setShader(name, shader)
  if type(name) ~= "string" then
    shader = name
    name = "_render"
  end
  name = name or "_render"
  local canvasTable = self:getCanvasTable(name)
  if canvasTable then
    canvasTable.shader = shader
  end
end

function scalify:initValues()
  self._PSCALE = (not love11 and self._highdpi) and getDPI() or 1
  self._SCALE = {
    x = self._RWIDTH / self._WWIDTH * self._PSCALE,
    y = self._RHEIGHT / self._WHEIGHT * self._PSCALE
  }
  local scale = math.min(self._SCALE.x, self._SCALE.y)
  if self._pixelperfect then scale = math.floor(scale) end
  self._OFFSET = {x = (self._SCALE.x - scale) * (self._WWIDTH / 2), y = (self._SCALE.y - scale) * (self._WHEIGHT / 2)}
  self._SCALE.x, self._SCALE.y = scale, scale
  self._GWIDTH = self._RWIDTH * self._PSCALE - self._OFFSET.x * 2
  self._GHEIGHT = self._RHEIGHT * self._PSCALE - self._OFFSET.y * 2
end

function scalify:start()
  if self._canvas then
    love.graphics.push()
    love.graphics.setCanvas({ self.canvases[1].canvas, stencil = self.canvases[1].stencil })
  else
    love.graphics.translate(self._OFFSET.x, self._OFFSET.y)
    love.graphics.setScissor(self._OFFSET.x, self._OFFSET.y, self._WWIDTH * self._SCALE.x, self._WHEIGHT * self._SCALE.y)
    love.graphics.push()
    love.graphics.scale(self._SCALE.x, self._SCALE.y)
  end
end

function scalify:applyShaders(canvas, shader)
  local _shader = love.graphics.getShader()
  if shader then
    love.graphics.setShader(shader)
  end
  love.graphics.draw(canvas)
  love.graphics.setShader(_shader)
end

function scalify:finish()
  love.graphics.setBackgroundColor(unpack(self._borderColor))
  if self._canvas then
    local _render = self:getCanvasTable("_render")
    if not _render then return end
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas(_render.canvas)
    for _, canvas in ipairs(self.canvases) do
      if not canvas.private then
        self:applyShaders(canvas.canvas, canvas.shader)
      end
    end
    love.graphics.setCanvas()
    love.graphics.translate(self._OFFSET.x, self._OFFSET.y)
    love.graphics.push()
    love.graphics.scale(self._SCALE.x, self._SCALE.y)
    self:applyShaders(_render.canvas, _render.shader)
    love.graphics.pop()
    for _, canvas in ipairs(self.canvases) do
      if not self.canvases[i].retain then
        love.graphics.setCanvas(self.canvases[i].canvas)
        love.graphics.clear()
      end
    end
    love.graphics.setCanvas()
    love.graphics.setShader()
  else
    love.graphics.pop()
    love.graphics.setScissor()
  end
end

function scalify:setBorderColor(color, g, b)
  self._borderColor = g and {color, g, b} or color
end

function scalify:resize(w, h)
  if self._highdpi then w, h = w / self._PSCALE, h / self._PSCALE end
  self._RWIDTH, self._RHEIGHT = w, h
  self:initValues()
end

function push:switchFullscreen(winw, winh)
  self._fullscreen = not self._fullscreen
  local _, _, flags = love.window.getMode()
  local desktopWidth, desktopHeight = love.window.getDesktopDimensions(flags.display)

  if self._fullscreen then
    self._WINWIDTH, self._WINHEIGHT = self._RWIDTH, self._RHEIGHT
  elseif not self._WINWIDTH or not self._WINHEIGHT then
    self._WINWIDTH, self._WINHEIGHT = desktopWidth * .5, desktopHeight * .5
  end

  self._RWIDTH = self._fullscreen and desktopWidth or winw or self._WINWIDTH
  self._RHEIGHT = self._fullscreen and desktopHeight or winh or self._WINHEIGHT

  self:initValues()

  local windowWidth, windowHeight = love.window.getMode()
  if not self._fullscreen and (windowWidth~=self._RWIDTH or windowHeight~=self._RHEIGHT) then
    windowUpdateMode(self._RWIDTH, self._RHEIGHT)
  end
end

function scalify:toGame(x, y)
  x, y = x - self._OFFSET.x, y - self._OFFSET.y
  local normalX, normalY = x / self._GWIDTH, y / self._GHEIGHT

  local gameX = normalX * self._WWIDTH
  local gameY = normalY * self._WHEIGHT

  if gameX < 0 or gameX > self._WWIDTH then gameX = nil end
  if gameY < 0 or gameY > self._WHEIGHT then gameY = nil end

  return gameX, gameY
end

function scalify:toReal(x, y)
  local realX = self._OFFSET.x + (self._GWIDTH * x)/self._WWIDTH
  local realY = self._OFFSET.y + (self._GHEIGHT * y)/self._WHEIGHT
  return realX, realY
end

function scalify:getWidth() return self._WWIDTH end
function scalify:getHeight() return self._WHEIGHT end
function scalify:getDimensions() return self._WWIDTH, self._WHEIGHT end

return scalify

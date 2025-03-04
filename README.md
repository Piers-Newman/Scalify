# Scalify

Scalify is a fork of the pre-existing resolution handler Push which is init of itself a LÖVE (Love2D) library that provides an easy way to handle resolution scaling and high-DPI rendering. It allows developers to set up a game screen with different window modes, manage canvases for rendering, and apply shaders efficiently.

## Features
- **Automatic resolution scaling**
- **Pixel-perfect rendering support**
- **Customizable window settings (fullscreen, resizable, high-DPI, etc.)**
- **Canvas management for shader applications**
- **Conversion between game and real-world coordinates**

## Installation
Simply include `scalify.lua` in your LÖVE project and require it:

```lua
local scalify = require("scalify")
```

## Usage
### Setting up the screen
```lua
scalify:setupScreen(800, 600, 1280, 720, { fullscreen = false, resizable = true })
```
- `800, 600`: Internal game resolution
- `1280, 720`: Window resolution
- `{ fullscreen = false, resizable = true }`: Optional settings

### Managing Canvases
```lua
scalify:setupCanvas({ { name = "background" }, { name = "game" } })
```
Switch to a specific canvas:
```lua
scalify:setCanvas("game")
```
Reset to the default rendering canvas:
```lua
scalify:finish()
```

### Scaling & Coordinate Conversion
Convert screen coordinates to game world coordinates:
```lua
local gameX, gameY = scalify:toGame(love.mouse.getX(), love.mouse.getY())
```
Convert game coordinates back to real screen coordinates:
```lua
local realX, realY = scalify:toReal(400, 300)
```

### Handling Resizing
To handle window resizes dynamically:
```lua
function love.resize(w, h)
    scalify:resize(w, h)
end
```


## Contributions
Contributions are welcome! Feel free to submit issues and pull requests to improve Scalify.

## Getting Started
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/scalify.git
   cd scalify
   ```
2. Include `scalify.lua` in your LÖVE project.
3. Follow the usage guide to integrate it into your game.

---

Scalify is designed to make resolution handling in LÖVE easier and more flexible. If you have any questions or suggestions, feel free to reach out!

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local world = {}
local screen_w
local screen_h
local amplitude = 15
local scale = 100
local sun = {}
local sky = {}

local function normalize(value, min, max)
    return (value - min) / (max - min)
end

function world.normalize()
    -- for l = 1, #world.data do
    --     for c = 1, #world.data[l] do
    --         world.data[l][c] = normalize(world.data[l][c], world.min, world.max)
    --     end
    -- end
    for c = 1, #world.data do
        world.data[c] = normalize(world.data[c], world.min, world.max)
    end
end

function world.gen(seed, amplitude, scale)
    world.seed = seed
    world.amplitude = amplitude
    world.data = {}
    world.min = 0
    world.max = 0
    -- for l = 1, screen_h do
    --     world.data[l] = {}
    --     for c = 1, screen_w do
    --         local noise = love.math.noise((c + seed) / scale, (l + seed) / scale)
    --         world.data[l][c] = noise
    --         if noise < world.min or world.min == 0 then world.min = noise end
    --         if noise > world.max then world.max = noise end
    --     end
    -- end
    for c = 1, screen_w do
        local noise = love.math.noise((c + 0) / scale, seed / scale)
         world.data[c] = noise
        if noise < world.min or world.min == 0 then world.min = noise end
        if noise > world.max then world.max = noise end
    end
    world.normalize()
end

function world.draw()
    -- for l = 1, #world.data, 4 do
    --     for c = 1, #world.data[l], 4 do
    --         love.graphics.points(c, l + (world.data[l][c] * world.amplitude))
    --     end
    -- end
    for c = 1, #world.data do
        local gradiant = 0.05
        local y = (screen_h -200) + (world.data[c] * world.amplitude)
        for l = y, screen_h do
            gradiant = gradiant + 0.001
            love.graphics.setColor((0.38 * sun.luminosity) - gradiant, (0.80 * sun.luminosity) - gradiant, (0.94 * sun.luminosity) - gradiant, 1)
            love.graphics.points(c, l)
        end
    end
end

function sun.load()
    sun.x = 0
    sun.y = 0
    sun.radius = 50
    sun.progress = 0
    sun.curve = love.math.newBezierCurve({-50, screen_h, screen_w / 2, -500, screen_w + 50, screen_h})
    sun.speed = 0.1
    sun.luminosity = 0
end

function sun.set_luminosity(dt)
    sun.luminosity = sun.luminosity + (sun.speed * 2 * dt)
    if sun.progress > 0.5 then
        sun.luminosity = sun.luminosity - (sun.speed * 2 * dt) * 2
    end
end

function sun.update(dt)
    sun.progress = sun.progress + sun.speed * dt
    if sun.progress > 1 then
        sun.progress = 0
    end
    sun.x, sun.y = sun.curve:evaluate(sun.progress)
    sun.set_luminosity(dt)
end

function sun.draw()
    -- soleil
    love.graphics.setColor(0.8, 0.8, 0, 1)
    love.graphics.circle("fill", sun.x, sun.y, sun.radius)
end

function sky.load()
    sky.canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(sky.canvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")
    local gradiant = 0.05
    for y = 1, screen_h do
        -- ciel
        gradiant = gradiant + 0.001
        love.graphics.setColor(0.17 + gradiant, 0.54 + gradiant, 0.91 + gradiant, 1)
        love.graphics.line(0, y, screen_w, y)
    end
    love.graphics.setCanvas()
end

function sky.draw()
    love.graphics.setColor(sun.luminosity, sun.luminosity, sun.luminosity, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(sky.canvas)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    screen_w = love.graphics.getWidth()
    screen_h = love.graphics.getHeight()
    world.gen(0, amplitude, scale)
    sky.load()
    sun.load()
end

function love.update(dt)
    world.gen(world.seed + 50 * dt, amplitude, scale)
    sun.update(dt)
end

function love.draw()
    sky.draw()
    sun.draw()
    world.draw()
end
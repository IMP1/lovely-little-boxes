local Scene = {}
Scene.__index = Scene

function Scene.new()
    local this = {}
    setmetatable(this, Scene)
    return this
end

function Scene:load()
    -- stub
end

function Scene:update(dt)
    -- stub
end

function Scene:press(mx, my)
    -- stub
end

function Scene:drag(mx, my, dx, dy)
    -- stub
end

function Scene:drop(mx, my)
    -- stub
end

function Scene:zoom(scale)
    -- stub
end

function Scene:keypressed(key)
    -- stub
end

function Scene:draw()
    -- stub
end

return Scene
local Button = {}
Button.__index = Button

function Button.new(options)
    local this = {}
    setmetatable(this, Button)
    this.position = options.position or {0, 0}
    this.size     = options.size     or {128, 32}
    this.action   = options.onclick  or function() end
    this.text     = options.text     or ""
    return this
end

function Button:isMouseOver(mx, my)
    local x, y = unpack(self.position)
    local w, h = unpack(self.size)
    return mx > x and mx < x + w and my > y and my < y + h
end

function Button:mousepressed(mx, my)
    if self:isMouseOver(mx, my) then
        self:press()
    end
end

function Button:press()
    self:action()
end

function Button:draw()
    local x, y = unpack(self.position)
    local w, h = unpack(self.size)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
    love.graphics.printf(self.text, x, y + 8, w, "center")
end

return Button
local MapEditor = require "mapeditor"

local Foe = MapEditor:extend()

function Foe:new(in_control)
	self.in_control = in_control
end

function Foe:update(dt)
	Foe.super.update(self, dt)
end

function Foe:draw()
	Foe.super.draw(self)
end

return Foe

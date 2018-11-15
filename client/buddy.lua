local MapEditor = require "mapeditor"

local Buddy = MapEditor:extend()

function Buddy:new(in_control)
	Buddy.super.new(self)
	self.in_control = in_control
end

function Buddy:update(dt)
	Buddy.super.update(self, dt)
end

function Buddy:draw(camera)
	Buddy.super.draw(self,camera)
end

function Buddy:mousereleased(x,y,button)
	Buddy.super.mousereleased(self, x,y,button)
end

return Buddy

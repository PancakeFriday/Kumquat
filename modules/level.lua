local LevelBlock = require "levelblock"

local Level = Object:extend()

function Level:new(w,h,isserver)
	isserver = isserver or false
	self.w = w
	self.h = h
	self.objects = {}
	self.enemies = {}
end

function Level:newObject(t,x,y,w,h,isserver)
	table.insert(self.objects, LevelBlock(t,x,y,w,h,isserver))
end

function Level:getData()
	local objects = {}
	for i,o in pairs(self.objects) do
		table.insert(objects, o:getData())
	end

	return {
		w=self.w,
		h=self.h,
		objects=objects,
		--enemies=self.enemies
	}
end

function Level:draw()
	for i,o in pairs(self.objects) do
		o:draw()
	end
end

return Level

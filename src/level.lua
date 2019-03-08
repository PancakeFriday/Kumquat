local LevelScreen = require "levelscreen"
local LevelBlock = require "levelblock"
local LevelObstacle = require "levelobstacle"
local Crystal = require "crystal"

local Level = Object:extend()

function Level:new(w,h)
	self.w = w
	self.h = h
	self.objects = {}
	self.enemies = {}
	self.crystals = {}

	self:createMap()
end

function Level:recreate_from_data(data)
	self.w = data.w
	self.h = data.h
	self.objects = {}
	for i,v in pairs(data.objects) do
		self:newObject(v.type,v.x,v.y,v.w,v.h)
	end
	self.map = {}
	for i,v in pairs(data.mapdata) do
		table.insert(self.map, LevelScreen(v.x,v.y,v.neighbors))
	end
	self.crystals = data.crystals
end

function Level:createMap()
	local num_screens = 1
	local screen = LevelScreen()
	self.map = {screen}
end

function Level:addScreenAt(x,y)
	if not self:isScreenAtPos(x,y) then
		local neighbors = {}
		for i,v in pairs({right={x+1,y},left={x-1,y},bottom={x,y+1},top={x,y-1}}) do
			neighbors[i] = self:isScreenAtPos(v[1],v[2])
		end
		screen = LevelScreen(x,y,neighbors)
		table.insert(self.map, screen)
	end
end

function Level:isScreenAtPos(x,y)
	x = math.floor(x)
	y = math.floor(y)
	for i,v in pairs(self.map) do
		if v.x == x and v.y == y then
			return true
		end
	end
	return false
end

function Level:getBounds()
	local minx, miny, maxx, maxy = 1000, 1000, -1000, -1000
	for i,v in pairs(self.map) do
		minx = math.min(minx, v.x)
		miny = math.min(miny, v.y)
		maxx = math.max(maxx, v.x)
		maxy = math.max(maxy, v.y)
	end
	return minx, miny, maxx, maxy
end

function Level:newObject(t,x,y,w,h)
	if lume.find({"grass"}, t) then
		table.insert(self.objects, LevelBlock(t,x,y,w,h))
	elseif lume.find({"saw"}, t) then
		table.insert(self.objects, LevelObstacle(t,x,y,w,h))
	end
end

function Level:get_data()
	local objects = {}
	for i,o in pairs(self.objects) do
		table.insert(objects, o:getData())
	end

	local mapdata = {}
	for i,v in pairs(self.map) do
		table.insert(mapdata, {
			x=v.x, y=v.y, neighbors=v.neighbors
		})
	end

	return {
		w=self.w,
		h=self.h,
		objects=objects,
		mapdata=mapdata,
		crystals=crystals
	}
end

function Level:update(dt)
	for i,v in pairs(self.objects) do
		if v.update then
			v:update(dt)
		end
	end
end

function Level:draw()
	for i,o in pairs(self.objects) do
		o:draw()
	end
end

return Level

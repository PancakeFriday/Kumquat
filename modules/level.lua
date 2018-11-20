local LevelScreen = require "levelscreen"
local LevelBlock = require "levelblock"
local LevelObstacle = require "levelobstacle"
local Crystal = require "crystal"

local Level = Object:extend()

function Level:new(w,h,isserver)
	isserver = isserver or false
	self.w = w
	self.h = h
	self.objects = {}
	self.enemies = {}
	self.crystals = {}

	if isserver then
		self:createMap()
		self:createCrystals()
	end
end

function Level:createMap()
	local num_screens = 1
	local screen = LevelScreen()
	self.map = {screen}

	local map_it = 1
	while num_screens < 20 do
		::get_new_screen::
		screen = self.map[map_it]
		local new_screen, dir = screen:newNeighbor()
		if new_screen == false then
			map_it = map_it-1
			goto get_new_screen
		end
		for i,v in pairs(self.map) do
			if new_screen.x == v.x and new_screen.y == v.y then
				screen.neighbors[dir] = true
				goto get_new_screen
			end
		end
		screen = new_screen
		map_it = map_it + 1
		num_screens = num_screens + 1
		table.insert(self.map, map_it, screen)
	end
end

function Level:createCrystals()
	local copy_map = lume.clone(self.map)
	for i=1,5 do
		local screen = lume.randomchoice(copy_map)
		lume.remove(copy_map, screen)
		local x = (screen.x+0.5)*SCREENW
		local y = (screen.y+0.5)*SCREENH
		table.insert(self.crystals, Crystal(x,y,i,true))
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

function Level:applyMap(mapdata)
	self.shapes = {}
	local HC = require "HC"
	local screenw, screenh = love.graphics.getWidth()/3, love.graphics.getHeight()/3
	self.map = {}
	for i,v in pairs(mapdata) do
		table.insert(self.map, LevelScreen(v.x,v.y,v.neighbors))
	end
end

function Level:applyCrystals(crystals)
	self.crystals = {}
	for i,v in pairs(crystals) do
		table.insert(self.crystals, Crystal(v.x,v.y,v.id,false))
	end
end

function Level:newObject(t,x,y,w,h,isserver)
	if lume.find({"grass"}, t) then
		table.insert(self.objects, LevelBlock(t,x,y,w,h,isserver))
	elseif lume.find({"saw"}, t) then
		table.insert(self.objects, LevelObstacle(t,x,y,w,h,isserver))
	end
end

function Level:getData()
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

	local crystals = {}
	for i,v in pairs(self.crystals) do
		table.insert(crystals, {
			x=v.x,y=v.y,id=v.id
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
	for i,v in pairs(self.crystals) do
		v:update(dt)
	end
end

function Level:draw()
	for i,o in pairs(self.objects) do
		o:draw()
	end
	for i,v in pairs(self.crystals) do
		v:draw()
	end
	if DEV_DRAW then
		for i,v in pairs(self.shapes) do
			v:draw()
		end
	end
end

return Level

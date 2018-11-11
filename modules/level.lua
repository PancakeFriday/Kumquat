local LevelBlock = require "levelblock"

local Level = Object:extend()

function Level:new(w,h,isserver)
	isserver = isserver or false
	self.w = w
	self.h = h
	self.objects = {}
	self.enemies = {}

	if not isserver then
		local Colorpalette = require "colorpalette"
		local dark_colors = {
			{0.,0.05,0.05},
			{0.7,0.12,0.86},
			{0.1,0.7,0.8},
			{1.0,0.17,0.51},
			{0.6,0.3,0.3},
			{0.7,0.4,0.9},
			{0.2,0.0,0.0},
			{0.5,0.9,0.7}
		}
		local light_colors = {
			{0.24,0.19,0.07},
			{0.12,0.45,0.12},
			{0.29,0.64,0.29},
			{0.25,0.13,0.04},
			{0.6,0.3,0.3},
			{0.7,0.4,0.9},
			{0.2,0.0,0.0},
			{0.5,0.9,0.7}
		}
		self.palettes = {}
		local num_steps = 50
		for i=0,num_steps-1 do
			local int_colors = {}
			for j=1,#dark_colors do
				local c = {}
				for k=1,3 do
					c[k] = lume.lerp(dark_colors[j][k],light_colors[j][k],i/(num_steps-1))
				end
				table.insert(int_colors, c)
			end
			table.insert(self.palettes, Colorpalette(unpack(int_colors)))
		end
		self.palette_pos = 1
	end
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
	if love.keyboard.isDown("l") then
		self.palette_pos = math.min(#self.palettes, self.palette_pos+1)
	end
	if love.keyboard.isDown("d") then
		self.palette_pos = math.max(1, self.palette_pos-1)
	end
	love.graphics.setShader(self.palettes[self.palette_pos].shader)
	for i,o in pairs(self.objects) do
		o:draw()
	end
	love.graphics.setShader()
end

return Level

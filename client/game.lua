local Moonshine = require 'moonshine'

local Player = require "player"
local Buddy = require "buddy"
local Foe = require "foe"
local Level = require "level"
local Gamera = require "gamera"

local Game = Object:extend()

function Game:new(players, level_data)
	self.players = {}
	if players then
		for role,v in pairs(players) do
			if role == "player" then
				self.players[role] = Player(5,0,v.isself)
			elseif role == "buddy" then
				self.players[role] = Buddy(v.isself)
			elseif role == "foe" then
				self.players[role] = Foe(v.isself)
			end
		end
	else
		connect_to_server("localhost")
		self.players["player"] = Player(0,0,true)
	end

	if self.players["player"].in_control then
		self.effect = Moonshine(Moonshine.effects.colorize)
			.chain(Moonshine.effects.chromasep)
			.chain(Moonshine.effects.crt)
			.chain(Moonshine.effects.scanlines)
			.chain(Moonshine.effects.vignette)

		self.effect.chromasep.angle = math.pi/2
		self.effect.chromasep.radius = 1.5
		self.effect.crt.feather = 0.01
		self.effect.crt.distortionFactor = {1.06,1.08}
		self.effect.scanlines.opacity = 0.2
		self.effect.vignette.opacity = 0.2
	else
		self.effect = Moonshine(Moonshine.effects.colorize)
	end

	self.level = Level(level_data.w, level_data.h)

	for i,o in pairs(level_data.objects) do
		self.level:newObject(o.type, o.x, o.y, o.w, o.h)
	end

	self.players["buddy"]:setLevel(self.level)

	self.camera = Gamera.new(0,0, 2000, 2000)
	if self.players["player"].in_control then
		self.camera:setScale(3,3)
	else
		self.camera:setScale(2,2)
		self.camera:setPosition(self.players["player"].x, self.players["player"].y)
	end

	self.bg_image = love.graphics.newImage("img/bg.png")
	self.bg_image:setWrap("repeat", "repeat")

	self.bg_quad = love.graphics.newQuad(0, 0, 2000, 2000, self.bg_image:getWidth(), self.bg_image:getHeight())

	local dark_colors = {
		{0.,0.05,0.05},
		{0.7,0.12,0.86},
		{0.1,0.7,0.8},
		{1.0,0.17,0.51},
		{0.6,0.3,0.3},
		{0.7,0.4,0.9},
		{0.05,0.0,0.05},
		{1.,1.,1.}
	}
	local light_colors = {
		{0.36,0.29,0.20},
		{0.12,0.45,0.12},
		{0.29,0.64,0.29},
		{0.51,0.35,0.20},
		{0.6,0.3,0.3},
		{0.7,0.4,0.9},
		{0.35,0.68,0.72},
		{1.,1.,1.}
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
		table.insert(self.palettes, int_colors)
	end
	self.palette_pos = 1

	self:registerCallbacks()
end

function Game:registerCallbacks()
	Client:on("new_level_object", function(obj_vars)
		self.level:newObject(obj_vars["obj_prop"], obj_vars["x"], obj_vars["y"],
			obj_vars["w"], obj_vars["h"])
	end)
end

function Game:update(dt)
	for i,v in pairs(self.players) do
		if v.in_control then
			v:update(dt)
		end
	end
end

function Game:draw()
	if love.keyboard.isDown("l") then
		self.palette_pos = math.min(#self.palettes, self.palette_pos+1)
	end
	if love.keyboard.isDown("d") then
		self.palette_pos = math.max(1, self.palette_pos-1)
	end

	if self.players["player"].in_control then
		self.camera:setPosition(self.players["player"].x, self.players["player"].y)
	end
	if self.players["buddy"].in_control then
		self.camera:setPosition(self.players["buddy"].x, self.players["buddy"].y)
	end

	-- This is shite
	self.effect.colorize.color1 = self.palettes[self.palette_pos][1]
	self.effect.colorize.color2 = self.palettes[self.palette_pos][2]
	self.effect.colorize.color3 = self.palettes[self.palette_pos][3]
	self.effect.colorize.color4 = self.palettes[self.palette_pos][4]
	self.effect.colorize.color5 = self.palettes[self.palette_pos][5]
	self.effect.colorize.color6 = self.palettes[self.palette_pos][6]
	self.effect.colorize.color7 = self.palettes[self.palette_pos][7]
	self.effect.colorize.color8 = self.palettes[self.palette_pos][8]

	self.effect(function()
		self.camera:draw(function(l,t,w,h)
			love.graphics.draw(self.bg_image, self.bg_quad)
			self.level:draw()
			self.players["player"]:draw()
		end)
	end)
	self.camera:draw(function(l,t,w,h)
		local wl,wt,ww,wh = self.camera:getWorld()
		if self.players["buddy"].in_control then
			self.players["buddy"]:draw(self.camera)
		elseif self.players["foe"].in_control then
			self.players["foe"]:draw(self.camera)
		end
	end)

end

function Game:keypressed(key)
	if self.players["player"].in_control then
		self.players["player"]:keypressed(key)
	end
end

function Game:mousereleased(x,y,button)
	for i,v in pairs(self.players) do
		if v.in_control then
			v:mousereleased(x,y,button)
		end
	end
end

return Game

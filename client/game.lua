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

	self.level = Level(level_data.w, level_data.h)

	for i,o in pairs(level_data.objects) do
		self.level:newObject(o.type, o.x, o.y, o.w, o.h)
		print(o.type)
	end

	self.camera = Gamera.new(0,0, 2000, 2000)
	self.camera:setScale(3,3)

	self.bg_image = love.graphics.newImage("img/bg.png")
	self.bg_image:setWrap("repeat", "repeat")

	self.bg_quad = love.graphics.newQuad(0, 0, 2000, 2000, self.bg_image:getWidth(), self.bg_image:getHeight())
end

function Game:update(dt)
	for i,v in pairs(self.players) do
		v:update(dt)
	end
end

function Game:draw()
	if self.players["player"].in_control then
		self.camera:setPosition(self.players["player"].x, self.players["player"].y)
	end
	self.camera:draw(function(l,t,w,h)
		love.graphics.draw(self.bg_image, self.bg_quad)
		self.players["player"]:draw()

		self.level:draw()
	end)
end

function Game:keypressed(key)
	if self.players["player"].in_control then
		self.players["player"]:keypressed(key)
	end
end

return Game

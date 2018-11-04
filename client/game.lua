local Player = require "player"
local Buddy = require "buddy"
local Foe = require "foe"

local Game = Object:extend()

function Game:new(players)
	self.players = {}
	for role,v in pairs(players) do
		if role == "player" then
			self.players[role] = Player(0,0,v.isself)
		elseif role == "buddy" then
			self.players[role] = Buddy(v.isself)
		elseif role == "foe" then
			self.players[role] = Foe(v.isself)
		end
		print(role, v.isself, v.nickname)
	end
end

function Game:update(dt)
	for i,v in pairs(self.players) do
		v:update(dt)
	end
end

function Game:draw()
	for i,v in pairs(self.players) do
		v:draw()
	end
end

return Game

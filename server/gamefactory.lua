local Level = require "level"

local Game = Object:extend()

local Player_Schema = {
	"x","y"
}

local Roles = {
	"player",
	"buddy",
	"foe"
}
function Game:new(lobby)
	self.players = {}
	self:createPlayers(lobby)

	local w,h = 100,100
	self.level = Level(w,h,true)
	self.level:newObject("grass",0,5,2,2,true)
	self.level:newObject("grass",5,5,4,7,true)
	self.level:newObject("grass",14,6,300,2,true)
	self.level:newObject("grass",2,5,3,2,true)
	self.level:newObject("grass",0,0,1,5,true)

	local level_data = self.level:getData()

	for j,k in pairs(self.players) do
		local send_players = {}
		for i,v in pairs(self.players) do
			send_players[i] = {
				role=v.role,
				nickname=v.nickname,
				isself=k==v
			}
		end
		k.client:send("start_game", {send_players, level_data})
	end
end

function Game:createPlayers(lobby)
	local lobby_players = lume.shuffle(lobby.players)
	for i,v in pairs(lobby_players) do
		self.players[Roles[i]] = {
			nickname=v.nickname,
			client=v.client
		}
	end

	self.players["player"].state = {
		x=0,
		y=0
	}
end

function Game:getNewLevelData()
	local level_data = {
		w=100,
		h=100,
		objects={
		},
		enemies={
		}
	}

	return level_data
end

function Game:updatePlayer(client, state)
	for i,v in pairs(self.players) do
		if v.client == client then
			v.state = state
		end
	end
end

function Game:getPlayerState(client)
	for i,v in pairs(self.players) do
		if v.client == client then
			return self.players["player"].state
		end
	end
end

local GameFactory = Object:extend()

function GameFactory:new()
	self.games = {}
end

-- listen to send_player_state, request_player_state,
-- send get_player_state
function GameFactory:registerCallbacks(Server)
	Server:setSchema("send_player_state", player_schema)
	Server:on("send_player_state", function(state, client)
		for i,v in pairs(self.games) do
			v:updatePlayer(client, state)
		end
	end)
	Server:setSchema("request_player_state", player_schema)
	Server:setSchema("get_player_state", player_schema)
	Server:on("request_player_state", function(state, client)
		for i,v in pairs(self.games) do
			local state = v:getPlayerState(client, state)
			if state then
				client:send("get_player_state", state)
				return
			end
		end
	end)
end

function GameFactory:newGame(lobby)
	table.insert(self.games, Game(lobby))
end

return GameFactory()

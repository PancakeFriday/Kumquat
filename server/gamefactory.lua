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
	--self.level:newObject("grass",0,5,7,2,true)
	--self.level:newObject("grass",3,0,4,1,true)
	--self.level:newObject("grass",5,5,4,7,true)
	--self.level:newObject("grass",9,5,6,2,true)
	--self.level:newObject("grass",16,8,3,2,true)
	self.level:newObject("grass",0,10,10,2,true)
	--self.level:newObject("grass",2,5,3,2,true)
	--self.level:newObject("grass",0,0,1,5,true)
	--self.level:newObject("grass",1,3,2,2,true)
	--self.level:newObject("saw",5,3,1,5,true)

	local level_data = self.level:getData()

	if DEV_MODE then
		self.players["buddy"].client:send("start_game", {
			{
				player={role="player", isself=true, nickname="test_player"},
				buddy={role="buddy",nickname="test_buddy",isself=false},
				foe={role="foe",nickname="test_foe",isself=false}
			}, level_data})
	else
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
end

function Game:createPlayers(lobby)
	local lobby_players
	if not lobby.noshuffle then
		lobby_players = lume.shuffle(lobby.players)
	else
		lobby_players = lume.clone(lobby.players)
	end

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

function Game:findClient(client)
	for i,v in pairs(self.players) do
		if v.client == client then
			return true
		end
	end
	return false
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

	Server:setSchema("new_level_object", {"obj_type", "obj_prop", "x","y","w","h"})
	Server:on("new_level_object", function(obj_vars, client)
		for i,v in pairs(self.games) do
			if v:findClient(client) then
				v.level:newObject(obj_vars["obj_prop"], obj_vars["x"], obj_vars["y"],
					obj_vars["w"], obj_vars["h"], true)

				for j,k in pairs(v.players) do
					k.client:send("new_level_object", obj_vars)
				end
				break
			end
		end
	end)

	Server:on("crystal_collect", function(id, client)
		for i,v in pairs(self.games) do
			if v:findClient(client) then
				v.level.crystals[id[1]].collected = true

				for j,k in pairs(v.players) do
					if k.client ~= client then
						k.client:send("crystal_collect", id)
					end
				end
				break
			end
		end
	end)
end

function GameFactory:newGame(lobby)
	table.insert(self.games, Game(lobby))
end

return GameFactory()

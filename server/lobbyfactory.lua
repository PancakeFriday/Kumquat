local Lobby = Object:extend()

function Lobby:new()
	self.players = {}
end

function Lobby:addPlayer(nickname, client)
	table.insert(self.players, {
		nickname=nickname,
		client=client,
		ready=true
	})
end

function Lobby:removeClient(client)
	for i,v in pairs(self.players) do
		if v.client == client then
			table.remove(self.players, i)
			return
		end
	end
end

function Lobby:getPlayersExcept(client)
	local other_players = {}
	for i,v in pairs(self.players) do
		if v.client ~= client then
			table.insert(other_players, v)
		end
	end
	return other_players
end

function Lobby:setReadyState(client, state)
	for i,v in pairs(self.players) do
		if v.client == client then
			v.ready = state
			return
		end
	end
end

function Lobby:allReady()
	if #self.players ~= 3 then
		return false
	end

	for i,v in pairs(self.players) do
		if not v.ready then
			return false
		end
	end
	return true
end

function Lobby:isEmptyOrFull()
	return #self.players == 0 or #self.players == 3
end

local LobbyFactory = Object:extend()

function LobbyFactory:new()
	self.framenum = 0
	self.connected_clients = {}

	self.lobbies = {
		private = {},
		public = {}
	}
end

function LobbyFactory:registerCallbacks(Server)
	Server:on("connect_public", function(nickname, client)
		local r = self:addPlayerToPublic(nickname, client)
		client:send("join_lobby", r)
	end)

	Server:on("joined_lobby", function(_,client)
		local other_players = client.lobby:getPlayersExcept(client)
		for _, player in pairs(other_players) do
			player.client:send("joined_lobby", {nickname=client.nickname,isself=false,ready=player.ready})
		end
	end)

	Server:on("player_readystate", function(state, client)
		client.lobby:setReadyState(client, state)
		local other_players = client.lobby:getPlayersExcept(client)
		for _, player in pairs(other_players) do
			player.client:send("player_readystate", {nickname=client.nickname,ready=state})
		end

		if client.lobby:allReady() then
			self:transferLobby(client.lobby)
		end
	end)

	Server:on("player_leavelobby", function(state, client)
		client.lobby:removeClient(client)
		client:disconnect()

		local other_players = client.lobby:getPlayersExcept(client)
		for _, player in pairs(other_players) do
			player.client:send("player_leave", client.nickname)
		end
	end)
end

function LobbyFactory:transferLobby(lobby)
	for _, tp in pairs({"public","private"}) do
		for i,v in pairs(self.lobbies[tp]) do
			if v == lobby then
				table.remove(self.lobbies[tp], i)
				GameFactory:newGame(lobby)

				for j, player in pairs(lobby.players) do
					lume.remove(self.connected_clients, player.client)
					print("happenin")
				end
				return
			end
		end
	end
end

function LobbyFactory:clear_lobby(tp)
	-- Clear disconnected players
	for i, client in lume.ripairs(self.connected_clients) do
		if not client:isConnected() then
			client.lobby:removeClient(client)
			table.remove(self.connected_clients, i)
		end
	end

	-- Clear empty lobbies
	for i,v in lume.ripairs(self.lobbies[tp]) do
		if #v.players == 0 then
			table.remove(self.lobbies[tp], i)
		end
	end
end

function LobbyFactory:getNextFree(tp)
	for i,v in pairs(self.lobbies[tp]) do
		if not v:isEmptyOrFull() then
			return v
		end
	end
	local new_lobby = Lobby()
	table.insert(self.lobbies[tp], new_lobby)
	return new_lobby
end

function LobbyFactory:addPlayerToPublic(nickname, client)
	if lume.find(self.connected_clients, client) then
		return {code="Already connected to a lobby"}
	end

	local lobby = self:getNextFree("public")
	lobby:addPlayer(nickname, client)

	client.lobby = lobby
	client.nickname = nickname
	table.insert(self.connected_clients, client)

	players = {}
	for i,v in pairs(lobby.players) do
		isself = v.client == client
		table.insert(players, {ready=v.ready, nickname=v.nickname, isself=isself})
	end

	return {code="success", players=players}
end

function LobbyFactory:update()
	self.framenum = self.framenum + 1

	self:clear_lobby("public")
	self:clear_lobby("private")

	if self.framenum%60 == 0 then
		for i,client in pairs(self.connected_clients) do
			players = {}
			for i,v in pairs(client.lobby.players) do
				isself = v.client == client
				table.insert(players, {ready=v.ready, nickname=v.nickname, isself=isself})
			end

			client:send("update_players", players)
		end
	end
end

return LobbyFactory()

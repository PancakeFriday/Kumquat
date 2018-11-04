local Suit = require "suit"

local function dashedLine( x1, y1, x2, y2, dash, gap )
	dash = dash or 3
	gap = gap or 3
	local dy, dx = y2 - y1, x2 - x1
	local an, st = math.atan2( dy, dx ), dash + gap
	local len	 = math.sqrt( dx*dx + dy*dy )
	local nm	 = ( len - dash ) / st
	love.graphics.push()
	love.graphics.translate( x1, y1 )
	love.graphics.rotate( an )
	for i = 0, nm do
		love.graphics.line( i * st, 0, i * st + dash, 0 )
	end
	love.graphics.line( nm * st, 0, nm * st + dash,0 )
	love.graphics.pop()
end

local Lobby = Object:extend()

function Lobby:new(players)
	self.ui = Suit.new()

	self.players = players
	Client:send("joined_lobby")

	self:registerCallbacks()

	self.bg_image = love.graphics.newImage("img/bg.png")
	self.bg_image:setWrap("repeat", "repeat")

	self.ready_img = love.graphics.newImage("img/ready.png")
	self.not_ready_img = love.graphics.newImage("img/not_ready.png")

	self.bg_quad = love.graphics.newQuad(0, 0, 2000, 2000, self.bg_image:getWidth(), self.bg_image:getHeight())
end

function Lobby:registerCallbacks()
	Client:on("joined_lobby", function(player)
		table.insert(self.players, player)
	end)
	Client:on("player_readystate", function(player)
		for i,v in pairs(self.players) do
			if v.nickname == player.nickname then
				v.ready = player.ready
			end
		end
	end)
	Client:on("player_leave", function(nickname)
		for i,v in pairs(self.players) do
			if v.nickname == nickname then
				table.remove(self.players, i)
				break
			end
		end
	end)
	Client:on("update_players", function(players)
		self.players = players
	end)
	Client:on("start_game", function(players)
		Gamestate:set("Game", players)
		self:unregisterCallbacks()
	end)
end

function Lobby:unregisterCallbacks()
	Client:removeCallback("joined_lobby")
	Client:removeCallback("player_readystate")
	Client:removeCallback("player_leave")
	Client:removeCallback("update_players")
	Client:removeCallback("start_game")
end

function Lobby:update()
	if not Client:isConnected() then
		self:unregisterCallbacks()
		Gamestate:reset("Lobby")
		Gamestate:set("Menu")
	end

	self.ui.layout:reset(100, 280)
	if self.ui:Button("Leave lobby", self.ui.layout:row(140,30)).hit then
		Client:send("player_leavelobby")
	end

	for i,v in pairs(self.players) do
		if v.isself then
			self.ui.layout:reset(410,100 + (i-1)*60)
			if self.ui:Button("Ready", self.ui.layout:row(80,30)).hit then
				v.ready = not v.ready
				Client:send("player_readystate", v.ready)
			end
		end
	end
end

function Lobby:draw()
	love.graphics.setColor(1,1,1,0.2)
	love.graphics.draw(self.bg_image, self.bg_quad)

	self.ui:draw()

	for i=1,3 do
		v = self.players[i] or nil
		love.graphics.setColor(0.28,0.29,0.33)
		if v then
			love.graphics.rectangle("fill", 100, 100 + (i-1)*60, 250, 30)
			love.graphics.rectangle("fill", 370, 100 + (i-1)*60, 30, 30)
		else
			dashedLine(100, 100 + (i-1)*60, 350, 100 + (i-1)*60)
			dashedLine(100, 130 + (i-1)*60, 350, 130 + (i-1)*60)

			dashedLine(100, 100 + (i-1)*60, 100, 130 + (i-1)*60)
			dashedLine(350, 100 + (i-1)*60, 350, 130 + (i-1)*60)
		end
		love.graphics.setColor(1,1,1)
		if v then
			if v.ready then
				love.graphics.draw(self.ready_img, 370, 100 + (i-1)*60)
			else
				love.graphics.draw(self.not_ready_img, 370, 100 + (i-1)*60)
			end
			love.graphics.print(v.nickname, 120, 105 + (i-1)*60)
		end
	end
end

return Lobby

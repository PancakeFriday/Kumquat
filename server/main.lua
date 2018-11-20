DEV_MODE = false
PORT = 22122

SCREENW, SCREENH = 320,240

-- Add libraries to path
package.path = package.path .. ";lib/?.lua"
local sock = require "sock"
local bitser = require "bitser"
Object = require "classic"
lume = require "lume"

-- Add modules to path
package.path = package.path .. ";modules/?.lua"

-- Local modules
LobbyFactory = require "lobbyfactory"
GameFactory = require "gamefactory"

local Server

function love.load()
	-- Limit FPS
	min_dt = 1/20
	next_time = love.timer.getTime()

	-- Set random seed
	math.randomseed(love.timer.getTime()*1000)
	love.math.setRandomSeed(love.timer.getTime()*1000)

    Server = sock.newServer("*", 22122)

    Server:on("connect", function(data, client)
        client:send("handshake")
		client:setTimeout(32, 5000, 10000)
		print("Received player", client:getConnectId())
    end)

	LobbyFactory:registerCallbacks(Server)
	GameFactory:registerCallbacks(Server)

	Server:on("disconnect", function(data, client)
	end)

	-- Debug: remove later
	if DEV_MODE then
		Server:on("test_game", function(_,client)
			local lobby = {players={
				{nickname="test_player",client=client},
				{nickname="test_buddy",client=client}
			},noshuffle=true}
			GameFactory:newGame(lobby)
		end)
	end
end

function love.update(dt)
	-- Limit FPS
	next_time = next_time + min_dt

    Server:update()
	LobbyFactory:update()

	-- Limit FPS
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
	return
	end
	love.timer.sleep(next_time - cur_time)
end

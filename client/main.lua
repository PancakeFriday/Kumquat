HOSTNAME = "localhost" -- or sofapizza.de
PORT = 22122

-- no blurry images
love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

-- Add libraries to path
package.path = package.path .. ";lib/?.lua"
local sock = require "sock"
local bitser = require "bitser"
Object = require "classic"
lume = require "lume"

-- Add modules to path
package.path = package.path .. ";modules/?.lua"
local Player = require "player"
Gamestate = require "gamestate"

-- Gamestates
package.path = package.path .. ";client/?.lua"
local Lobby = require "lobby"

ROLE = ""

function connect_to_server()
	if not Client or not Client:isConnected() then
		-- Creating a new client on localhost:22122
		Client = sock.newClient(HOSTNAME, PORT)

		-- Called when a connection is made to the server
		Client:on("connect", function(data)
			print("Client connected to the server.")
		end)

		-- Custom callback, called whenever you send the event from the server
		Client:on("handshake", function(role)
			ROLE = role
			print("Received handshake!")
		end)

		Client:connect()
		Client:update()

		for i=0,50 do
			if Client:isConnected() then
				break
			end
			love.timer.sleep(0.1)
			Client:update()
		end
	end
end

function love.load()
	-- Limit FPS
	min_dt = 1/60
	next_time = love.timer.getTime()

	Gamestate:register(Lobby, "Lobby")
	Gamestate:set(Lobby)
end

function love.update(dt)
	-- Limit FPS
	next_time = next_time + min_dt

	Gamestate:update(dt)

	if Client then
		Client:update()
	end

	--if ROLE == "player" then
		--Player:update(dt)
		--client:send("player_state", Player:getSerialized())
	--end
end

function love.draw()
	Gamestate:draw()
end

--function love.draw()
	--Player:draw()

	---- Limit FPS
	--local cur_time = love.timer.getTime()
	--if next_time <= cur_time then
		--next_time = cur_time
	--return
	--end
	--love.timer.sleep(next_time - cur_time)
--end

function love.textedited(text, start, length)
	Gamestate:textedited(text, start, length)
end

function love.textinput(t)
	Gamestate:textinput(t)
end

function love.keypressed(key)
	Gamestate:keypressed(key)
end

function love.keyreleased(key)
	Gamestate:keyreleased(key)
end

function love.mousepressed(x,y,button)
	Gamestate:mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
	Gamestate:mousereleased(x,y,button)
end

function love.wheelmoved(x,y)
	Gamestate:wheelmoved(x,y)
end

function love.resize(w,h)
	Gamestate:resize(w,h)
end

function love.quit()
	if Client then
		Client:disconnect()
		Client:update()
	end
end

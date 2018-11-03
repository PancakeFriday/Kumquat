HOSTNAME = "sofapizza" -- or sofapizza.de
PORT = 22122

-- no blurry images
love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

-- Add libraries to path
package.path = package.path .. ";lib/?.lua"
local sock = require "sock"
local bitser = require "bitser"
Object = require "classic"
_ = require "lume"

-- Add modules to path
package.path = package.path .. ";modules/?.lua"
local Player = require "player"

ROLE = ""

function love.load()
    -- Creating a new client on localhost:22122
    client = sock.newClient(HOSTNAME, PORT)

    -- Called when a connection is made to the server
    client:on("connect", function(data)
        print("Client connected to the server.")
    end)

    -- Custom callback, called whenever you send the event from the server
    client:on("handshake", function(role)
		ROLE = role
        print("Received handshake!")
    end)

	client:setSchema("update_player", Player:getSchema())
	client:on("update_player", function(player_data)
		Player:updateFromData(player_data)
	end)

    client:connect()
end

function love.update(dt)
    client:update()

	if ROLE == "player" then
		Player:update(dt)
		client:send("player_state", Player:getSerialized())
	end
end

function love.draw()
	Player:draw()
end

function love.quit()
	client:disconnect()
	client:update()
end

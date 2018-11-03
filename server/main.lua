PORT = 22122

-- Add libraries to path
package.path = package.path .. ";lib/?.lua"
local sock = require "sock"
local bitser = require "bitser"
Object = require "classic"
_ = require "lume"

-- Add modules to path
package.path = package.path .. ";modules/?.lua"
local Player = require "player"

Matches = {
	{}
}

Roles = {
	"player",
	"buddy",
	"foe"
}

function love.load()
	-- Limit FPS
	min_dt = 1/60
	next_time = love.timer.getTime()

    server = sock.newServer("*", 22122)

    server:on("connect", function(data, client)
		cur_match = Matches[#Matches]
		table.insert(cur_match, client)
		player_num = #cur_match
        client:send("handshake", Roles[player_num])
		if player_num == 3 then
			-- Create a new match
			table.insert(Matches, {})
		end

		print("Received player and assigned role " .. Roles[player_num])
    end)

	server:setSchema("player_state", Player:getSchema())
	server:on("player_state", function(player_data, client)
		Player:updateFromData(player_data)
		data = Player:getSerialized()
		server:sendToAllBut(client, "update_player", Player:getSerialized())
	end)

	server:on("disconnect", function(data, client)
		if #server.clients == 0 then
			love.quit()
		end
	end)

end

function love.update(dt)
	-- Limit FPS
	next_time = next_time + min_dt

    server:update()

	-- Limit FPS
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
	return
	end
	love.timer.sleep(next_time - cur_time)
end

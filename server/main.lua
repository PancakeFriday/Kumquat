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
    server:update()
end

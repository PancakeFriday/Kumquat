local Suit = require "suit"
local Namegen = require "namegen/namegen"

local Menu = Object:extend()

function Menu:new()
	self.ui = Suit.new()

	self.bg_image = love.graphics.newImage("img/bg.png")
	self.bg_image:setWrap("repeat", "repeat")

	self.bg_quad = love.graphics.newQuad(0, 0, 2000, 2000, self.bg_image:getWidth(), self.bg_image:getHeight())

	self.font = love.graphics.newFont("fonts/PatuaOne-Regular.ttf", 15)
	love.graphics.setFont(self.font)
end

function get_random_name()
	local race_list = {
		"halfling male",
		"halfling female",
		"elf male",
		"elf female",
		"hobgoblin male",
		"hobgoblin female",
		"human male",
		"human female",
		"kobold male",
		"kobold female",
		"ogre male",
		"ogre female"
	}
	math.randomseed(love.timer.getTime()*1000)
	return Namegen.generate(lume.randomchoice(race_list))
end

hostname = {text = "localhost"}
nickname = {text = get_random_name()}
error_msg = {text = ""}
private_identifier = {text = ""}

function Menu:update(dt)
	self.ui.layout:reset(100,100)

	self.ui:Label(error_msg.text, {align = "left", color={normal={fg={1,0,0}}}}, self.ui.layout:row(200,30))
	self.ui.layout:row()
	self.ui:Label("Server Hostname", {align = "left"}, self.ui.layout:row())
	self.ui:Input(hostname, self.ui.layout:row())

	self.ui:Label("Nickname", {align = "left"}, self.ui.layout:row())
	self.ui:Input(nickname, self.ui.layout:row())

	self.ui.layout:row()
	col_pos, row_pos = self.ui.layout:row()
	self.ui.layout:reset(100, row_pos)

	self.ui:Label("Public game", {align = "left"}, self.ui.layout:row(200,30))
	if self.ui:Button("Join public game", self.ui.layout:row()).hit then
		if nickname.text == "" then
			error_msg.text = "Nickname cannot be empty"
		else
			connect_to_server(hostname.text)
			if Client:isConnected() then
				Client:send("connect_public", nickname.text)
				Client:on("join_lobby", function(r)
					if r.code == "success" then
						Gamestate:set("Lobby", r.players)
						Client:removeCallback("join_lobby")
					else
						error_msg.text = r.code
					end
				end)
			else
				error_msg.text = "Could not connect to server"
			end
		end
	end

	self.ui.layout:row()
	self.ui:Label("Identifier for private game", {align = "left"}, self.ui.layout:row())
	self.ui:Input(private_identifier, self.ui.layout:row())
	self.ui.layout:row(200,10)
	if self.ui:Button("Join private game", self.ui.layout:row(200,30)).hit then
		connect_to_server(hostname.text)
		if Client:isConnected() then

		else
			error_msg.text = "Could not connect to server"
		end
	end
end

function Menu:draw()
	love.graphics.setColor(1,1,1,0.2)
	love.graphics.draw(self.bg_image, self.bg_quad)
	love.graphics.setColor(1,1,1)
	self.ui:draw()
end

--client:setSchema("update_player", Player:getSchema())
--client:on("update_player", function(player_data)
	--Player:updateFromData(player_data)
--end)

function Menu:textedited(text, start, length)
	self.ui:textedited(text, start, length)
end

function Menu:textinput(t)
	-- forward text input to SUIT
	self.ui:textinput(t)
end

function Menu:keypressed(key)
	-- forward keypresses to SUIT
	self.ui:keypressed(key)
end

return Menu
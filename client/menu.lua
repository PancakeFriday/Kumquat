local Suit = require "suit"

local Menu = Object:extend()

function Menu:new()
	self.ui = Suit.new()

	self.bg_image = love.graphics.newImage("img/bg.png")
	self.bg_image:setWrap("repeat", "repeat")

	self.bg_quad = love.graphics.newQuad(0, 0, 2000, 2000, self.bg_image:getWidth(), self.bg_image:getHeight())

	self.font = love.graphics.newFont("fonts/PatuaOne-Regular.ttf", 15)
	love.graphics.setFont(self.font)
end

error_msg = {text = ""}

function Menu:update(dt)
	self.ui.layout:reset(100,100)

	if self.ui:Button("Start game", self.ui.layout:row(200,30)).hit then
		Gamestate:set("Game")
	end
end

function Menu:draw()
	love.graphics.setColor(1,1,1,0.2)
	love.graphics.draw(self.bg_image, self.bg_quad)
	love.graphics.setColor(1,1,1)
	self.ui:draw()
end

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

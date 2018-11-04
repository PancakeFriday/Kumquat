local gamera = require "gamera"

Player = Object:extend()

function Player:new(x,y,in_control)
	self.x = x
	self.y = y

	self.in_control = in_control

	self.hvel = 0
	self.maxhvel = 250
	self.haccel = 200
	self.hfriction = 10

	self.camera = gamera.new(0,0, 2000, 2000)
	self.camera:setScale(4,4)

	self.bg_image = love.graphics.newImage("img/bg.png")
	self.bg_image:setWrap("repeat", "repeat")

	self.bg_quad = love.graphics.newQuad(0, 0, 2000, 2000, self.bg_image:getWidth(), self.bg_image:getHeight())

	self:registerCallbacks()
end

function Player:registerCallbacks()
	if self.in_control then
		Client:setSchema("send_player_state", self:getSchema())
	else
		Client:setSchema("get_player_state", self:getSchema())
		Client:on("get_player_state", function(player_vars)
			for i,v in pairs(player_vars) do
				self[i] = v
			end
		end)
	end
end

function Player:getSchema()
	return {
		"x", "y"
	}
end

function Player:getSerialized()
	return {
		self.x, self.y
	}
end

function Player:updateFromData(data)
	for index, value in pairs(data) do
		self[index] = value
	end
end

function Player:update(dt)
	if self.in_control then
		local dx, dy = 0, 0
		local xforces = 0

		if love.keyboard.isDown("right") then
			if self.hvel >= -10 then
				xforces = xforces + self.haccel
			end
		end
		if love.keyboard.isDown("left") then
			if self.hvel <= 10 then
				xforces = xforces - self.haccel
			end
		end
		if love.keyboard.isDown("up") then
			dy = -1
		end
		if love.keyboard.isDown("down") then
			dy = 1
		end
		if xforces == 0 then
			-- Apply friction
			xforces = xforces - self.hfriction * self.hvel
		end
		self.hvel = lume.clamp(self.hvel + xforces*dt, -self.maxhvel, self.maxhvel)

		dx = self.hvel * dt

		self:move(dx, dy)

		-- Request player position
		Client:send("send_player_state", self:getSerialized())
	else
		-- Request player position
		Client:send("request_player_state")
	end
end

function Player:draw()
	self.camera:setPosition(self.x, self.y)
	self.camera:draw(function(l,t,w,h)
		love.graphics.draw(self.bg_image, self.bg_quad)
		love.graphics.rectangle("fill", self.x, self.y, 10, 10)
	end)
end

function Player:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end


return Player

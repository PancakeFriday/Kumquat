local HC = require "HC"

Player = Object:extend()

function Player:new(x,y,in_control)
	self.x = x*16
	self.y = y*16

	self.in_control = in_control

	self.xforces = 0
	self.yforces = 0

	self.hvel = 0
	self.maxhvel = 120
	self.maxhvel2 = 160
	self.haccel = 320
	self.hfriction = 48

	self.vvel = 0
	self.maxvvel = 250
	self.gravity = 1440
	self.jumpvel = 250

	self.mario_img = love.graphics.newImage("img/mario.png")

	self.hitbox = HC.rectangle(self.x, self.y, self.mario_img:getWidth(), self.mario_img:getHeight())

	self:registerCallbacks()

	self.key_press_frames = {}
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
		for i,v in pairs(self.key_press_frames) do
			if not love.keyboard.isDown(i) then
				self.key_press_frames[i] = nil
			end
		end
		if not self.key_press_frames["space"] then
			self.falling = (self.vvel ~= 0)
			self.jumping = false
		end
		local dx, dy = 0, 0
		print("-----------------")

		self.yforces = self.yforces + self.gravity

		if love.keyboard.isDown("right") then
			if self.hvel >= -10 then
				self.xforces = self.xforces + self.haccel
			end
		end
		if love.keyboard.isDown("left") then
			if self.hvel <= 10 then
				self.xforces = self.xforces - self.haccel
			end
		end
		if self.key_press_frames["space"] then
			local jumpframes = 10
			if self.running then
				jumpframes = 14
			end

			if self.key_press_frames["space"] == 0 and not self.jumping and not self.falling
			or (self.key_press_frames["space"] <= jumpframes and self.jumping) then
				if self.vvel == 0 then
					-- Player not currently in the air
					self.jumping = true
				end
				if self.jumping then
					self.vvel = -self.jumpvel
				end
			end
		end
		if self.xforces == 0 then
			-- Apply friction
			self.xforces = self.xforces - self.hfriction * self.hvel
		end
		self.hvel = lume.clamp(self.hvel + self.xforces*dt, -self.maxhvel, self.maxhvel)
		self.vvel = lume.clamp(self.vvel + self.yforces*dt, -self.maxvvel, self.maxvvel)

		if self.key_press_frames["lshift"] then
			if math.abs(self.hvel) == self.maxhvel then
				-- Don't start the run when we are in the air, however do continue it
				-- anytime
				if not self.jumping or self.running then
					if self.key_press_frames["lshift"] >= 10 then
						self.running = true
						self.hvel = lume.sign(self.hvel)*self.maxhvel2
					end
				end
			else
				self.key_press_frames["lshift"] = 0
			end
		end

		self.xforces = 0
		self.yforces = 0

		dx = self.hvel * dt
		dy = self.vvel * dt

		self:move(dx, dy)

		if self.vvel == 0 then
			self.jumping = false
		end
		print("jump:",self.jumping, self.vvel)
		if not self.jumping and math.abs(self.hvel) ~= self.maxhvel2 then
			self.running = false
		end
		print("run:",self.running)

		for i,v in pairs(self.key_press_frames) do
			self.key_press_frames[i] = v+1
		end

		-- Request player position
		Client:send("send_player_state", self:getSerialized())
	else
		-- Request player position
		Client:send("request_player_state")
	end
end

function Player:draw()
	love.graphics.draw(self.mario_img, self.x, self.y)
	if DEV_DRAW then
		self.hitbox:draw()
	end
end

function Player:move(dx, dy)
	local moveby_x, moveby_y = dx, dy
	-- x movement
	self.hitbox:move(dx, 0)

	::start_xcheck::
	for shape, delta in pairs(HC.collisions(self.hitbox)) do
		if delta.x ~= 0 then
			self.hitbox:move(delta.x, 0)
			moveby_x = moveby_x + delta.x
			self.hvel = 0
			goto start_xcheck
		end
	end

	-- y movement
	self.hitbox:move(0, dy)

	::start_ycheck::
	for shape, delta in pairs(HC.collisions(self.hitbox)) do
		if delta.y ~= 0 then
			self.hitbox:move(0, delta.y)
			moveby_y = moveby_y + delta.y
			self.vvel = 0
			goto start_ycheck
		end
	end

	self.x = self.x + moveby_x
	self.y = self.y + moveby_y
end

function Player:keypressed(key)
	self.key_press_frames[key] = 0
end

return Player

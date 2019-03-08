local Animation = require "animation"
local HC = require "HC"

Player = Object:extend()

function Player:new(x,y,in_control)
	self.origin_x = 0
	self.origin_y = 0

	self.x = x*16
	self.y = y*16
	self.w = 10
	self.h = 14

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

	--self.player_img = love.graphics.newImage("img/player.png")
	self.player_anim = Animation("img/player.png")
	self.player_anim:create("idle", 0, 0, 10, 14, 1)
	self.player_anim:create("walking", 10, 0, 10, 14, 2)
	self.player_anim:set("idle")

	self.hitbox = HC.rectangle(self.x-5, self.y-7, self.w, self.h)

	self.key_press_frames = {}
end

function Player:update(dt)
	self.player_anim:update(dt)
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
	if self.xforces < 0 then
		self.player_anim:set_hflipped(true)
	elseif self.xforces > 0 then
		self.player_anim:set_hflipped(false)
	end
	if self.xforces == 0 then
		self.player_anim:set("idle")
		-- Apply friction
		self.xforces = self.xforces - self.hfriction * self.hvel
	else
		self.player_anim:set("walking")
	end
	self.hvel = lume.clamp(self.hvel + self.xforces*dt, -self.maxhvel, self.maxhvel)
	self.vvel = lume.clamp(self.vvel + self.yforces*dt, -self.maxvvel, self.maxvvel)

	-- Fast walking. Not sure if we want this?
	--if self.key_press_frames["lshift"] then
		--if math.abs(self.hvel) == self.maxhvel then
			---- Don't start the run when we are in the air, however do continue it
			---- anytime
			--if not self.jumping or self.running then
				--if self.key_press_frames["lshift"] >= 10 then
					--self.running = true
					--self.hvel = lume.sign(self.hvel)*self.maxhvel2
				--end
			--end
		--else
			--self.key_press_frames["lshift"] = 0
		--end
	--end

	self.xforces = 0
	self.yforces = 0

	dx = self.hvel * dt
	dy = self.vvel * dt

	self:move(dx, dy)

	if self.vvel == 0 then
		self.jumping = false
	end
	if not self.jumping and math.abs(self.hvel) ~= self.maxhvel2 then
		self.running = false
	end

	for i,v in pairs(self.key_press_frames) do
		self.key_press_frames[i] = v+1
	end
end

function Player:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y-7)
	self.player_anim:draw()
	love.graphics.pop()
	--love.graphics.draw(self.player_img, self.x-5, self.y-7)
	if DEV_DRAW then
		self.hitbox:draw()
	end
end

function Player:move_to(ix,iy)
	self.x = ix*16+5
	self.y = iy*16
	self.hitbox:moveTo(ix*16+5,iy)
end

function Player:move(dx, dy)
	dy = math.min(dy, 5)
	dx = math.min(dx, 5)
	local moveby_x, moveby_y = dx, dy
	-- x movement
	self.hitbox:move(dx, 0)

	local num_cols = 0
	::start_xcheck::
	if num_cols < 20 then
		for shape, delta in pairs(HC.collisions(self.hitbox)) do
			if shape.type and shape.type == "kill" then
				--print("kill")
			elseif shape.type and shape.type == "crystal" then
				shape.obj.collected = true
				HC.remove(shape)
			elseif delta.x ~= 0 then
				num_cols = num_cols + 1
				self.hitbox:move(delta.x, 0)
				moveby_x = moveby_x + delta.x
				self.hvel = 0
				goto start_xcheck
			end
		end
	end

	-- y movement
	self.hitbox:move(0, dy)

	local num_cols = 0
	::start_ycheck::
	if num_cols < 20 then
		for shape, delta in pairs(HC.collisions(self.hitbox)) do
			if shape.type and shape.type == "kill" then
				--print("kill")
			elseif shape.type and shape.type == "crystal" then
				shape.obj.collected = true
				HC.remove(shape)
			elseif delta.y ~= 0 then
				num_cols = num_cols + 1
				self.hitbox:move(0, delta.y)
				moveby_y = moveby_y + delta.y
				self.vvel = 0
				goto start_ycheck
			end
		end
	end

	self.x = self.x + moveby_x
	self.y = self.y + moveby_y
end

function Player:keypressed(key)
	self.key_press_frames[key] = 0
end

function Player:mousereleased(x,y,button)

end

return Player

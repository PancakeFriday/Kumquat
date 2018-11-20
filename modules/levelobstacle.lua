local LevelObstacle = Object:extend()

function LevelObstacle:new(t,x,y,w,h,isserver)
	self.type = t
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	if not isserver then
		local HC = require "HC"

		self.img = love.graphics.newImage("img/objects/"..t..".png")
		if t == "saw" then
			self.quad = love.graphics.newQuad(0,0,32,32,32,32)
			self.hitbox = HC.circle(self.x*16+32/2, self.y*16+32/2, 14)
			self.hitbox.type = "kill"
		end
	end

	self.time = 0
end

function LevelObstacle:getData()
	return {
		type=self.type,
		x=self.x,
		y=self.y,
		w=self.w,
		h=self.h
	}
end

function LevelObstacle:update(dt)
	self.time = self.time + dt
end

function LevelObstacle:draw()
	love.graphics.push()
	local r = lume.round(self.time, 0.05)*4
	love.graphics.translate(16,16)
	love.graphics.draw(self.img, self.quad, self.x*16, self.y*16, r, 1, 1, 16, 16)
	love.graphics.pop()

	if DEV_DRAW then
		self.hitbox:draw()
	end
end

return LevelObstacle

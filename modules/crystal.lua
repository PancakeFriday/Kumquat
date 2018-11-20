local Crystal = Object:extend()

function Crystal:new(x,y,id,isserver)
	self.x = x
	self.y = y
	self.my = 0
	if not isserver then
		local HC = require "HC"
		self.img = love.graphics.newImage("img/objects/crystal.png")
		self.hitbox = HC.rectangle(self.x,self.y,self.img:getWidth(),self.img:getHeight())
		self.hitbox.type = "crystal"
		self.hitbox.obj = self
		self.time = math.random()*5
	end
	self.collected = false
	self.id = id
end

function Crystal:update(dt)
	if not self.collected then
		self.time = self.time + dt
		self.my = math.sin(self.time*2.5)*3
		self.hitbox:moveTo(self.x+self.img:getWidth()/2,self.y+self.my+self.img:getHeight()/2)

		if love.keyboard.isDown("d") then
			self.collected = true
		end
	end
end

function Crystal:draw()
	if not self.collected then
		love.graphics.draw(self.img, self.x, self.y+self.my)
		if DEV_DRAW then
			self.hitbox:draw()
		end
	end
end

return Crystal

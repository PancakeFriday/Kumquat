local MapEditor = Object:extend()

function MapEditor:new()
	self.grid_canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(self.grid_canvas)
	love.graphics.setCanvas()

	self.mousedown = false

	self.x = 0
	self.y = 0
	self.mousepos = {}
	self.new_rec = {}
end

function MapEditor:setLevel(level)
	self.level = level
end

function MapEditor:update(dt)
	if love.keyboard.isDown("left") then
		self.x = self.x - 200*dt
	end
	if love.keyboard.isDown("right") then
		self.x = self.x + 200*dt
	end
	if love.keyboard.isDown("up") then
		self.y = self.y - 200*dt
	end
	if love.keyboard.isDown("down") then
		self.y = self.y + 200*dt
	end
end

function MapEditor:draw(camera)
	local s = camera:getScale()
	local l,t,w,h = camera:getVisible()
	local wl,wt,ww,wh = camera:getWorld()
	self.x = lume.clamp(self.x, w/2, ww-w/2)
	self.y = lume.clamp(self.y, h/2, wh-h/2)

	if love.mouse.isDown(1) and not self.mousedown then
		self.mousedown = true
		self.mousepos.x, self.mousepos.y = love.mouse.getPosition()
	elseif not love.mouse.isDown(1) then
		self.mousedown = false
	end

	if self.mousedown then
		local s = camera:getScale()
		local mx, my = camera:toWorld(love.mouse.getPosition())
		local x, y = camera:toWorld(self.mousepos.x, self.mousepos.y)
		local w, h = mx-x, my-y
		x = lume.round(x,16)
		y = lume.round(y,16)
		w = lume.round(w,16)
		h = lume.round(h,16)
		love.graphics.rectangle("line",x,y,w,h)
		self.new_rec.x = x
		self.new_rec.y = y
		self.new_rec.w = w
		self.new_rec.h = h
	end

	love.graphics.setColor(0.2,0.2,0.2,0.4)
	love.graphics.setLineWidth(0.1)
	local minx, maxx = math.floor(l/16)*16, math.floor((l+w)/16)*16+16
	local miny, maxy = math.floor(t/16)*16, math.floor((t+h)/16)*16+16

	for x=minx,maxx,16 do
		love.graphics.line(x, 0, x, maxy)
	end
	for y=miny,maxy,16 do
		love.graphics.line(0, y, maxx, y)
	end
	love.graphics.setColor(1,1,1)
end

function MapEditor:mousereleased(x,y,button)
	if button == 1 then
		Client:send("new_level_object", {"r","grass",self.new_rec.x/16, self.new_rec.y/16, self.new_rec.w/16, self.new_rec.h/16})
	end
end

return MapEditor

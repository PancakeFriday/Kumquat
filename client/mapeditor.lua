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

	self.no_mode_canvas = love.graphics.newCanvas(SCREENW, SCREENH)
	love.graphics.setCanvas(self.no_mode_canvas)
		love.graphics.setColor(1,0.2,0.1)
		local _max = math.max(SCREENW,SCREENH)
		for i=-_max,_max,8 do
			love.graphics.line(0,i,_max,_max+i)
		end
	love.graphics.setCanvas()
end

function MapEditor:setLevel(level)
	self.level = level
end

function MapEditor:update(dt)
	if self.in_control then
		if love.keyboard.isDown("a") then
			self.x = self.x - 400*dt
		end
		if love.keyboard.isDown("d") then
			self.x = self.x + 400*dt
		end
		if love.keyboard.isDown("w") then
			self.y = self.y - 400*dt
		end
		if love.keyboard.isDown("s") then
			self.y = self.y + 400*dt
		end
	end
end

function MapEditor:draw(camera)
	local s = camera:getScale()
	local l,t,w,h = camera:getVisible()
	local wl,wt,ww,wh = camera:getWorld()
	self.x = lume.clamp(self.x, wl+w/2, ww+wl-w/2)
	self.y = lume.clamp(self.y, wt+h/2, wh+wt-h/2)

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

	local minx, maxx = math.floor(l/16)*16, math.floor((l+w)/16)*16+16
	local miny, maxy = math.floor(t/16)*16, math.floor((t+h)/16)*16+16

	for x=minx,maxx,16 do
		if x%SCREENW == 0 then
			love.graphics.setColor(1,1,1)
			love.graphics.setLineWidth(0.4)
		else
			love.graphics.setColor(0.2,0.2,0.2,0.4)
			love.graphics.setLineWidth(0.1)
		end
		love.graphics.line(x, miny, x, maxy)
	end
	for y=miny,maxy,16 do
		if y%SCREENH == 0 then
			love.graphics.setColor(1,1,1)
			love.graphics.setLineWidth(0.4)
		else
			love.graphics.setColor(0.2,0.2,0.2,0.4)
			love.graphics.setLineWidth(0.1)
		end
		love.graphics.line(minx, y, maxx, y)
	end

	love.graphics.setColor(1,1,1)

	if not self.inv_map then
		self.inv_map = {}
		local minx,miny,maxx,maxy = self.level:getBounds()
		for x=minx,maxx do
			for y=miny,maxy do
				local map = {}
				map.x = x
				map.y = y
				table.insert(self.inv_map, map)
			end
		end
		for i,v in pairs(self.level.map) do
			local val,key = lume.match(self.inv_map, function(x) return x.x == v.x and x.y == v.y end)
			lume.remove(self.inv_map, val)
		end
	end
	for i,v in pairs(self.inv_map) do
		love.graphics.draw(self.no_mode_canvas,v.x*SCREENW,v.y*SCREENH)
	end
end

function MapEditor:mousereleased(x,y,button)
	if button == 1 then
		if self.new_rec.w ~= 0 and self.new_rec.h ~= 0 then
			Client:send("new_level_object", {"r","grass",self.new_rec.x/16, self.new_rec.y/16, self.new_rec.w/16, self.new_rec.h/16})
		end
	end
end

return MapEditor

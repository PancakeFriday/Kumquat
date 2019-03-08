local Bitser = require "bitser"
local Suit = require "suit"

local MapEditor = Object:extend()

function MapEditor:new()
	self.ui = Suit.new()

	self.minimenu = Suit.new()

	self.grid_canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(self.grid_canvas)
	love.graphics.setCanvas()

	self.mousedown = false

	self.x = 0
	self.y = 0
	self.mousepos = {}
	self.new_rec = {}

	self.filename = {text=""}

	self.no_mode_canvas = love.graphics.newCanvas(SCREENW, SCREENH)
	love.graphics.setCanvas(self.no_mode_canvas)
		love.graphics.setColor(1,0.2,0.1)
		local _max = math.max(SCREENW,SCREENH)
		for i=-_max,_max,8 do
			love.graphics.line(0,i,_max,_max+i)
		end
	love.graphics.setCanvas()

	-- Variables related to tools
	self.timer_paused = true
end

function MapEditor:set_level(level)
	self.level = level
end

function MapEditor:set_camera(cam)
	self.camera = cam
	self.camera:setWindow(130,0,love.graphics.getWidth()-130,love.graphics.getHeight())
end

function MapEditor:set_player(player)
	self.player = player
end

function MapEditor:update(dt)
	if not self.test_mode then
		local speed = 400
		if love.keyboard.isDown("lshift") then
			speed = 600
		end
		if love.keyboard.isDown("a") then
			self.x = self.x - speed*dt
		end
		if love.keyboard.isDown("d") then
			self.x = self.x + speed*dt
		end
		if love.keyboard.isDown("w") then
			self.y = self.y - speed*dt
		end
		if love.keyboard.isDown("s") then
			self.y = self.y + speed*dt
		end

		if love.mouse.isDown(2) then
			if not self.minimenu.mx then
				self.minimenu.mx, self.minimenu.my = love.mouse.getPosition()
			end
		end
		if self.minimenu.mx then
			self:draw_minimenu()
		end

		self:draw_ui(dt)
	else
		self:draw_test_ui(dt)
	end
end

function MapEditor:draw_test_ui(dt)
	self.ui.layout:reset(5,5)

	if self.ui:Button("Reset position", self.ui.layout:row(120,30)).hit then
		self.player:move_to(self.player.origin_x, self.player.origin_y)
	end
	if self.ui:Button("Back to editor", self.ui.layout:row(120,30)).hit then
		self.set_test_mode = false
	end
end

function MapEditor:draw_minimenu()
	local mx_world, my_world = self.camera:toWorld(self.minimenu.mx,self.minimenu.my)

	self.minimenu.layout:reset(self.minimenu.mx+3, self.minimenu.my+3)

	local buttons = {}
	add_button = function(text, fun)
		table.insert(buttons, { text=text, fun=fun })
	end

	for i,screen in pairs(self.level.map) do
		if mx_world >= screen.x*SCREENW and mx_world < (screen.x+1)*SCREENW
		and my_world >= screen.y*SCREENH and my_world < (screen.y+1)*SCREENH then
			local dirs = {
				{"top",0,-1,"above"},
				{"bottom",0,1,"below"},
				{"left",-1,0,"to the left"},
				{"right",1,0,"to the right"}
			}

			for i,v in pairs(dirs) do
				if not screen.neighbors[v[1]] then
					add_button("Add screen "..v[4], function()
						self.level:addScreenAt(screen.x+v[2],screen.y+v[3])
						local minx, miny, maxx, maxy = self.level:getBounds()
						self.camera:setWorld(minx*SCREENW, miny*SCREENH, (maxx-minx+1)*SCREENW, (maxy-miny+1)*SCREENH)
					end)
				end
			end
		end
	end

	for i,v in pairs(buttons) do
		buttons[i].button = self.minimenu:Button(v.text, self.minimenu.layout:row(160,30))
	end

	if not love.mouse.isDown(2) then
		self.minimenu.mx = nil
		self.minimenu.my = nil
		for i,v in pairs(buttons) do
			if v.button.hovered then
				v.fun()
			end
		end
	end
end

function MapEditor:draw_ui()
	self.ui.layout:reset(5,5)

	if self.ui:Button("Open level", self.ui.layout:row(120,30)).hit then
		self.dialog_window_mode = "read"
	end
	if self.ui:Button("Save level", self.ui.layout:row(120,30)).hit then
		self.dialog_window_mode = "write"
	end
	self.ui.layout:row(120,10)
	if self.ui:Button("Reset position", self.ui.layout:row(120,30)).hit then
		self.player:move_to(self.player.origin_x, self.player.origin_y)
	end
	self.ui.layout:row(120,10)
	if self.ui:Button("Play", self.ui.layout:row(120,30)).hit then
		self.set_test_mode = true
	end

	if self.dialog_window_mode then
		self:show_file_dialog()
	end
end

function MapEditor:show_file_dialog(bit_string)
	self.ui.layout:reset(145,15)
	if self.ui:Button("Close", self.ui.layout:row(120,30)).hit then
		self.dialog_window_mode = nil
	end
	self.ui.layout:row(120,5)
	self.ui:Input(self.filename, self.ui.layout:row(220,30))
	self.ui.layout:reset(370,50)
	if self.dialog_window_mode == "write" then
		if self.ui:Button("Save", self.ui.layout:row(120,30)).hit then
			love.filesystem.createDirectory('levels')
			local f = love.filesystem.newFile('levels/'..self.filename.text, "w")
			f:write(Bitser.dumps(self.level:get_data()))
			f:close()
		end
	end
	if self.dialog_window_mode == "read" then
		if self.ui:Button("Load", self.ui.layout:row(120,30)).hit then
			if love.filesystem.getInfo('levels/'..self.filename.text) and string.len(self.filename.text) > 0 then
				local f = love.filesystem.newFile('levels/'..self.filename.text, "r")
				self.level:recreate_from_data(Bitser.loads(f:read()))
				f:close()

				local minx, miny, maxx, maxy = self.level:getBounds()
				self.camera:setWorld(minx*SCREENW, miny*SCREENH, (maxx-minx+1)*SCREENW, (maxy-miny+1)*SCREENH)
			end
		end
	end
	local files = love.filesystem.getDirectoryItems('levels')
	files = lume.sort(files)
	for i,v in pairs(files) do
		i = i - 1
		self.ui.layout:reset(145+125*math.floor(i/17), 100+30*(i%17))
		if self.ui:Button(v, self.ui.layout:row(120,30)).hit then
			self.filename.text = v
		end
	end
end

function MapEditor:draw()
	if not self.test_mode then
		self:draw_grid()
	end
end

function MapEditor:draw_unscaled()
	if not self.test_mode then
		-- Left rectangle where the buttons are
		love.graphics.setColor(0.9,0.9,0.9,0.1)
		love.graphics.rectangle("fill", 0,0,130,love.graphics.getHeight())
		love.graphics.setColor(1,1,1)

		-- File dialog
		if self.dialog_window_mode then
			love.graphics.setColor(0.1,0.1,0.1,0.9)
			love.graphics.rectangle("fill",140,10,800,605)
			love.graphics.setColor(1,1,1)
			love.graphics.line(142,90,800+138,90)
		end
	end

	self.ui:draw()
	self.minimenu:draw()
end

function MapEditor:draw_grid()
	local s = self.camera:getScale()
	local l,t,w,h = self.camera:getVisible()
	local wl,wt,ww,wh = self.camera:getWorld()
	self.x = lume.clamp(self.x, wl+w/2, ww+wl-w/2)
	self.y = lume.clamp(self.y, wt+h/2, wh+wt-h/2)

	if love.mouse.isDown(1) and not self.mousedown then
		self.mousedown = true
		self.mousepos.x, self.mousepos.y = love.mouse.getPosition()
	elseif not love.mouse.isDown(1) then
		self.mousedown = false
	end

	if self.mousedown then
		local s = self.camera:getScale()
		local mx, my = self.camera:toWorld(love.mouse.getPosition())
		local x, y = self.camera:toWorld(self.mousepos.x, self.mousepos.y)
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

	local minx, maxx = math.floor(l/16)*16, math.floor((l+w)/16)*16
	local miny, maxy = math.floor(t/16)*16, math.floor((t+h)/16)*16

	if ww > w then maxx = maxx + 16 end
	if wh > h then maxy = maxy + 16 end

	-- Draw grid
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

	--if not self.inv_map then
		inv_map = {}
		local minx,miny,maxx,maxy = self.level:getBounds()
		for x=minx,maxx do
			for y=miny,maxy do
				local map = {}
				map.x = x
				map.y = y
				table.insert(inv_map, map)
			end
		end
		for i,v in pairs(self.level.map) do
			local val,key = lume.match(inv_map, function(x) return x.x == v.x and x.y == v.y end)
			lume.remove(inv_map, val)
		end
	--end
	for i,v in pairs(inv_map) do
		love.graphics.draw(self.no_mode_canvas,v.x*SCREENW,v.y*SCREENH)
	end
end

function MapEditor:mousereleased(x,y,button)
	if button == 1 then
		if self.new_rec.w ~= 0 and self.new_rec.h ~= 0 then
			self.level:newObject("grass",self.new_rec.x/16, self.new_rec.y/16, self.new_rec.w/16, self.new_rec.h/16)
		end
	end
end

function MapEditor:textedited(text, start, length)
	self.ui:textedited(text, start, length)
end

function MapEditor:textinput(t)
	self.ui:textinput(t)
end

function MapEditor:keypressed(key)
	self.ui:keypressed(key)
end

return MapEditor

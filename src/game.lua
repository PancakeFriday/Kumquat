local Moonshine = require 'moonshine'

local Player = require "player"
local Level = require "level"
local Gamera = require "gamera"
local MapEditor = require "mapeditor"

local Game = Object:extend()

function Game:new(is_editor, ...)
	self.player = Player(0,0,true)

	self.level = Level(100,30)

	self.level:newObject("grass", 0,10,10,3)
	self.level:newObject("saw", 6,8,10,3)

	local minx, miny, maxx, maxy = self.level:getBounds()
	self.camera = Gamera.new(minx*SCREENW, miny*SCREENH, (maxx-minx+1)*SCREENW, (maxy-miny+1)*SCREENH)
	self.camera:setScale(love.graphics.getWidth()/SCREENW, love.graphics.getHeight()/SCREENH)

	if is_editor then
		self.editor = MapEditor()
		self.editor:set_level(self.level)
		self.editor:set_camera(self.camera)
		self.editor:set_player(self.player)

		self.camera:setScale(love.graphics.getWidth()/SCREENW*2/3, love.graphics.getHeight()/SCREENH*2/3)
		self.camera:setPosition(self.player.x, self.player.y)
	end

	self:set_effects()

	local dark_colors = {
		{0.,0.05,0.05}, --used
		{0.7,0.12,0.86}, --used
		{0.1,0.7,0.8}, --used
		{1.0,0.17,0.51}, --used
		{0.3,0.3,0.3}, --used
		{0.2,0.5,0.75},
		{0.05,0.0,0.05}, --used
		{1.,1.,1.} --used
	}
	local light_colors = {
		{0.36,0.29,0.20},
		{0.12,0.45,0.12},
		{0.29,0.64,0.29},
		{0.51,0.35,0.20},
		{0.6,0.6,0.6},
		{0.0,0.5,0.75},
		{0.35,0.68,0.72},
		{1.,1.,1.}
	}
	self.palettes = {}
	local num_steps = 50
	for i=0,num_steps-1 do
		local int_colors = {}
		for j=1,#dark_colors do
			local c = {}
			for k=1,3 do
				c[k] = lume.lerp(dark_colors[j][k],light_colors[j][k],i/(num_steps-1))
			end
			table.insert(int_colors, c)
		end
		table.insert(self.palettes, int_colors)
	end
	self.palette_pos = 1
	self.palette_sign = -1

	self.time = 0
end

function Game:set_effects()
	if self.editor and not self.editor.test_mode then
		self.effect = Moonshine(Moonshine.effects.colorize)
			.chain(Moonshine.effects.chromasep)
	else
		self.effect = Moonshine(Moonshine.effects.colorize)
			.chain(Moonshine.effects.chromasep)
			.chain(Moonshine.effects.scanlines)
			.chain(Moonshine.effects.crt)
			.chain(Moonshine.effects.vignette)

		self.effect.chromasep.angle = math.pi
		self.effect.chromasep.radius = 1.
		self.effect.crt.feather = 0.01
		self.effect.crt.distortionFactor = {1.06,1.08}
		self.effect.scanlines.opacity = 0.1
		self.effect.scanlines.width = 5
		self.effect.scanlines.thickness = 0.7
		self.effect.vignette.opacity = 0.2
	end
end

function Game:update(dt)
	if self.editor and self.editor.set_test_mode then
		self.editor.set_test_mode = nil
		self.editor.test_mode = true
		self:set_effects()
		self.player:move_to(self.player.origin_x, self.player.origin_y)
		self.camera:setScale(love.graphics.getWidth()/SCREENW, love.graphics.getHeight()/SCREENH)
		self.camera:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	end
	if self.editor and self.editor.set_test_mode == false then
		self.editor.set_test_mode = nil
		self.editor.test_mode = false
		self:set_effects()
		self.player:move_to(self.player.origin_x, self.player.origin_y)
		self.camera:setScale(love.graphics.getWidth()/SCREENW*2/3, love.graphics.getHeight()/SCREENH*2/3)
		self.camera:setWindow(130,0,love.graphics.getWidth()-130,love.graphics.getHeight())
	end

	if not self.editor or (self.editor and self.editor.test_mode) then
		self.time = self.time % (2*math.pi)

		self:update_effects(dt)
		self.time = self.time + dt
	end

	if self.editor then
		self.editor:update(dt)
	end
	self.level:update(dt)
	self.player:update(dt)
end

function Game:update_effects(dt)
	self.effect.scanlines.phase = self.time*30

	if self.time + dt > 2*math.pi then
		--self.palette_sign = self.palette_sign*(-1)
	end
	self.palette_pos = lume.clamp(self.palette_pos+self.palette_sign*dt*40, 1, #self.palettes)
end

function Game:colorize()
	-- This is shite
	local p = math.floor(self.palette_pos)
	self.effect.colorize.color1 = self.palettes[p][1]
	self.effect.colorize.color2 = self.palettes[p][2]
	self.effect.colorize.color3 = self.palettes[p][3]
	self.effect.colorize.color4 = self.palettes[p][4]
	self.effect.colorize.color5 = self.palettes[p][5]
	self.effect.colorize.color6 = self.palettes[p][6]
	self.effect.colorize.color7 = self.palettes[p][7]
	self.effect.colorize.color8 = self.palettes[p][8]
end

function Game:draw_minimap()
	local px, py = self.player.x, self.player.y
	local _, _, rw, rh = self.camera:getVisible()
	px = math.floor(px/rw)
	py = math.floor(py/rh)
	local minx, miny, maxx, maxy = self.level:getBounds()
	for i,v in pairs(self.level.map) do
		local mode = "line"
		if v.x == px and v.y == py then
			mode = "fill"
		end
		local rx = love.graphics.getWidth() - 40 + (-maxx+v.x)*10
		local ry = 20 + (-miny+v.y)*10
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle(mode, rx, ry, 10, 10)
	end
end

function Game:draw_timer()
	love.graphics.setColor(1,1,1)
	love.graphics.arc("fill",love.graphics.getWidth()/2,40,20,-math.pi/2,-math.pi/2+(self.time)%(2*math.pi))
end

function Game:set_camera()
	if self.editor and not self.editor.test_mode then
		local px, py = self.editor.x, self.editor.y
		self.camera:setPosition(px, py)
	else
		local px, py = self.player.x, self.player.y
		local _, _, rw, rh = self.camera:getVisible()
		if self.level:isScreenAtPos(px/rw,py/rh) then
			local cx = math.floor(self.player.x/rw)*rw + rw/2
			local cy = math.floor(self.player.y/rh)*rh + rh/2
			self.camera:setPosition(cx, cy)
		end
	end
end

function Game:draw()
	love.graphics.setColor(1,1,1)
	self:set_camera()

	self:colorize()

	self.effect(function()
		self.camera:draw(function(l,t,w,h)
			-- Set the background color
			love.graphics.setColor(0.875,0.875,0.875)
			love.graphics.rectangle("fill",l,t,w,h)
			love.graphics.setColor(1,1,1)

			self.level:draw()
			self.player:draw()
		end)

		self:draw_timer()

		self:draw_minimap()
	end)

	if self.editor then
		self.camera:draw(function()
			self.editor:draw(self.camera)
		end)
		self.editor:draw_unscaled(self.camera)
	end
end

function Game:keypressed(key)
	self.player:keypressed(key)
	if self.editor then
		self.editor:keypressed(key)
	end
end

function Game:textinput(t)
	if self.editor then
		self.editor:textinput(t)
	end
end

function Game:textedited(text, start, length)
	if self.editor then
		self.editor:textedited(text, start, length)
	end
end

function Game:mousereleased(x,y,button)
	self.player:mousereleased(x,y,button)
	if self.editor then
		self.editor:mousereleased(x,y,button)
	end
end

return Game

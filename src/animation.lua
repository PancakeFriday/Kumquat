local AnimKey = Object:extend()

function AnimKey:new(ox, oy, fw, fh, num_frames, img)
	self.num_frames = num_frames
	self.img = img
	self.fw = fw
	self.fh = fh
	self.quads = {}
	for i=0,num_frames-1 do
		print(ox+i*fw)
		table.insert(self.quads, love.graphics.newQuad(ox+i*fw, oy, fw, fh, img:getWidth(), img:getHeight()))
	end
	self.time = 0
end

function AnimKey:update(dt)
	self.time = self.time + dt
end

function AnimKey:draw(hflipped)
	local it = math.floor(self.time/0.2)%(#self.quads)+1
	sx = 1
	if hflipped then sx = -1 end
	love.graphics.draw(self.img, self.quads[it], 0, 0, 0, sx, 1, self.fw/2)
end

Animation = Object:extend()

function Animation:new(src)
	self.img = love.graphics.newImage(src)
	self.hflipped = false
	self.cur_anim = ""
	self.keys = {}
end

function Animation:set_hflipped(b)
	self.hflipped = b
end

-- This function expects the frames to be in one row without gaps
function Animation:create(name, ox, oy, fw, fh, num_frames)
	self.keys[name] = AnimKey(ox, oy, fw, fh, num_frames, self.img)
end

function Animation:set(name)
	self.cur_anim = name
end

function Animation:update(dt)
	if self.keys[self.cur_anim] then
		self.keys[self.cur_anim]:update(dt)
	end
end

function Animation:draw()
	if self.keys[self.cur_anim] then
		self.keys[self.cur_anim]:draw(self.hflipped)
	end
end

return Animation

local LevelBlock = Object:extend()

function LevelBlock:new(t,x,y,w,h,isserver)
	self.type = t
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	if not isserver then
		local HC = require "HC"

		self.img = love.graphics.newImage("img/objects/"..t..".png")
		self.quads3x3 = {}
		self.quads2x2 = {}
		self.quad1x1 = nil
		for x=0,2 do
			self.quads3x3[x] = {}
			for y=0,2 do
				self.quads3x3[x][y] = love.graphics.newQuad(x*16,y*16,16,16,96,48)
			end
		end
		for x=0,1 do
			self.quads2x2[x] = {}
			for y=0,1 do
				self.quads2x2[x][y] = love.graphics.newQuad((x+3)*16,y*16,16,16,96,48)
			end
		end
		self.quad1x1 = love.graphics.newQuad(5*16,0,16,16,96,48)

		self.hitbox = HC.rectangle(self.x*16, self.y*16, self.w*16, self.h*16)
	end
end

function LevelBlock:getData()
	return {
		type=self.type,
		x=self.x,
		y=self.y,
		w=self.w,
		h=self.h
	}
end

function LevelBlock:draw()
	local minx = 0
	local miny = 0
	local maxx = self.w-1
	local maxy = self.h-1
	for ix=minx,maxx do
		for iy=miny,maxy do
			local xpos = (self.x+ix)*16
			local ypos = (self.y+iy)*16

			if self.w == 1 or self.h == 1 then
				love.graphics.draw(self.img, self.quad1x1, xpos, ypos)
			else
				if ix == minx and iy == miny then
					-- top left
					if self.w >= 3 then
						love.graphics.draw(self.img, self.quads3x3[0][0], xpos, ypos)
					elseif self.w == 2 then
						love.graphics.draw(self.img, self.quads2x2[0][0], xpos, ypos)
					elseif self.w == 1 then
					end
				elseif ix == maxx and iy == miny then
					-- top right
					if self.w >= 3 then
						love.graphics.draw(self.img, self.quads3x3[2][0], xpos, ypos)
					elseif self.w == 2 then
						love.graphics.draw(self.img, self.quads2x2[1][0], xpos, ypos)
					end
				elseif ix == minx and iy == maxy then
					-- bottom left
					if self.w >= 3 then
						love.graphics.draw(self.img, self.quads3x3[0][2], xpos, ypos)
					elseif self.w == 2 then
						love.graphics.draw(self.img, self.quads2x2[0][1], xpos, ypos)
					end
				elseif ix == maxx and iy == maxy then
					-- bottom right
					if self.w >= 3 then
						love.graphics.draw(self.img, self.quads3x3[2][2], xpos, ypos)
					elseif self.w == 2 then
						love.graphics.draw(self.img, self.quads2x2[1][1], xpos, ypos)
					end
				elseif ix == minx then
					-- left
					love.graphics.draw(self.img, self.quads3x3[0][1], xpos, ypos)
				elseif ix == maxx then
					--right
					love.graphics.draw(self.img, self.quads3x3[2][1], xpos, ypos)
				elseif iy == miny then
					-- top
					love.graphics.draw(self.img, self.quads3x3[1][0], xpos, ypos)
				elseif iy == maxy then
					-- bottom
					love.graphics.draw(self.img, self.quads3x3[1][2], xpos, ypos)
				else
					-- center
					love.graphics.draw(self.img, self.quads3x3[1][1], xpos, ypos)
				end
			end
		end
	end

	if DEV_DRAW then
		--self.hitbox:draw()
	end
end

return LevelBlock

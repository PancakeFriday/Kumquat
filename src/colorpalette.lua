local Colorpalette = Object:extend()

function Colorpalette:new(...)
	--assert(#{...} == 8, "Invalid number of arguments to Colorpalette:new(...)")

	self.colors = {}
	for i,v in pairs({...}) do
		-- v is like {r,g,b}
		for j,k in pairs(v) do
			table.insert(self.colors, tostring(k))
		end
	end

	local Moonshine = require 'moonshine'
	test = Moonshine(Moonshine.effects.colorize)
	test.colorize.find_color = {1,0.2,0.2}
	for i=1,8 do
		local Moonshine = require 'moonshine'
		self.effect = Moonshine(Moonshine.effects.colorize)
		self.effect.colorize.find_color={0.1,0,0}
	end
	print(test.colorize.find_color)
end

return Colorpalette

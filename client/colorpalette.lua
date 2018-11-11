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

	self.shaderString = [[
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 current_color = Texel(texture, texture_coords);
		if (current_color.r <= 0.175) // 0.125
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 0.30) // 0.25
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 0.425) // 0.375
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 0.55) // 0.5
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 0.675) // 0.625
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 0.8) // 0.75
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 0.925) // 0.875
			return vec4(%s,%s,%s,current_color.a);
		else if (current_color.r <= 1) // 1.0
			return vec4(%s,%s,%s,current_color.a);
		return current_color * color;
	}
	]]
	self.shader = love.graphics.newShader(string.format(self.shaderString, unpack(self.colors)))
end

return Colorpalette

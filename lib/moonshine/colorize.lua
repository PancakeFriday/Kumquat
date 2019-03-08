return function(moonshine)
  local distortionFactor
  local shader = love.graphics.newShader[[
	extern vec3 color1;
	extern vec3 color2;
	extern vec3 color3;
	extern vec3 color4;
	extern vec3 color5;
	extern vec3 color6;
	extern vec3 color7;
	extern vec3 color8;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 cc = Texel(texture, texture_coords);
		if (cc.r <= 0.175 && cc.g <= 0.175 && cc.b <= 0.175) // 0.125
			return vec4(color1,cc.a);
		else if (cc.r <= 0.3 && cc.g <= 0.3 && cc.b <= 0.3) // 0.25
			return vec4(color2,cc.a);
		else if (cc.r <= 0.425 && cc.g <= 0.425 && cc.b <= 0.425) // 0.375
			return vec4(color3,cc.a);
		else if (cc.r <= 0.55 && cc.g <= 0.55 && cc.b <= 0.55) // 0.5
			return vec4(color4,cc.a);
		else if (cc.r <= 0.675 && cc.g <= 0.675 && cc.b <= 0.675) // 0.625
			return vec4(color5,cc.a);
		else if (cc.r <= 0.8 && cc.g <= 0.8 && cc.b <= 0.8) // 0.75
			return vec4(color6,cc.a);
		else if (cc.r <= 0.925 && cc.g <= 0.925 && cc.b <= 0.925) // 0.875
			return vec4(color7,cc.a);
		else if (cc.r <= 1 && cc.g <= 1 && cc.b <= 1)
			return vec4(color8,cc.a);

		return cc * color;
		}
	]]

  local setters = {}

  setters.color1 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color1", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color2 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color2", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color3 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color3", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color4 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color4", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color5 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color5", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color6 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color6", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color7 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color7", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end
  setters.color8 = function(v)
    assert(type(v) == "table" and #v == 3, "Invalid value for `colors'")
    shader:send("color8", {
		tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0
	})
  end

  local defaults = {
	color1 = {0,0,0},
	color2 = {0.125,0.125,0.125},
	color3 = {0.25,0.25,0.25},
	color4 = {0.375,0.375,0.375},
	color5 = {0.5,0.5,0.5},
	color6 = {0.625,0.625,0.625},
	color7 = {0.75,0.75,0.75},
	color8 = {0.875,0.875,0.875},
  }

  return moonshine.Effect{
    name = "colorize",
    shader = shader,
    setters = setters,
    defaults = defaults
  }
end

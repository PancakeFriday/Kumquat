local LevelScreen = Object:extend()

function LevelScreen:new(x,y,neighbors)
	self.x = x or 0
	self.y = y or 0

	self.neighbors = neighbors or {
		top=false,
		bottom=false,
		right=false,
		left=false
	}
end

function LevelScreen:newNeighbor()
	local valid_neighbors = {}
	for i,v in pairs(self.neighbors) do
		if not v then
			table.insert(valid_neighbors, i)
		end
	end

	if #valid_neighbors == 0 then
		return false
	end

	local dir = lume.randomchoice(valid_neighbors)
	if dir == "top" then
		self.neighbors["top"] = true
		return LevelScreen(self.x, self.y-1), "top"
	elseif dir == "bottom" then
		self.neighbors["bottom"] = true
		return LevelScreen(self.x, self.y+1), "bottom"
	elseif dir == "left" then
		self.neighbors["left"] = true
		return LevelScreen(self.x-1, self.y), "left"
	elseif dir == "right" then
		self.neighbors["right"] = true
		return LevelScreen(self.x+1, self.y), "right"
	end
end

return LevelScreen

local Gamestate = {
	loaded = {},
	registered = {},
	names = {}
}

function Gamestate:register(s, n)
	if not lume.find(self.registered, s) then
		table.insert(self.registered, s)
		table.insert(self.names, n)
	else
		print("[WARNING] Class ".." already registered as a gamestate!")
	end
end

function Gamestate:set(s)
	if not lume.find(self.registered, s) then
		error("Class is not registered as a gamestate. Call register(...) before setting it")
	end

	self.state = s
	if not self.loaded[s] then
		self:load()
		self.loaded[s] = true
	end
end

function Gamestate:call(f, ...)
	if self.state then
		if self.state[f] then
			self.state[f](self.state, ...)
		end
	end
end

function Gamestate:load(...)
	self:call("load", ...)
end

function Gamestate:draw()
	self:call("draw")
end

function Gamestate:update(...)
	self:call("update", ...)
end

function Gamestate:textedited(...)
	self:call("textedited", ...)
end

function Gamestate:textinput(...)
	self:call("textinput", ...)
end

function Gamestate:keypressed(...)
	self:call("keypressed", ...)
end

function Gamestate:keyreleased(...)
	self:call("keyreleased", ...)
end

function Gamestate:mousepressed(...)
	self:call("mousepressed", ...)
end

function Gamestate:mousereleased(...)
	self:call("mousereleased", ...)
end

function Gamestate:wheelmoved(...)
	self:call("wheelmoved", ...)
end

function Gamestate:resize(...)
	self:call("resize", ...)
end

return Gamestate

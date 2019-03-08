DEV_MODE = false
DEV_DRAW = true

PORT = 22122

SCREENW, SCREENH = 320,240

-- no blurry images
love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

-- Add libraries to path
package.path = package.path .. ";src/?.lua"
package.path = package.path .. ";lib/?.lua"
package.path = package.path .. ";lib/?/init.lua"
local sock = require "sock"
local bitser = require "bitser"
Object = require "classic"
lume = require "lume"

Gamestate = require "gamestate"

-- Gamestates
local Menu = require "menu"
local Lobby = require "lobby"
local Game = require "game"

function love.load()
	-- Limit FPS
	min_dt = 1/60
	next_time = love.timer.getTime()

	-- Set random seed
	math.randomseed(os.time())

	Gamestate:register(Menu, "Menu")
	Gamestate:register(Game, "Game")
	Gamestate:set("Menu")
end

function love.update(dt)
	-- Limit FPS
	next_time = next_time + min_dt

	love.math.setRandomSeed(love.timer.getTime())
	math.randomseed(os.time())

	Gamestate:update(dt)

	if Client then
		Client:update()
	end
end

function love.draw()
	Gamestate:draw()

	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function love.textedited(text, start, length)
	Gamestate:textedited(text, start, length)
end

function love.textinput(t)
	Gamestate:textinput(t)
end

function love.keypressed(key)
	Gamestate:keypressed(key)
end

function love.keyreleased(key)
	Gamestate:keyreleased(key)
end

function love.mousepressed(x,y,button)
	Gamestate:mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
	Gamestate:mousereleased(x,y,button)
end

function love.wheelmoved(x,y)
	Gamestate:wheelmoved(x,y)
end

function love.resize(w,h)
	Gamestate:resize(w,h)
end

function love.quit()
	if Client then
		Client:disconnect()
		Client:update()
	end
end

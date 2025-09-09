local nest = love.system.getOS() == 'Windows' and require("nest").init({ console = "3ds" }) or nil
is3ds = string.lower(love._console) == '3ds' and love.system.getOS() == 'Horizon'
fontExtension = is3ds and '.bcfnt' or '.ttf'
imageExtension = is3ds and '.t3x' or '.png'

homescreen = nil
scene = nil

game = {
    debug = true,
    fonts = {},
    homescreen = true,
    songselect = false,
    ingame = false,
    selectedChart = '',
    chart = nil,
    music = nil,
    paused = false,
    background = nil,
    optionsopen = false,
    options = {
        bgdim = 0
    },
    reset = function()
        if game.music then
            game.music:stop() 
        end
        package.loaded['charts/' .. game.selectedChart .. '/chart'] = nil

        game.ingame = false
        game.songselect = false
        game.options = false
        game.homescreen = true
        game.chart = nil
        game.music = nil
        game.background = nil
        game.selectedChart = ''

        homescreen.reset()
        scene.reset()
    end
}

homescreen = require("scripts/homescreen")
scene = require("scripts/scene")

local targetFPS = 60
local accumulator = 0

function love.load()
    love.graphics.set3D(false)

    game.fonts.gamer = love.graphics.newFont("assets/fonts/gamer" .. fontExtension, is3ds and 48 or 36)
    game.fonts.gamersmall = love.graphics.newFont("assets/fonts/gamer" .. fontExtension, is3ds and 32 or 24)
    game.fonts.basic = love.graphics.newFont(is3ds and 28 or 24)
    game.fonts.basicsmall = love.graphics.newFont(is3ds and 24 or 18)
    game.fonts.basictiny = love.graphics.newFont(is3ds and 16 or 14)
end

function love.update(dt)
    accumulator = accumulator + dt
    if accumulator < 1 / targetFPS then return end
    accumulator = accumulator - 1 / targetFPS

    if game.homescreen then
        homescreen.update()
    end
    if game.ingame then
        scene.update()
    end
end

function love.draw(screen)
    if game.homescreen then
        homescreen.draw(screen)
    end
    if game.ingame then
        scene.draw(screen)
    end
end

function love.gamepadpressed(joystick, button)
    if game.homescreen then
        homescreen.handleInput(button)
    end
    if game.ingame then
        scene.handleInput(button)
    end
end

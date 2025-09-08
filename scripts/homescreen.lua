local homescreen = {}
local dots = {}
local menuIndex = 1
local songIndex = 1
local charts = love.filesystem.getDirectoryItems('charts')

for i = 1, 5 do
    table.insert(dots, {
        x = (i - 1) * -25,
        y = i * -30,
    })
end

local fadeouttimer = 0
local fadeout = false
function unInithomescreen()
    fadeout = true
end

homescreen.handleInput = function(button)
    if button == 'dpup' then
        if game.songselect then
            songIndex = math.max(songIndex - 1, 1)
        else
            menuIndex = math.max(menuIndex - 1, 1)
        end
    elseif button == 'dpdown' then
        if game.songselect then
            songIndex = math.min(songIndex + 1, #charts)
        else
            menuIndex = math.min(menuIndex + 1, 2)
        end
    end

    if game.songselect then
        if button == 'a' then
            game.selectedChart = charts[songIndex]
            game.chart = require('charts/' .. game.selectedChart .. '/chart')
            game.music = love.audio.newSource('charts/' .. game.selectedChart .. '/song.mp3', 'stream')

            scene.fadeout = true
            unInithomescreen()
        elseif button == 'b' then
            game.songselect = false
        end
    else
        if button == 'a' then
            if menuIndex == 1 then     -- play
                game.songselect = true
            elseif menuIndex == 2 then -- quit
                love.event.quit()
            end
        end
    end
end

homescreen.update = function()
    for i, v in pairs(dots) do
        v.x = v.x + 2
        v.y = v.y + 2
        if v.x >= 410 or v.y >= 250 then
            v.x = (v.x + 1) % 410
            v.y = (v.y + 1) % 250
        end
    end
end

homescreen.draw = function(screen)
    if screen ~= 'bottom' then
        love.graphics.setColor(0.8, 0.85, 0.75, 0.7)
        love.graphics.rectangle('fill', 0, 0, 400, 240)

        love.graphics.setColor(0.658, 0.733, 0.639, 1)
        for i, v in pairs(dots) do
            love.graphics.circle("fill", v.x, v.y, 5)
        end

        love.graphics.setFont(game.fonts.gamer)
        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('3ds RhythmGame', 16, 18)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('3ds RhythmGame', 18, 20)

        love.graphics.setFont(game.fonts.gamersmall)
        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('START', 23, 118)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('START', 25, 120)

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('EXIT', 23, 148)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('EXIT', 25, 150)

        if not game.songselect then
            local pointerpos = 120 + (menuIndex - 1) * 30
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
            love.graphics.print('>', 6, pointerpos - 1)
            love.graphics.setColor(0.6, 0.8, 0.6, 1)
            love.graphics.print('>', 7, pointerpos)
        end
    else
        love.graphics.setColor(0.8, 0.85, 0.75, 0.6)
        love.graphics.rectangle('fill', 0, 0, 320, 240)

        if game.songselect then
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            love.graphics.rectangle('fill', 30, 30, 320 - 30 * 2, 240 - 30 * 2)

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.setFont(game.fonts.basicsmall)
            love.graphics.print('>', 34, 34 + (songIndex - 1) * 22)
            for i, v in ipairs(charts) do
                love.graphics.print(v, i == songIndex and 52 or 34, 34 + (i - 1) * 22)
            end
        end
    end
    if fadeout then
        if fadeouttimer == 100 then
            game.homescreen = false
            game.ingame = true
            love.graphics.setFont(game.fonts.basic)
        else
            fadeouttimer = fadeouttimer + 1
        end

        love.graphics.setColor(0.95, 0.95, 0.95, fadeouttimer / 100)
        love.graphics.rectangle('fill', 0, 0, 400, 240)
    end
end

homescreen.reset = function()
    fadeouttimer = 0
    fadeout = false
    menuIndex = 1
    songIndex = 1
end

return homescreen

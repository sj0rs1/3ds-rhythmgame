local homescreen = {}
local dots = {}
local menuIndex = 1
local songIndex = 1
local optionIndex = 1
local selectedInfo = { difficulty = 0, duration = '00:00', background = nil }
local charts = love.filesystem.getDirectoryItems('charts')
local options = {}
options = {
    {
        type = 'slider',
        value = 0,
        min = 0,
        modifier = 5,
        max = 100,
        name = 'Background dim',
        update = function(i, value)
            options[i].value = value
            game.options.bgdim = value
        end
    },
    {
        type = 'toggle',
        value = false,
        name = 'Flip screens',
        update = function(i, value)
            options[i].value = value
            game.options.flipped = value
        end
    },
}

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
    selectedInfo = { difficulty = 0, duration = '00:00', background = nil }
end

function updateSong()
    local chart = love.filesystem.load("charts/" .. charts[songIndex] .. "/chart.lua")()
    local difficulty = chart.difficulty
    local duration = chart.finishCount
    chart = nil
    collectgarbage()
    selectedInfo.duration = string.format("%02d:%02d", math.floor(duration / 3600), (math.floor(duration / 60) % 60))
    selectedInfo.difficulty = difficulty
    if love.filesystem.getInfo('charts/' .. charts[songIndex] .. '/background' .. imageExtension) then
        selectedInfo.background = love.graphics.newImage('charts/' ..
            charts[songIndex] .. '/background' .. imageExtension)
    else
        selectedInfo.background = nil
    end
end

homescreen.handleInput = function(button)
    if game.options.flipped then
        if button == 'dpup' then
            button = 'dpdown'
        elseif button == 'dpdown' then
            button = 'dpup'
        end
    end
    
    if button == 'dpup' then
        if game.songselect then
            songIndex = math.max(songIndex - 1, 1)
            updateSong()
        elseif game.optionsopen then
            optionIndex = math.max(optionIndex - 1, 1)
        else
            menuIndex = math.max(menuIndex - 1, 1)
        end
    elseif button == 'dpdown' then
        if game.songselect then
            songIndex = math.min(songIndex + 1, #charts)
            updateSong()
        elseif game.optionsopen then
            optionIndex = math.min(optionIndex + 1, #options)
        else
            menuIndex = math.min(menuIndex + 1, 3)
        end
    end

    if game.songselect then
        if button == 'a' then
            game.selectedChart = charts[songIndex]
            game.chart = require('charts/' .. game.selectedChart .. '/chart')
            if love.filesystem.getInfo('charts/' .. game.selectedChart .. '/song.mp3') then
                game.music = love.audio.newSource('charts/' .. game.selectedChart .. '/song.mp3', 'stream')
            end
            if love.filesystem.getInfo('charts/' .. game.selectedChart .. '/background' .. imageExtension) then
                game.background = love.graphics.newImage('charts/' ..
                    game.selectedChart .. '/background' .. imageExtension)
            end

            scene.fadeout = true
            unInithomescreen()
        elseif button == 'b' then
            game.songselect = false
        end
    elseif game.optionsopen then
        local option = options[optionIndex]
        if button == 'a' then
            if option.type == 'toggle' then
                options[optionIndex].value = not options[optionIndex].value
            end
        elseif button == 'dpleft' then
            if option.type == 'slider' then
                option.update(optionIndex, math.max(option.min, option.value - option.modifier))
            end
        elseif button == 'dpright' then
            if option.type == 'slider' then
                option.update(optionIndex, math.min(option.max, option.value + option.modifier))
            end
        elseif button == 'b' then
            local settingsSaved = {}
            for i, v in pairs(options) do
                settingsSaved[v.name] = v.value
            end
            love.filesystem.write('settings.json', json.encode(settingsSaved, { indent = true }))
            game.optionsopen = false
        end
    else
        if button == 'a' then
            if menuIndex == 1 then -- play
                updateSong()
                game.songselect = true
            elseif menuIndex == 2 then -- options
                game.optionsopen = true
            elseif menuIndex == 3 then -- quit
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
        love.graphics.print('OPTIONS', 23, 148)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('OPTIONS', 25, 150)

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('EXIT', 23, 178)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('EXIT', 25, 180)

        if not game.songselect and not game.optionsopen then
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
            love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
            love.graphics.rectangle('fill', 10, 10, 320 - 10 * 2, 240 - 10 * 2)

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.setFont(game.fonts.basictiny)
            love.graphics.print('>', 14, 14 + (songIndex - 1) * 22)
            for i, v in ipairs(charts) do
                love.graphics.print(v, i == songIndex and 34 or 14, 14 + (i - 1) * 22)
            end

            love.graphics.print('Difficulty: ' .. selectedInfo.difficulty, 220, 14)
            love.graphics.print('Duration: ' .. selectedInfo.duration, 188, 36)
            if selectedInfo.background then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(selectedInfo.background, 164, 60, 0, 0.435, 0.435)
            end
        end

        if game.optionsopen then
            love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
            love.graphics.rectangle('fill', 10, 10, 320 - 10 * 2, 240 - 10 * 2)

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.setFont(game.fonts.basicsmall)
            love.graphics.print('>', 14, 14 + (optionIndex - 1) * 22)
            for i, v in ipairs(options) do
                love.graphics.print(
                    v.name ..
                    ' ' ..
                    (v.type == 'slider' and i == optionIndex and '<- ' or '') ..
                    tostring(v.value) .. (v.type == 'slider' and i == optionIndex and ' ->' or ''),
                    i == optionIndex and 34 or 14, 14 + (i - 1) * 22)
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

if love.filesystem.getInfo('settings.json') then
    local saved = json.decode(love.filesystem.read('settings.json'))
    for i, v in pairs(options) do
        if saved[v.name] then
            v.update(i, saved[v.name])
        end
    end
end

return homescreen

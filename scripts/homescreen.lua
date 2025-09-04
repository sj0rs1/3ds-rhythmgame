local homescreen = {}
local dots = {}
local menuIndex = 1

local tempcount = 0

for i = 1, 5 do
    table.insert(dots, {
        x = (i - 1) * -25,
        y = i * -30,
    })
end

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
        menuIndex = math.max(menuIndex - 1, 1)
    elseif button == 'dpdown' then
        menuIndex = math.min(menuIndex + 1, 2)
    end

    if button == 'a' then
        if menuIndex == 1 then -- play
            unInithomescreen()
        elseif menuIndex == 2 then -- quit
            love.event.quit()
        end
    end
end

homescreen.moveDots = function()
    for i, v in pairs(dots) do
        v.x = v.x + 2
        v.y = v.y + 2
        if v.x >= 410 or v.y >= 250 then
            v.x = (v.x + 1) % 410
            v.y = (v.y + 1) % 250
        end
    end
    if tempcount == 60 then
        tempcount = 0
    end
    tempcount = tempcount + 1
end

homescreen.drawHomescreen = function(screen)
    if screen ~= 'bottom' then
        love.graphics.setColor(0.968, 0.956, 0.917, 1)
        love.graphics.rectangle('fill', 0, 0, 400, 240)

        love.graphics.setColor(0.658, 0.733, 0.639, 1)
        for i, v in pairs(dots) do
            love.graphics.circle("fill", v.x, v.y, 5)
        end

        love.graphics.setFont(game.fonts.gamer)
        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('EPIC RHYTHM GAME', 18, 18)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('EPIC RHYTHM GAME', 20, 20)

        love.graphics.setFont(game.fonts.gamersmall)
        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('START', 23, 118)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('START', 25, 120)

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('EXIT', 23, 148)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('EXIT', 25, 150)

        local pointerpos = 120 + (menuIndex-1) * 30
        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.print('>', 6, pointerpos - 1)
        love.graphics.setColor(0.6, 0.8, 0.6, 1)
        love.graphics.print('>', 7, pointerpos)
    else
        love.graphics.setColor(0.968, 0.956, 0.917, 0.95)
        love.graphics.rectangle('fill', 0, 0, 320, 240)

        love.graphics.setColor(0,0,0,1)
        love.graphics.print(tostring(tempcount))
    end

    if fadeout then
        if fadeouttimer == 100 then
            game.homescreen = false
            game.ingame = true
            love.graphics.setFont(game.fonts.basic)
        else
            fadeouttimer = fadeouttimer + 1
        end
        love.graphics.setColor(0.95, 0.95, 0.95, fadeouttimer/100)
        love.graphics.rectangle('fill', 0, 0, 400, 240)
    end
end

return homescreen

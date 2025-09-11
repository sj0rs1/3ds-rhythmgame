local scene = { fadeout = true }
local circles = {}
local hitScores = {}

local white = 1
local firsttouch = false
local startgame = false

local currentX = -20
local currentY = -20
local score = 0
local combo = 0

local gameCounter = 0

local circleCount = 0
local hitScoreCount = 0

local resetTriggered = false

function makeCircle(x, y, size, color, number, approach, active)
    table.insert(circles, {
        x = x,
        y = y,
        size = size,
        activefrom = active,
        approachtime = approach,
        approachtotal = approach,
        id = circleCount,
        color = color,
        number = number
    })
    circleCount = circleCount + 1
end

function makeHitScore(x, y, text, color)
    table.insert(hitScores, {
        text = text,
        x = x,
        y = y,
        color = color,
        id = hitScoreCount,
        time = gameCounter + 60
    })
    hitScoreCount = hitScoreCount + 1
end

function removeCircle(id)
    for i, circle in pairs(circles) do
        if circle.id == id then
            table.remove(circles, i)
            break
        end
    end
end

function removeHitScore(id)
    for i, hitscore in pairs(hitScores) do
        if hitscore.id == id then
            table.remove(hitScores, i)
            break
        end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if not game.ingame then return end
    firsttouch = true
    currentX = x
    currentY = game.options.flipped and 240 - y or y
end

function love.touchreleased(id)
    currentX = -20
    currentY = -20
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if not game.ingame then return end
    currentX = x
    currentY = game.options.flipped and 240 - y or y
end

function getTouchingCircle()
    for i, circle in pairs(circles) do
        if gameCounter >= circle.activefrom then
            local circleCenterX = circle.x + circle.size
            local circleCenterY = circle.y + circle.size

            local dx = circleCenterX - currentX
            local dy = circleCenterY - currentY

            local rSum = circle.size + 5
            if dx * dx + dy * dy <= rSum * rSum then
                return circle, i
            end
        end
    end
    return nil
end

function updateCircles()
    for i, v in pairs(circles) do
        if gameCounter >= v.activefrom then
            v.approachtime = math.max(-3, v.approachtime - 1)
            if v.approachtime <= -3 then
                makeHitScore(v.x + 40 + v.size / 2 - 3, v.y + v.size / 2 - 3, 'X', { 1, 0, 0 })
                combo = 0
                table.remove(circles, i)
            end
        end
    end
end

function updateHitScores()
    for i, v in pairs(hitScores) do
        if gameCounter >= v.time then
            table.remove(hitScores, i)
        end
    end
end

local initializedChart = false
function initChart()
    initializedChart = true
    for _, v in pairs(game.chart.circles) do
        makeCircle(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
    end
end

scene.update = function()
    if resetTriggered and white <= 0 then
        resetTriggered = false
        game.reset()
        return
    end
    if not initializedChart then
        initChart()
    end
    if not startgame and initializedChart and firsttouch and white <= 0 then
        startgame = true
    end
    if game.paused then return end
    if not startgame then return end
    if not game.chart then return end
    if gameCounter >= game.chart.finishCount and not resetTriggered then
        resetTriggered = true
        scene.fadeout = false
        white = 1
        return
    end
    gameCounter = gameCounter + 1
    if gameCounter == 1 and game.music then
        game.music:play()
    end
    updateCircles()
    updateHitScores()
end

scene.handleInput = function(button)
    if not startgame then return end
    if game.paused then
        if button == 'start' then
            game.paused = false
            if game.music then
                game.music:seek(gameCounter / 60, "seconds")
                game.music:play()
            end
        end
    else
        if button == 'start' and not is3ds then
            game.paused = true
            if game.music then
                game.music:pause()
            end
        elseif button == 'select' then
            game.reset()
            return
        else
            local circle, index = getTouchingCircle()
            if circle then
                if index == 1 then -- correct circle
                    local at = circle.approachtime
                    if at <= 12 then
                        makeHitScore(circle.x + 40 + circle.size / 2 - 3, circle.y + circle.size / 2 - 3, '300',
                            { 0, 0, 1 })
                        score = score + 300
                        combo = combo + 1
                    elseif at <= 17 then
                        makeHitScore(circle.x + 40 + circle.size / 2 - 3, circle.y + circle.size / 2 - 3, '100',
                            { 0, 0.5, 0 })
                        score = score + 100
                        combo = combo + 1
                    elseif at <= 23 then
                        makeHitScore(circle.x + 40 + circle.size / 2 - 3, circle.y + circle.size / 2 - 3, '50',
                            { 0.8, 0, 0 })
                        score = score + 50
                        combo = combo + 1
                    else
                        makeHitScore(circle.x + 40 + circle.size / 2 - 3, circle.y + circle.size / 2 - 3, 'X',
                            { 1, 0, 0 })
                        combo = 0
                    end
                    removeCircle(circle.id)
                else -- incorrect circle (wrong order)
                    makeHitScore(circle.x + 40 + circle.size / 2 - 3, circle.y + circle.size / 2 - 3, 'X', { 1, 0, 0 })
                end
            end
        end
    end
end

scene.draw = function(screen)
    love.graphics.setFont(game.fonts.basicsmall)
    if screen ~= 'bottom' then
        --background
        if game.background then
            love.graphics.setColor(1, 1, 1, 1 - game.options.bgdim / 100)
            love.graphics.draw(game.background, 40, 0)
        end
        --borders
        love.graphics.setColor(0.15, 0.15, 0.15, 1)
        love.graphics.rectangle('fill', 0, 0, 40, 240)
        love.graphics.rectangle('fill', 360, 0, 400, 400)

        love.graphics.setColor(1, 1, 1, 1)

        --corners
        love.graphics.line(40, 1, 40, 11)
        love.graphics.line(40, 1, 50, 1)

        love.graphics.line(40, 229, 40, 239)
        love.graphics.line(40, 239, 50, 239)

        love.graphics.line(360, 1, 350, 1)
        love.graphics.line(360, 1, 360, 11)

        love.graphics.line(360, 239, 350, 239)
        love.graphics.line(360, 229, 360, 239)

        --draw click circles
        if startgame then
            for i = #circles, 1, -1 do
                local v = circles[i]
                if v and gameCounter >= v.activefrom then
                    local size = v.size

                    --white outline
                    love.graphics.setColor(1, 1, 1, 0.8)
                    love.graphics.circle("fill", v.x + 40 + size, v.y + size, size + 2)

                    --circle
                    love.graphics.setColor(v.color[1], v.color[2], v.color[3], 1)
                    love.graphics.circle("fill", v.x + 40 + size, v.y + size, size)

                    --approach circle
                    if v.approachtime >= 0 then
                        love.graphics.setColor(1,1,1, 0.8)
                        love.graphics.circle("line", v.x + 40 + size, v.y + size,
                            size + (30 * v.approachtime / v.approachtotal) + 1)
                        love.graphics.circle("line", v.x + 40 + size, v.y + size,
                            size + (30 * v.approachtime / v.approachtotal) - 1)
                        love.graphics.setColor(0,0,0, 0.8)
                        love.graphics.circle("line", v.x + 40 + size, v.y + size,
                            size + (30 * v.approachtime / v.approachtotal))
                    end

                    --number text
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.printf(tostring(v.number), v.x + 41, v.y + 10, v.size * 2, "center")
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.printf(tostring(v.number), v.x + 40, v.y + 9, v.size * 2, "center")
                end
            end
        end

        if game.chart and game.chart.draw then
            game.chart.draw(gameCounter)
        end

        --draw hitscores
        for i, v in pairs(hitScores) do
            love.graphics.setColor(v.color[1], v.color[2], v.color[3], 1)
            love.graphics.print(v.text, v.x, v.y)
        end

        --draw cursor
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", currentX + 40, currentY, 6)
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.circle("fill", currentX + 40, currentY, 5)
    else
        love.graphics.circle("fill", currentX, currentY, 5)
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle('fill', 0, 0, 320, 240)

        if currentX == -20 and not firsttouch then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.rectangle('fill', 50, 50, 320 - 50 * 2, 240 - 50 * 2)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Touch here!", 0, 105, 320, "center")
        end

        if game.paused then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.rectangle('fill', 50, 50, 320 - 50 * 2, 240 - 50 * 2)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Paused", 0, 105, 320, "center")
        end

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(game.fonts.basictiny)
        love.graphics.print('score: ' .. tostring(score), 2, 210)
        love.graphics.print('combo: ' .. tostring(combo) .. 'x', 2, 224)

        if game.debug then
            local a = 0
            love.graphics.print(tostring(gameCounter), 0, 0)
            -- for i, v in pairs(circles) do
            --     a = a + 1
            --     love.graphics.print(tostring(i) .. ' ' .. tostring(v), 0, a * 20 - 20)
            -- end
        end
    end
    if white > 0 then
        white = white - 0.01
        love.graphics.setColor(1, 1, 1, scene.fadeout and white or 1 - white)
        love.graphics.rectangle('fill', 0, 0, 400, 240)
    end
end

scene.reset = function()
    circles = {}
    hitScores = {}

    white = 1
    firsttouch = false
    startgame = false
    initializedChart = false

    currentX = -20
    currentY = -20
    score = 0
    combo = 0

    gameCounter = 0

    circleCount = 0
    hitScoreCount = 0
end

return scene

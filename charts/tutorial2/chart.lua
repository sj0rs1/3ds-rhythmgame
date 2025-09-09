local chart = {
    difficulty = 2,
    finishCount = 1400,
    circles = {
        { 40, 110, 20, { 1.0, 0.2, 0.2 }, 1, 90, 780 },
        { 140, 110, 20, { 1.0, 0.2, 0.2 }, 2, 90, 900 },
        { 240, 110, 20, { 1.0, 0.2, 0.2 }, 3, 90, 1020 },
    }
}

--custom code
local messages = {
    { start = 20, finish = 150, message = 'Welcome to the tutorial!' },
    { start = 150, finish = 360, message = 'Using the touchscreen, place and move your cursor on the screen.' },
    { start = 360, finish = 660, message = 'When a circle appears, hover over it and use any button to click when the approach circle overlaps.' },
    { start = 660, finish = 780, message = 'Try it out!' },
    { start = 1170, finish = 1290, message = "That's it!\n\nGood luck!" },
}
chart.draw = function(gameCounter)
    love.graphics.setFont(game.fonts.basicsmall)
    love.graphics.setColor(1, 1, 1, 1)
    for i, v in pairs(messages) do
        if gameCounter >= v.start and gameCounter <= v.finish then
            --love.graphics.print(v.message, v.x, v.y)
            love.graphics.printf(v.message, 40, 20, 320, "center")
        end
    end
end


return chart

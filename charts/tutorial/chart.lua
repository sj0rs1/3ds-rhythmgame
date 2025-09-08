local chart = {
    finishCount = 200,
    circles = {
        { 40, 40, 20, { 1.0, 0.2, 0.2 }, 1, 120, 20 }
    }
}

--custom code
chart.draw = function()
    love.graphics.print(1,30,30)
end


return chart

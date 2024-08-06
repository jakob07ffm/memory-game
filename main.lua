function love.load()
    math.randomseed(os.time())
    boardSize = 4
    colors = {}
    for i = 1, boardSize * boardSize / 2 do
        colors[#colors + 1] = { math.random(), math.random(), math.random() }
    end
    cards = {}
    for i = 1, 2 do
        for j = 1, #colors do
            cards[#cards + 1] = { color = colors[j], revealed = false, matched = false, flip = 0 }
        end
    end
    for i = #cards, 2, -1 do
        local j = math.random(i)
        cards[i], cards[j] = cards[j], cards[i]
    end
    firstPick = nil
    secondPick = nil
    pairsFound = 0
    attempts = 0
    startTime = love.timer.getTime()
    gameState = "start"
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == "play" then
        local col = math.ceil(x / 100)
        local row = math.ceil(y / 100)
        local index = (row - 1) * boardSize + col
        if index <= #cards and not cards[index].revealed and cards[index].flip == 0 then
            cards[index].flip = 1
            if not firstPick then
                firstPick = index
            elseif not secondPick then
                secondPick = index
                attempts = attempts + 1
            end
        end
    elseif button == 1 and gameState == "start" then
        gameState = "play"
        startTime = love.timer.getTime()
    end
end

function love.update(dt)
    if firstPick and secondPick and cards[firstPick].flip == 2 and cards[secondPick].flip == 2 then
        if cards[firstPick].color == cards[secondPick].color then
            cards[firstPick].matched = true
            cards[secondPick].matched = true
            pairsFound = pairsFound + 1
        else
            cards[firstPick].revealed = false
            cards[secondPick].revealed = false
        end
        firstPick = nil
        secondPick = nil
    end

    for i = 1, #cards do
        if cards[i].flip == 1 then
            cards[i].flip = 2
            cards[i].revealed = true
        elseif cards[i].flip == 2 and not cards[i].revealed then
            cards[i].flip = 3
        elseif cards[i].flip == 3 then
            cards[i].flip = 0
        end
    end

    if pairsFound == #cards / 2 and gameState == "play" then
        gameState = "end"
        endTime = love.timer.getTime()
    end
end

function love.draw()
    if gameState == "start" then
        love.graphics.printf("Memory Game\nClick to Start", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    elseif gameState == "play" then
        for i = 1, #cards do
            local x = ((i - 1) % boardSize) * 100
            local y = math.floor((i - 1) / boardSize) * 100
            if cards[i].revealed or cards[i].matched then
                love.graphics.setColor(cards[i].color)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("fill", x, y, 100, 100)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Time: " .. string.format("%.1f", love.timer.getTime() - startTime), 10, 10)
        love.graphics.print("Attempts: " .. attempts, 10, 30)
    elseif gameState == "end" then
        love.graphics.printf("You win!\nTime: " .. string.format("%.1f", endTime - startTime) .. "\nAttempts: " .. attempts, 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end
end

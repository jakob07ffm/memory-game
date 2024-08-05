
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
            cards[#cards + 1] = { color = colors[j], revealed = false, matched = false }
        end
    end
    for i = #cards, 2, -1 do
        local j = math.random(i)
        cards[i], cards[j] = cards[j], cards[i]
    end
    firstPick = nil
    secondPick = nil
    pairsFound = 0
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local col = math.ceil(x / 100)
        local row = math.ceil(y / 100)
        local index = (row - 1) * boardSize + col
        if index <= #cards and not cards[index].revealed then
            cards[index].revealed = true
            if not firstPick then
                firstPick = index
            elseif not secondPick then
                secondPick = index
            end
        end
    end
end

function love.update(dt)
    if firstPick and secondPick then
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
end

function love.draw()
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
    if pairsFound == #cards / 2 then
        love.graphics.print("You win!", 150, 50)
    end
end

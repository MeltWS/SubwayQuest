name = "Thief Quest"
author = "Melt"

description = [[This script will clear the Thief quest, buy one thief TM, and teach it.]]

local pf          = require "Pathfinder/Pathfinder/Maps_Pathfind" -- requesting table with methods of Pathfinder
local qStep       = 1 -- quest step
local stepDialogs = { -- Dialog checks for knowing when the quest advance.
    "Those things can be anywhere in this mart..",
    "Do you want to buy TM96 - Thief from me for 7500 each?"
}
local itemCount   = 0
local itemLocs    = {
    {"Celadon Mart 4", 6, 3},
    {"Celadon Mart 2", 13, 12},
    {"Celadon Mart 1", 17, 6},
}
local keepMoves = {"Cut", "Surf", "Dive", "Rock Smash"}
local stepAction  = {}

local function findItem(itemIndex)
    local nextLoc = itemLocs[itemIndex]
    if nextLoc then
        local map = nextLoc[1]
        local npcX = nextLoc[2]
        local npcY = nextLoc[3]
        if pf.MoveTo(map) then
            return true
        elseif isNpcOnCell(npcX, npcY) then
            return talkToNpcOnCell(npcX, npcY)
        else
            itemCount = itemCount + 1
            return findItem(itemCount + 1)
        end
    end
    return false
end

stepAction[1] = function() -- talk to the thief NPC on top of Celadon Mart
    if not pf.MoveTo("Celadon Mart 6") then
        return talkToNpcOnCell(7, 7)
    end
end

stepAction[2] = function()
    if not findItem(itemCount + 1) and not pf.MoveTo("Celadon Mart 6") then
        talkToNpcOnCell(7, 7)
    end
end

stepAction[3] = function()
    game.tryTeachMove("Thief", "TM96")
end

function onStart()
    if game.hasPokemonWithMove("Thief") then
        fatal("Has Pokemon with move Thief, quest terminated.")
    elseif hasItem("TM96") then
        log("Already has item TM96 Thief, Skip to learning phase.")
        qStep = 3
    end
end

function onPathAction()
    stepAction[qStep]()
end

function onBattleAction()
    return run() or sendAnyPokemon() or attack()
end

function onDialogMessage(message)
    for i, check in ipairs(stepDialogs) do
        if message == check then
            qStep = i + 1
            if i == 3 and hasItem("TM96") then
                return pushDialogAnswer("I don't really need it right now") -- default proshine input will buy it otherwise.
            end
        end
    end
end

function onLearningMove()
    return forgetAnyMoveExcept(keepMoves)
end
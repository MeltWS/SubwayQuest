name = "Thief Quest"
author = "Melt"

description = [[This script will clear the Thief quest, and buy one thief TM]]

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
local stepAction  = {}

local function findNextItem(map, npcX, npcY)
    if pf.MoveTo(map) then
        return
    elseif isNpcOnCell(npcX, npcY) then
        talkToNpcOnCell(npcX, npcY)
    else itemCount = itemCount + 1
    end
end
stepAction[1] = function() -- talk to the thief NPC on top of Celadon Mart
    if not pf.MoveTo("Celadon Mart 6") then
        return talkToNpcOnCell(7, 7)
    end
end

stepAction[2] = function()
    local nextLoc = itemLocs[itemCount]
    if nextLoc then
        findNextItem(nextLoc[1], nextLoc[2], nextLoc[3])
    elseif not pf.MoveTo("Celadon Mart 6") then
        talkToNpcOnCell(7, 7)
    end
end

stepAction[3] = function()
    fatal("Thief quest is over.")
end

function onStart()
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
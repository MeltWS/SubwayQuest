name = "Subway Quest"
author = "Melt"

description = [[This script will clear the subway quest]]

local pf          = require "Pathfinder/Maps_Pathfind" -- requesting table with methods
local game        = require "Lib/gamelib"
local stealMove   = "steal move"
local resolveExce = false
local feather = false
local qStep       = 1
local stepAction  = {}
local dialogs = {
    [1] = "Hope someone will help him, he is somewhere on Route 16.",
    [2] = "I have no idea where my brother is, but he would never leave Kanto, so I guess that's a start..",
    [3] = "You have received Yorkie's Parcel!",
    [4] = "If you are looking for the Nocturnal Feather, look for Pidgeotto on this Route.",
    [6] = "Hope you enjoy your gift, and also talked to the managers.",
    [7] = "Enjoying our Subway System?",
}
local brother = {
    {"Saffron Pokemart", 13, 7},
    {"Route 10", 20, 25},
    {"Digletts Cave", 17, 24},
    {"Victory Road Kanto 2F", 38, 24},
    {"Route 21", 26, 40},
}
local exce = {
    ["Victory Road Kanto 2F"] = {{"Victory Road kant 3F", function() return moveToCell(35,33) end},
                                {"Victory Road kant 2F", function() return moveToCell(62,11) end},
                                {"Victory Road kant 2F", function() return moveToCell(57,25) end},
                                {"Victory Road kant 3F", function() return moveToCell(61, 35) end}
    },
    ["Route 10"] = {{"Route 9", function() return moveToCell(91, 33) end},
                    {"Route 10", function() return pf.MoveTo("Route 9") end}, 
                    {"Rock Tunnel 1", function() return pf.MoveTo("Route 9") end}, 
                    {"Rock Tunnel 2", function() return pf.MoveTo("Route 9") end}, 
    }
}

local function isDoable()
    return assert(hasItem("Bicycle"), "Bot does not have Bicycle") and assert((getMoney() > 50000), "Not enough Money")
end

local function needPC()
	if getPokemonHealth(1) == 0 or getRemainingPowerPoints(1, stealMove) == 0 then
		return true
	else return false
	end 
end

local function setStealMove()
    local i = game.getPokemonNumberWithMove("Thief")
    if i then
        stealMove = "Thief"
    else
        i = game.getPokemonNumberWithMove("Covet")
	    if not i then
            return log("You need a Pokemon with Thief or Covet.")
        end
        stealMove = "Covet"
    end
    if i == 1 then return true end
    return assert(swapPokemonWithLeader(getPokemonName(i)), "Failed to swap Pokemon with leader.")
end

local function exceMove(_,v)
    if getMapName() == v[1] then
        return v[2]()
    end
    return false
end

local function talkToBrother(map, Npcx, Npcy)
    if getMapName() == map and talkToNpcOnCell(Npcx, Npcy) then
        resolveExce = false
    elseif assert(game.iterTable(exce[map], exceMove), "Could not find direction for exception, exceMap :" .. map) then
        resolveExce = true
    end
end

stepAction[1] = function() -- talk to npc in Saffron City Station
    if not pf.MoveTo("Saffron City Station") then
        return talkToNpcOnCell(12,16)
    end
end

stepAction[2] = function() -- talk to npc in Route 16 house
    if not pf.MoveTo("Route 16 house") then
        return talkToNpcOnCell(5,7)
    end
end

stepAction[3] = function() -- search for npc brother on the map
    local map     = brother[1][1]
    local Npcx    = brother[1][2]
    local Npcy    = brother[1][3]

    if resolveExce then
        return talkToBrother(map, Npcx, Npcy)
    elseif not pf.MoveTo(map) then
        if isNpcOnCell(Npcx, Npcy) then
            return talkToBrother(map, Npcx, Npcy)
        else
            table.remove(brother, 1)
            pf.MoveTo(brother[1][1])
        end
    end
    if not brother[1] then error("looked for every spot and did not find brother npc") end
end

stepAction[4] = stepAction[2]

stepAction[5] = function()
    if feather then
        qStep = 6
        if not hasItem("Nocturnal Feather") then
            assert(takeItemFromPokemon(1), "Failed to retrieve Feather from leader.")
        else stepAction[6]()
        end
    elseif needPC() then
        pf.UseNearestPokecenter()
    elseif getMapName() == "Route 16 Stop House" then
        moveToCell(20,6)
    elseif not pf.MoveTo("Route 16") then
        if game.inRectangle(70,3,91,21) then
            moveToGrass()
        else
            moveToMap("Route 16 Stop House")
        end
    end
end

stepAction[6] = stepAction[2]
stepAction[7] = stepAction[1]
stepAction[8] = function() fatal("Subway quest completed.") end

function onStart()
    isDoable()
    setStealMove()
    feather = hasItem("Nocturnal Feather")
end

function onPathAction()
    stepAction[qStep]()
end

function onBattleAction()
    if qStep ~= 5 then
        return run() or attack() or sendAnyPokemon()
    else
        if getOpponentName() ~= "Pidgeotto" or needPC() then
            return run() or sendAnyPokemon() or attack()
        else return useMove(stealMove) or attack() or run() or sendAnyPokemon()
        end
    end
end

function onDialogMessage(message)
    for i, check in pairs(dialogs) do
        if message == check then
            qStep = i + 1
        end 
    end
end

function onBattleMessage(message)
    if qStep == 5 and string.find(message, "'s Nocturnal Feather!") then
        feather = true
    end
end
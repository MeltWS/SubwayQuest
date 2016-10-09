local game = {}

function game.inRectangle(UpperX, UpperY, LowerX, LowerY)
	local ActX = getPlayerX()
	local ActY = getPlayerY()
	if (ActX >= UpperX and ActX <= LowerX) and (ActY >= UpperY and ActY <= LowerY) then
		return true
	else
		return false
	end
end

function game.getPokemonNumberWithMove(Move)
	for i=1, getTeamSize(), 1 do
		if hasMove(i, Move) then
			return i
		end
	end
	return false
end

local pokemonIdTeach = 1
function game.tryTeachMove(movename, ItemName)
    if not game.hasPokemonWithMove(movename) then
        if pokemonIdTeach > getTeamSize() then
            return fatal("No pokemon in this Team can learn: ".. ItemName)
        else
            log("Pokemon: " .. getPokemonName(pokemonIdTeach) .. " Try Learning: " .. ItemName)
            useItemOnPokemon(ItemName, pokemonIdTeach)
            pokemonIdTeach = pokemonIdTeach + 1
            return
        end
    end
    pokemonIdTeach = 1
    return true
end

function game.iterTable(t, f)
	for k, v in pairs(t) do
		if f(k,v) then
			return true
		end
	end
	return false
end

return game
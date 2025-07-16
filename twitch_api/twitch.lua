-- Provides access to Twitch API to change marathon channel's information
twitch = {
    initialized = true
}

---Updates Twitch title over at FM channel
---@param game string
---@param directory string
---@param runner string
---@param is_tas? boolean
twitch.update_title = function(game, directory, runner, is_tas)
    if not is_tas then
        is_tas = false
    end

    local game_string = game
    if is_tas then
        game_string = game_string .. " (TAS)"
    end

    local title = "FM2025 || " .. game_string .. ", by " .. runner
	os.execute('start  C:/TitleUpdaterConsole.exe "' .. title .. '"' .. ' "' .. directory .. '"')
end

return twitch

-- File for working with the schedule file
local json = require("cjson")
local http = require("socket.http")
local obs = require("obslua")


schedule = {}

schedule._has_schedule = false
schedule._schedule_cache = {}

local columns = {
    game_name = "Game Name",
    setup = "Setup",
    restreamer = "Restreamer",
    run_category = "Run Category",
    run_type = "Run Type",
    runners = "Runner(s)",
    runner_prs = "Runner Pronouns",
    commentators = "Commentators",
    window_size = "Window Size",
    created_by = "Created By",
    directory = "Directory",
    console = "Console"
}

local function sec_to_m(seconds)
    return seconds / 60.0
end

local function parse_ratio(ratio)
    local result_ratio = {
        width = 0,
        height = 0,
        is_ratio = false
    }

    if not ratio then
        return nil
    end

    if not string.find(ratio, "^%d") then
        return nil
    end

    local has_x = false
    local has_colon = false
    local width = ""
    local height = ""
    for char in string.gmatch(ratio, ".") do
        local skip = false
        if char == "x" or char == "X" then
            has_x = true
            skip = true
        end

        if char == ":" then
            has_colon = true
            result_ratio.is_ratio = true
            skip = true
        end

        if not skip then
            if not has_x and not has_colon then
                width = width .. char
            else
                height = height .. char
            end
        end
    end

    result_ratio.width = tonumber(width)
    result_ratio.height = tonumber(height)

    return result_ratio
end


---Parses runners into a table array
---@param runners_string string
---@return table
local function parse_runners(runners_string)
    local result = {}

    if runners_string:match(".") ~= "[" then
        table.insert(result, runners_string)
        return result
    end

    for runner in runners_string:gmatch("%[(.-)%]") do
        table.insert(result, runner)
    end

    return result
end

---Parses runner's pronouns
---@param pronouns_string string
---@return table
local function parse_runners_pronouns(pronouns_string)
    local result = {}

    for pronouns in pronouns_string:gmatch("%((.-)%)") do
        table.insert(result, pronouns)
    end

    return result
end


---Parses commentators into a table array
---@param commentators_string string
---@return table
local function parse_commentators(commentators_string)
    local result = {}

    if commentators_string == "null" then
        return result
    end

    commentators_string = commentators_string:gsub("%+", "")
    commentators_string = commentators_string:gsub("%((.-)%)", "")
    commentators_string = commentators_string:gsub("%s+", " ")

    for commentator in commentators_string:gmatch("%S+") do
        table.insert(result, commentator)
    end

    return result
end

---Parses commentators into their pronouns array
---@param commentators_string string
---@return table
local function parse_commentators_pronouns(commentators_string)
    local result = {}

    if commentators_string == "null" then
        return result
    end

    for pronouns in commentators_string:gmatch("%((.-)%)") do
        table.insert(result, pronouns)
    end

    return result
end

local function parse_estimate(estimate)
    local result = ""
    estimate = string.sub(estimate, 3)
    local encountered_hours = false
    local encountered_minutes = false
    local encountered_seconds = false

    -- This is awful but I honestly can't be bothered with pattern matching
    for char in string.gmatch(estimate, ".") do
        if char == "H" then
            result = result .. ":"
            encountered_hours = true
        elseif char == "M" then
            if not encountered_hours then
                result = "0:" .. result
                encountered_hours = true
            end
            result = result .. ":"
            encountered_minutes = true
        elseif char == "S" then
            if not encountered_minutes then
                result = "0:00:" .. result
            end
            encountered_seconds = true
            break
        else
            result = result .. char
        end
    end

    if encountered_hours and not encountered_minutes and not encountered_seconds then
        result = result .. "00:00"
    elseif encountered_minutes and not encountered_seconds then
        result = result .. "00"
    end

    return result
end

local function get_horaro_column(data, column)
    return data[schedule.column_map[column]]
end

---Gets the schedule from the file
---@param force_reload? boolean
schedule.get_schedule = function(force_reload)
    if not schedule._has_schedule or force_reload then
        local marathon_info = assert(io.open(script_path() .. "/fm_schedule.json", "r"))
        local json_data = marathon_info:read("*a")
        local decoded_info = json.decode(json_data)
        schedule._schedule_cache = decoded_info.schedule
        schedule._has_schedule = true

        schedule.column_map = {}
        for i = 1, #(schedule._schedule_cache.columns) do
            schedule.column_map[schedule._schedule_cache.columns[i]] = i
        end
    end

    return schedule._schedule_cache
end

--- Get the run information string in the form of `[Game] [Platform(if present)] [Runners] [Category] [Estimate]`
---
--- For setup blocks returns information string in the form of `[Setup block name]`
---
--- Function is 0 indexed and converts to lua's array indexing internally
---
---@param run_index integer
---@return string
schedule.get_run_info = function(run_index)
    local schedule = schedule.get_schedule()
    local run = schedule.oengus.schedule.items[run_index + 1]
    local horaro_run = schedule.items[run_index + 1]

    local run_string = tostring(run_index + 1) .. ". "

    if run.data[0] == nil and run.data[4] == nil then
        run_string = run_string .. run.data[1]
        return run_string
    end

    run_string = run_string .. run.data[1]
    run_string = run_string .. " "
    if run.data[4] ~= nil then
        run_string = run_string .. run.data[4]
        run_string = run_string .. " "
    end


    if run.data[0] ~= nil then
        local runners = {}
        local runners_amt = 0
        for runner in string.gmatch(run.data[0], "([^, ]+)") do
            runners[runners_amt] = runner
            runners_amt = runners_amt + 1
        end
        run_string = run_string .. tostring(runners_amt) .. " player(s) "
        for i = 0, runners_amt do
            local runner = runners[i]
            run_string = run_string .. runner
            run_string = run_string .. " "
        end
    end

    run_string = run_string .. run.data[2]
    run_string = run_string .. " "

    local estimate = parse_estimate(run.length)
    run_string = run_string .. estimate

    return run_string
end

schedule.get_run_data = function(run_idx, is_multiplayer)
    local data = {}

    local run = schedule.get_schedule().oengus.schedule.items[run_idx + 1]
    local horaro_run = schedule.get_schedule().items[run_idx + 1].data

    data.game_name = run.data[2]:match("%[(.-)%]") or run.data[2]
    data.estimate = parse_estimate(run.length)
    data.category = run.data[3]
    data.ratio = parse_ratio(get_horaro_column(horaro_run, columns.window_size))
    data.created_by = get_horaro_column(horaro_run, columns.created_by)
    data.twitch_directory = get_horaro_column(horaro_run, columns.directory)
    data.runner_string = ""
    data.is_tas = get_horaro_column(horaro_run, columns.run_type) == "TAS"

    local runner_names = parse_runners(get_horaro_column(horaro_run, columns.runners))
    local runner_pronouns = parse_runners_pronouns(get_horaro_column(horaro_run, columns.runner_prs))
    data.runners = {}
    local runner_amt = #(runner_names)
    for i = 1, runner_amt do
        local pronouns = runner_pronouns[i]
        if pronouns == "???" then
            pronouns = "ASK FOR PRONOUNS"
        end

        table.insert(data.runners, {
            name = runner_names[i],
            pronouns = pronouns
        })
    end

    if is_multiplayer then
        data.participants = {}
        local participants_string = schedule.get_schedule().items[run_idx + 1].participants
        local participant_names = parse_commentators(participants_string)
        local participant_pronouns = parse_commentators_pronouns(participants_string)
        local participants_amt = #(participant_names)
        for i = 1, participants_amt do
            local pronouns = participant_pronouns[i]
            if pronouns == "???" then
                pronouns = "ASK FOR PRONOUNS"
            end

            table.insert(data.participants, {
                name = participant_names[i],
                pronouns = pronouns
            })
        end
    end

    local runner_array = {}
    for i = 1, runner_amt do
        table.insert(runner_array, runner_names[i])
    end

    data.runner_string = table.concat(runner_array, ", ")

    data.commentators = {}
    local comm_names = parse_commentators(get_horaro_column(horaro_run, columns.commentators))
    local comm_pronouns = parse_commentators_pronouns(get_horaro_column(horaro_run, columns.commentators))
    local comm_amt = #(comm_names)
    for i = 1, comm_amt do
        local pronouns = comm_pronouns[i]
        if pronouns == "???" then
            pronouns = "ASK FOR PRONOUNS"
        end

        table.insert(data.commentators, {
            name = comm_names[i],
            pronouns = pronouns
        })
    end

    return data
end

schedule.get_runs = function()
    local runs = {}
    local runs_amount = #(schedule.get_schedule().oengus.schedule.items)
    for i = 1, runs_amount do
        local run_info = schedule.get_run_info(i - 1)
        table.insert(runs, run_info)
    end

    return runs
end

schedule.get_multiplayer_runs = function()
    local runs = {}
    local runs_amount = #(schedule.get_schedule().items)
    for i = 1, runs_amount do
        local run_info = schedule.get_schedule().items[i]
        if run_info.is_multiplayer then
            local run_table = {
                name = schedule.get_run_info(i - 1),
                index = i
            }
            table.insert(runs, run_table)
        end
    end

    return runs
end

return schedule

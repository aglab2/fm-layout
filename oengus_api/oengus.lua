-- Provides access to oengus API to receive data on the state of the marathon
local json = require("cjson")
local http = require("socket.http")
local obs = require("obslua")


oengus = {}

oengus._last_schedule_call = 0.0
oengus._has_schedule = false
oengus._schedule_cache = {}

local function sec_to_m(seconds)
    return seconds / 60.0
end

local function parse_estimate(estimate)
    local result = ""
    estimate = string.sub(estimate, 3)
    local encountered_hours = false
    local encountered_minutes = false

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
            break
        else
            result = result .. char
        end
    end

    return result
end

---Gets the schedule from the file
oengus.get_schedule = function()
    if not oengus._has_schedule then
        local marathon_info = assert(io.open(script_path() .. "/fm_2023_schedule.json", "r"))
        local json_data = marathon_info:read("*a")
        local decoded_info = json.decode(json_data)
        oengus._schedule_cache = decoded_info.schedule
        oengus._has_schedule = true
    end

    return oengus._schedule_cache
end

--- Get the run information string in the form of `[Game] [Platform(if present)] [Runners] [Category] [Estimate]`
---
--- For setup blocks returns information string in the form of `[Setup block name]`
---
--- Function is 0 indexed and converts to lua's array indexing internally
---
---@param run_index integer
---@return string
oengus.get_run_info = function(run_index)
    local schedule = oengus.get_schedule()
    local run = schedule.oengus.lines[run_index + 1]

    local run_string = ""

    if run.setupBlock then
        run_string = run.setupBlockText
        return run_string
    end

    run_string = run.gameName
    run_string = run_string .. " "
    if run.console ~= "null" then
        run_string = run_string .. run.console
        run_string = run_string .. " "
    end

    local runners_amt = #(run.runners)
    for i = 1, runners_amt do
        local runner = run.runners[i]
        run_string = run_string .. runner.username
        run_string = run_string .. " "
    end

    run_string = run_string .. run.categoryName
    run_string = run_string .. " "

    local estimate = parse_estimate(run.estimate)
    run_string = run_string .. estimate

    return run_string
end

return oengus

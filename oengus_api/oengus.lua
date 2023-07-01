-- Provides access to oengus API to receive data on the state of the marathon
local json = require("cjson")
local http = require("socket.http")
local obs = require("obslua")

-- Oengus caches the scedule API call for 5 minutes
local SCHEDULE_CACHE_TIME = 5


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

---Gets the schedule from the file or directly from Oegnus if that is needed
---
---By default accesses Oengus directly
---
---@param pull_from_oengus? boolean
oengus.get_schedule = function(pull_from_oengus)
    if pull_from_oengus == nil then
        pull_from_oengus = true
    end

    if not pull_from_oengus then
        if not oengus._has_schedule then
            local marathon_info = assert(io.open("fm_2023_schedule.json", "r"))
            local json_data = marathon_info:read("*a")
            local decoded_info = json.decode(json_data)
            oengus._schedule_cache = decoded_info.schedule
        end

        return oengus._schedule_cache
    end

    local time_since_last_call = sec_to_m(os.clock() - oengus._last_schedule_call)
    if time_since_last_call >= SCHEDULE_CACHE_TIME or not oengus._has_schedule then
        oengus._has_schedule = true
        oengus._last_schedule_call = os.clock()

        local body, code, headers, status = http.request("https://oengus.io/api/v1/marathons/fm2023/schedule")
        oengus._schedule_cache = json.decode(body)
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
    local run = schedule.lines[run_index + 1]

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

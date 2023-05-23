-- Controller source to get time from timer source and split it if needed

local obs = obslua
local bit = require("bit")
local table_to_string = require("table_to_string")

timer_controller = {}
timer_controller.id = "fm_timer_controller"
timer_controller.output_flags = obs.OBS_SOURCE_CAP_DISABLED

timer_controller.get_name = function()
    return "FM multiplayer layout timer controller"
end

timer_controller.create = function(settings, source)
    local data = {}
    data.uuid = obs.obs_source_get_uuid(source)

    local ctx = util.create_item_ctx(timer_controller.get_id(data))
    ctx.id = timer_controller.get_id(data)

    obs.script_log(obs.LOG_INFO, "Created timer controller " .. obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    return data
end

timer_controller.get_defaults = function(settings)
    obs.obs_data_set_default_int(settings, util.setting_names.runner_amt, 1)
end

timer_controller.get_id = function(data)
    return timer_controller.id .. data.uuid
end

-- Binds the function call to the object and one additional parameter
local function bind(t, k, p)
    return function(...) return t[k](t, p, ...) end
end

timer_controller.timer_start_finish = function(self, data, props, prop)
    local ctx = util.get_item_ctx(timer_controller.get_id(data))
    local state = ctx.state
    if state == nil then
        state = util.timer_states.stopped
    end
    local timer = obs.obs_get_source_by_uuid(obs.obs_data_get_string(ctx.props_settings, "timer_source"))
    if state == util.timer_states.stopped then
        ctx.state = util.timer_states.running
        obs.obs_source_media_play_pause(timer, false)
        obs.obs_property_set_description(prop, util.timer_controller_names.timer_finish)
    elseif state == util.timer_states.running then
        ctx.state = util.timer_states.finished
        obs.obs_source_media_next(timer)
        obs.obs_property_set_description(prop, util.timer_controller_names.timer_reset)
    elseif state == util.timer_states.finished then
        ctx.state = util.timer_states.stopped
        obs.obs_source_media_stop(timer)
        obs.obs_property_set_description(prop, util.timer_controller_names.timer_start)
    end
    return true
end

timer_controller.timer_pause_continue = function(self, data, props, prop)
    return true
end

timer_controller.get_properties = function(data)
    local ctx = util.get_item_ctx(timer_controller.get_id(data))

    ctx.props_def = obs.obs_properties_create()

    local runner_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runner_amt)
    if runner_amt == 2 then
        obs.obs_properties_add_button(ctx.props_def, "left_runner", util.timer_controller_names.left_runner)
        obs.obs_properties_add_button(ctx.props_def, "right_runner", util.timer_controller_names.right_runner)
    elseif runner_amt == 3 then
        obs.obs_properties_add_button(ctx.props_def, "top_left_runner", util.timer_controller_names.top_left_runner)
        obs.obs_properties_add_button(ctx.props_def, "top_right_runner", util.timer_controller_names.top_right_runner)
        obs.obs_properties_add_button(ctx.props_def, "bottom_left_runner",
            util.timer_controller_names.bottom_left_runner)
    elseif runner_amt == 4 then
        obs.obs_properties_add_button(ctx.props_def, "top_left_runner", util.timer_controller_names.top_left_runner)
        obs.obs_properties_add_button(ctx.props_def, "top_right_runner", util.timer_controller_names.top_right_runner)
        obs.obs_properties_add_button(ctx.props_def, "bottom_left_runner",
            util.timer_controller_names.bottom_left_runner)
        obs.obs_properties_add_button(ctx.props_def, "bottom_right_runner",
            util.timer_controller_names.bottom_right_runner)
    end

    obs.obs_properties_add_button(ctx.props_def, "start_finish_timer", util.timer_controller_names.timer_start,
        bind(timer_controller, "timer_start_finish", data))
    obs.obs_properties_add_button(ctx.props_def, "pause_continue_timer", util.timer_controller_names.timer_pause,
        bind(timer_controller, "timer_pause_continue", data))

    return ctx.props_def
end

timer_controller.get_width = function(data)
    return 0
end

timer_controller.get_height = function(data)
    return 0
end


obs.obs_register_source(timer_controller)

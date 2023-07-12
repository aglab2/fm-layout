require("util")

local obs = obslua
local bit = require("bit")


layout_fish_out_water_source_def = {}
layout_fish_out_water_source_def.scene_name = "FM fish out of water layout"
layout_fish_out_water_source_def.id = "fm_2023_fish_out_water"
layout_fish_out_water_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_fish_out_water_source_def.get_name = function()
    return "FM fish out of water layout"
end

layout_fish_out_water_source_def.create = function(settings, source)
    local data = {}
    data.background = obs.gs_image_file()
    data.wolfie_special = obs.gs_image_file()

    local ctx = util.create_item_ctx(layout_fish_out_water_source_def.id)
    ctx.scene = layout_fish_out_water_source_def.scene_name

    ctx.props_settings = settings

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    local template_path = script_path() .. util.layout_templates_path
    local img_path = script_path() .. util.layout_builder_path
    util.image_source_load(data.background, template_path .. "fishout_of_water.png")
    util.image_source_load(data.wolfie_special, img_path .. "fish_out_of_water_swap.png")

    return data
end

layout_fish_out_water_source_def.get_defaults = function(settings)
end

local function update_twitch(props, p)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx)

    twitch.update_title(run_data.game_name, run_data.twitch_directory, run_data.runner_string, run_data.is_tas)
end

layout_fish_out_water_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    ctx.scene = layout_fish_out_water_source_def.scene_name
    ctx.props_def = obs.obs_properties_create()

    local runs_list = obs.obs_properties_add_list(ctx.props_def, util.setting_names.runs_list,
        util.dashboard_names.runs_list, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)

    local runs = schedule.get_runs()
    local runs_amount = #(runs)
    for i = 1, runs_amount do
        obs.obs_property_list_add_int(runs_list, runs[i], i - 1)
    end

    obs.obs_properties_add_button(ctx.props_def, util.setting_names.update_twitch,
        util.dashboard_names.update_twitch, update_twitch)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_fish_out_water_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    ctx.props_settings = settings
end

layout_fish_out_water_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.wolfie_special)
    obs.obs_leave_graphics()
end

layout_fish_out_water_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    -- TODO: Fish out of water specific images
    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false);
        obs.obs_source_draw(data.wolfie_special.texture, 55, 570, 578, 452, false);
    end

    obs.gs_blend_state_pop()
end

layout_fish_out_water_source_def.get_width = function(data)
    return 1920
end

layout_fish_out_water_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_fish_out_water_source_def)

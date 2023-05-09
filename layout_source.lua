require("util")

local obs = obslua
local bit = require("bit")

layout_1p_no_cam_4x3_source_def = {}
layout_1p_no_cam_4x3_source_def.id = "fm_2023_1_person_no_cam_4x3"
layout_1p_no_cam_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_1p_no_cam_4x3_source_def.get_name = function()
    return "FM 4x4 1 person no cam layout"
end

layout_1p_no_cam_4x3_source_def.create = function(settings, source)
    local data = {}
    util.create_layout_ctx(layout_1p_no_cam_4x3_source_def.id)
    data.background = obs.gs_image_file()
    obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))
    util.image_source_load(data.background, script_path() .. "layout-builder-pictures/background.png")

    return data
end

layout_1p_no_cam_4x3_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_source, util.source_names.runner_1)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr_source, util.source_names.runner_1_pronouns)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_name, "Runner 1")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr, "They/Them")
end

layout_1p_no_cam_4x3_source_def.get_properties = function(data)
    local ctx = util.get_layout_ctx(layout_1p_no_cam_4x3_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r1_name, util.dashboard_names.r1_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r1_pr, util.dashboard_names.r1_pr,
        obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_1p_no_cam_4x3_source_def.update = function(data, settings)
    local ctx = util.get_layout_ctx(layout_1p_no_cam_4x3_source_def.id)
    ctx.props_settings = settings

    util.set_obs_text_source_text(obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_source),
        obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_name))
    util.set_obs_text_source_text(obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_pr_source),
        obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_pr))
end

layout_1p_no_cam_4x3_source_def.destroy = function(data)
    obs.obs_enter_graphics();
    obs.gs_image_file_free(data.layout_template);
    obs.obs_leave_graphics();
end

layout_1p_no_cam_4x3_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false);
    end

    obs.gs_matrix_pop()

    obs.gs_blend_state_pop()
end

layout_1p_no_cam_4x3_source_def.get_width = function(data)
    return 1920
end

layout_1p_no_cam_4x3_source_def.get_height = function(data)
    return 1080
end

layout_3p_4x3_source_def = {}
layout_3p_4x3_source_def.id = "fm_2023_3_person_4x3"
layout_3p_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_3p_4x3_source_def.get_name = function()
    return "FM 4x3 3 person layout"
end

layout_3p_4x3_source_def.create = function(settings, source)
    local data = {}
    data.layout_template = obs.gs_image_file()
    util.create_layout_ctx(layout_3p_4x3_source_def.id)
    obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))
    util.image_source_load(data.layout_template, script_path() .. "layout-templates/3_person_4x3.png")

    return data
end

layout_3p_4x3_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_source, util.source_names.runner_1)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr_source, util.source_names.runner_1_pronouns)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_name, "Runner 1")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_name, "Runner 2")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.r3_name, "Runner 3")
    obs.obs_data_set_default_string(settings, util.setting_names.r3_pr, "They/Them")
end

layout_3p_4x3_source_def.get_properties = function(data)
    local ctx = util.get_layout_ctx(layout_3p_4x3_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r1_name, util.dashboard_names.r1_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r1_pr, util.dashboard_names.r1_pr,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r2_name, util.dashboard_names.r2_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r2_pr, util.dashboard_names.r2_pr,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r3_name, util.dashboard_names.r3_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r3_pr, util.dashboard_names.r3_pr,
        obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_3p_4x3_source_def.update = function(data, settings)
    local ctx = util.get_layout_ctx(layout_3p_4x3_source_def.id)
    ctx.props_settings = settings

    util.set_obs_text_source_text(obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_source),
        obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_name))
    util.set_obs_text_source_text(obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_pr_source),
        obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_pr))
end

layout_3p_4x3_source_def.destroy = function(data)
    obs.obs_enter_graphics();
    obs.gs_image_file_free(data.layout_template);
    obs.obs_leave_graphics();
end

layout_3p_4x3_source_def.video_render = function(data, effect)
    if not data.layout_template.texture then
        return;
    end

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.layout_template.texture, 0, 0, 1920, 1080, false);
    end

    obs.gs_matrix_pop()

    obs.gs_blend_state_pop()
end

layout_3p_4x3_source_def.get_width = function(data)
    return 1920
end

layout_3p_4x3_source_def.get_height = function(data)
    return 1080
end


obs.obs_register_source(layout_1p_no_cam_4x3_source_def)
obs.obs_register_source(layout_3p_4x3_source_def)

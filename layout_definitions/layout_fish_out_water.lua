require("util")

local obs = obslua
local bit = require("bit")


layout_fish_out_water_source_def = {}
layout_fish_out_water_source_def.scene_name = "FM fish out of water layout"
layout_fish_out_water_source_def.id = "fm_2023_fish_out_water"
layout_fish_out_water_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_fish_out_water_source_def.hide_finish_times = function(ctx)
    util.set_item_visible(ctx, util.setting_names.r1_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r2_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r3_time_source, false)
end

layout_fish_out_water_source_def.get_name = function()
    return "FM fish out of water layout"
end

layout_fish_out_water_source_def.create = function(settings, source)
    local data = {}
    -- TODO: Fish out of water specific images
    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()

    local ctx = util.create_item_ctx(layout_fish_out_water_source_def.id)
    ctx.scene = layout_fish_out_water_source_def.scene_name

    ctx.props_settings = settings

    obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    -- TODO: Fish out of water specific images
    local template_path = script_path() .. util.layout_templates_path
    local img_path = script_path() .. util.layout_builder_path
    util.image_source_load(data.background, template_path .. "3_person_4x3.png")
    util.image_source_load(data.comm_name_box, img_path .. "3p_comm_name_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")

    return data
end

layout_fish_out_water_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, util.setting_names.game_name, "i wanna be the guy")
    obs.obs_data_set_default_string(settings, util.setting_names.created_by, "Kayin")
    obs.obs_data_set_default_string(settings, util.setting_names.category, "full send%")
    obs.obs_data_set_default_string(settings, util.setting_names.estimate, "1:30:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_source, util.source_names.runner_1)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr_source, util.source_names.runner_1_pronouns)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_name, "Runner 1")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_name, "Runner 2")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.r3_name, "Runner 3")
    obs.obs_data_set_default_string(settings, util.setting_names.r3_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_time, "0:00:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_time, "0:00:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r3_time, "0:00:00")
end

layout_fish_out_water_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    ctx.scene = layout_fish_out_water_source_def.scene_name
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.game_name, util.dashboard_names.game_name,
        obs.OBS_TEXT_MULTILINE)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.created_by, util.dashboard_names.created_by,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.category, util.dashboard_names.category,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.estimate, util.dashboard_names.estimate,
        obs.OBS_TEXT_DEFAULT)
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

layout_fish_out_water_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    ctx.props_settings = settings

    util.set_obs_text(ctx, util.setting_names.game_name_source, util.setting_names.game_name)
    util.set_obs_text(ctx, util.setting_names.created_by_source, util.setting_names.created_by, "Created by ")
    util.set_obs_text(ctx, util.setting_names.category_source, util.setting_names.category)
    util.set_obs_text(ctx, util.setting_names.estimate_source, util.setting_names.estimate)
    util.set_obs_text(ctx, util.setting_names.r1_source, util.setting_names.r1_name)
    util.set_obs_text(ctx, util.setting_names.r1_pr_source, util.setting_names.r1_pr)
    util.set_obs_text(ctx, util.setting_names.r2_source, util.setting_names.r2_name)
    util.set_obs_text(ctx, util.setting_names.r2_pr_source, util.setting_names.r2_pr)
    util.set_obs_text(ctx, util.setting_names.r3_source, util.setting_names.r3_name)
    util.set_obs_text(ctx, util.setting_names.r3_pr_source, util.setting_names.r3_pr)
    util.set_obs_text(ctx, util.setting_names.r1_time_source, util.setting_names.r1_time)
    util.set_obs_text(ctx, util.setting_names.r2_time_source, util.setting_names.r2_time)
    util.set_obs_text(ctx, util.setting_names.r3_time_source, util.setting_names.r3_time)
end

layout_fish_out_water_source_def.destroy = function(data)
    -- TODO: Fish out of water specific images
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.comm_name_box)
    obs.gs_image_file_free(data.comm_pr_frame)
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
    end

    obs.gs_matrix_pop()

    obs.gs_blend_state_pop()
end

layout_fish_out_water_source_def.get_width = function(data)
    return 1920
end

layout_fish_out_water_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_fish_out_water_source_def)

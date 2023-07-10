require("util")

local obs = obslua
local bit = require("bit")

local show_commentators = function(ctx)
    util.set_prop_visible(ctx, util.setting_names.c2_name, true)
    util.set_prop_visible(ctx, util.setting_names.c2_pr, true)
end

layout_relay_race_source_def = {}
layout_relay_race_source_def.scene_name = "FM relay race layout"
layout_relay_race_source_def.id = "fm_2023_relay_race"
layout_relay_race_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_relay_race_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
end

layout_relay_race_source_def.get_name = function()
    return "FM relay race layout"
end

layout_relay_race_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_relay_race_source_def.id)
    ctx.scene = layout_relay_race_source_def.scene_name

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.kid = obs.gs_image_file()
    data.red_team_box = obs.gs_image_file()
    data.yellow_team_box = obs.gs_image_file()

    local img_path = script_path() .. util.layout_builder_path
    local template_path = script_path() .. util.layout_templates_path

    util.image_source_load(data.background, template_path .. "relay_race.png")
    util.image_source_load(data.comm_name_box, img_path .. "2p_comm_name_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.kid, img_path .. "relay_race_kid_run_static.png")
    util.image_source_load(data.red_team_box, img_path .. "relay_race_red_team_box.png")
    util.image_source_load(data.yellow_team_box, img_path .. "relay_race_yellow_team_box.png")

    return data
end

layout_relay_race_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, util.setting_names.category, "full send%")
    obs.obs_data_set_default_string(settings, util.setting_names.estimate, "1:30:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_source, util.source_names.runner_1)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr_source, util.source_names.runner_1_pronouns)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_name, "Runner 1")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_name, "Runner 2")
    obs.obs_data_set_default_int(settings, util.setting_names.comm_amt, 1)
    obs.obs_data_set_default_string(settings, util.setting_names.c1_name, "Comm 1")
    obs.obs_data_set_default_string(settings, util.setting_names.c1_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.c2_name, "Comm 2")
    obs.obs_data_set_default_string(settings, util.setting_names.c2_pr, "They/Them")
end

local slider_modified = function(props, p, settings)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    show_commentators(ctx)
    if comm_amt <= 1 then
        util.set_prop_visible(ctx, util.setting_names.c2_name, false)
        util.set_prop_visible(ctx, util.setting_names.c2_pr, false)
    end

    return true
end

layout_relay_race_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.category, util.dashboard_names.category,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.estimate, util.dashboard_names.estimate,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r1_name, util.dashboard_names.r1_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.r2_name, util.dashboard_names.r2_name,
        obs.OBS_TEXT_DEFAULT)

    local slider = obs.obs_properties_add_int_slider(ctx.props_def, util.setting_names.comm_amt,
        util.dashboard_names.comm_amt, 1, 2, 1)
    obs.obs_property_set_modified_callback(slider, slider_modified)

    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c1_name, util.dashboard_names.c1_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c1_pr, util.dashboard_names.c1_pr,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c2_name, util.dashboard_names.c2_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c2_pr, util.dashboard_names.c2_pr,
        obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_relay_race_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    ctx.props_settings = settings

    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    util.set_item_visible(ctx, util.setting_names.c2_source, true)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, true)
    if comm_amt <= 1 then
        util.set_item_visible(ctx, util.setting_names.c2_source, false)
        util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
    end

    -- TODO: Runner names position moving
    -- TODO: Team names

    util.set_obs_text(ctx, util.setting_names.category_source, util.setting_names.category)
    util.set_obs_text(ctx, util.setting_names.estimate_source, util.setting_names.estimate)
    util.set_obs_text(ctx, util.setting_names.r1_source, util.setting_names.r1_name)
    util.set_obs_text(ctx, util.setting_names.r2_source, util.setting_names.r2_name)
    util.set_obs_text(ctx, util.setting_names.c1_source, util.setting_names.c1_name)
    util.set_obs_text(ctx, util.setting_names.c2_source, util.setting_names.c2_name)
    util.set_obs_text(ctx, util.setting_names.c1_pr_source, util.setting_names.c1_pr)
    util.set_obs_text(ctx, util.setting_names.c2_pr_source, util.setting_names.c2_pr)
end

layout_relay_race_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.comm_name_box)
    obs.gs_image_file_free(data.comm_pr_frame)
    obs.gs_image_file_free(data.kid)
    obs.gs_image_file_free(data.red_team_box)
    obs.gs_image_file_free(data.yellow_team_box)
    obs.obs_leave_graphics()
end

layout_relay_race_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        -- Background
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)

        obs.obs_source_draw(data.yellow_team_box.texture, 79, 23, 800, 600, false)
        obs.obs_source_draw(data.red_team_box.texture, 1000, 23, 800, 600, false)

        -- TODO: Moving kids rendering

        -- Yellow team kid
        obs.obs_source_draw(data.kid.texture, 788, 705, 67, 56, false)

        -- Red team kid
        obs.obs_source_draw(data.kid.texture, 788, 846, 67, 56, false)

        local x_off = 245
        -- Draw commentator boxes
        for i = 1, comm_amt do
            obs.obs_source_draw(data.comm_name_box.texture, 79 + x_off * (i - 1), 908,
                228, 35, false)
            obs.obs_source_draw(data.comm_pr_frame.texture, 223 + x_off * (i - 1), 913,
                79, 26, false)
        end
    end

    obs.gs_matrix_pop()
    obs.gs_blend_state_pop()
end

layout_relay_race_source_def.get_width = function(data)
    return 1920
end

layout_relay_race_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_relay_race_source_def)

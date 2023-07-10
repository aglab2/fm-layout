require("util")

local obs = obslua
local bit = require("bit")

local show_commentators = function(ctx)
    util.set_prop_visible(ctx, util.setting_names.c2_name, true)
    util.set_prop_visible(ctx, util.setting_names.c2_pr, true)
    util.set_prop_visible(ctx, util.setting_names.c3_name, true)
    util.set_prop_visible(ctx, util.setting_names.c3_pr, true)
    util.set_prop_visible(ctx, util.setting_names.c4_name, true)
    util.set_prop_visible(ctx, util.setting_names.c4_pr, true)
end

layout_2p_monkey_ball_source_def = {}
layout_2p_monkey_ball_source_def.scene_name = "FM Monkey Ball layout"
layout_2p_monkey_ball_source_def.id = "fm_2023_monkey_ball_tournament"
layout_2p_monkey_ball_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_2p_monkey_ball_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c4_source, false)
    util.set_item_visible(ctx, util.setting_names.c4_pr_source, false)
end

layout_2p_monkey_ball_source_def.get_name = function()
    return "FM 4x3 monkey ball tournament layout"
end

layout_2p_monkey_ball_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_2p_monkey_ball_source_def.id)
    ctx.scene = layout_2p_monkey_ball_source_def.scene_name

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.game_frame = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.empty_score = obs.gs_image_file()
    data.score = obs.gs_image_file()

    local img_path = script_path() .. util.layout_builder_path
    local template_path = script_path() .. util.layout_templates_path
    util.image_source_load(data.background, template_path .. "2_person_tournament.png")
    util.image_source_load(data.comm_name_box, img_path .. "2p_comm_name_box.png")
    util.image_source_load(data.game_frame, img_path .. "2p_tournament_game_frame.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.empty_score, img_path .. "monkey_ball_empty_score.png")
    util.image_source_load(data.score, img_path .. "monkey_ball_score.png")

    return data
end

layout_2p_monkey_ball_source_def.get_defaults = function(settings)
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
    obs.obs_data_set_default_int(settings, util.setting_names.comm_amt, 1)
    obs.obs_data_set_default_string(settings, util.setting_names.c1_name, "Comm 1")
    obs.obs_data_set_default_string(settings, util.setting_names.c1_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.c2_name, "Comm 2")
    obs.obs_data_set_default_string(settings, util.setting_names.c2_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.c3_name, "Comm 3")
    obs.obs_data_set_default_string(settings, util.setting_names.c3_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.c4_name, "Comm 4")
    obs.obs_data_set_default_string(settings, util.setting_names.c4_pr, "They/Them")
end

local slider_modified = function(props, p, settings)
    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    show_commentators(ctx)
    if comm_amt <= 3 then
        util.set_prop_visible(ctx, util.setting_names.c4_name, false)
        util.set_prop_visible(ctx, util.setting_names.c4_pr, false)
    end
    if comm_amt <= 2 then
        util.set_prop_visible(ctx, util.setting_names.c3_name, false)
        util.set_prop_visible(ctx, util.setting_names.c3_pr, false)
    end
    if comm_amt <= 1 then
        util.set_prop_visible(ctx, util.setting_names.c2_name, false)
        util.set_prop_visible(ctx, util.setting_names.c2_pr, false)
    end

    return true
end

layout_2p_monkey_ball_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.game_name, util.dashboard_names.game_name,
        obs.OBS_TEXT_DEFAULT)
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

    local slider = obs.obs_properties_add_int_slider(ctx.props_def, util.setting_names.comm_amt,
        util.dashboard_names.comm_amt, 1, 4, 1)
    obs.obs_property_set_modified_callback(slider, slider_modified)

    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c1_name, util.dashboard_names.c1_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c1_pr, util.dashboard_names.c1_pr,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c2_name, util.dashboard_names.c2_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c2_pr, util.dashboard_names.c2_pr,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c3_name, util.dashboard_names.c3_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c3_pr, util.dashboard_names.c3_pr,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c4_name, util.dashboard_names.c4_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.c4_pr, util.dashboard_names.c4_pr,
        obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_2p_monkey_ball_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    ctx.props_settings = settings

    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    util.set_item_visible(ctx, util.setting_names.c2_source, true)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, true)
    util.set_item_visible(ctx, util.setting_names.c3_source, true)
    util.set_item_visible(ctx, util.setting_names.c3_pr_source, true)
    util.set_item_visible(ctx, util.setting_names.c4_source, true)
    util.set_item_visible(ctx, util.setting_names.c4_pr_source, true)
    if comm_amt <= 3 then
        util.set_item_visible(ctx, util.setting_names.c4_source, false)
        util.set_item_visible(ctx, util.setting_names.c4_pr_source, false)
    end
    if comm_amt <= 2 then
        util.set_item_visible(ctx, util.setting_names.c3_source, false)
        util.set_item_visible(ctx, util.setting_names.c3_pr_source, false)
    end
    if comm_amt <= 1 then
        util.set_item_visible(ctx, util.setting_names.c2_source, false)
        util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
    end

    util.set_obs_text(ctx, util.setting_names.game_name_source, util.setting_names.game_name)
    util.set_obs_text(ctx, util.setting_names.created_by_source, util.setting_names.created_by, "Created by ")
    util.set_obs_text(ctx, util.setting_names.category_source, util.setting_names.category)
    util.set_obs_text(ctx, util.setting_names.estimate_source, util.setting_names.estimate)
    util.set_obs_text(ctx, util.setting_names.r1_source, util.setting_names.r1_name)
    util.set_obs_text(ctx, util.setting_names.r1_pr_source, util.setting_names.r1_pr)
    util.set_obs_text(ctx, util.setting_names.r2_source, util.setting_names.r2_name)
    util.set_obs_text(ctx, util.setting_names.r2_pr_source, util.setting_names.r2_pr)
    util.set_obs_text(ctx, util.setting_names.c1_source, util.setting_names.c1_name)
    util.set_obs_text(ctx, util.setting_names.c2_source, util.setting_names.c2_name)
    util.set_obs_text(ctx, util.setting_names.c1_pr_source, util.setting_names.c1_pr)
    util.set_obs_text(ctx, util.setting_names.c2_pr_source, util.setting_names.c2_pr)
    util.set_obs_text(ctx, util.setting_names.c3_source, util.setting_names.c3_name)
    util.set_obs_text(ctx, util.setting_names.c4_source, util.setting_names.c4_name)
    util.set_obs_text(ctx, util.setting_names.c3_pr_source, util.setting_names.c3_pr)
    util.set_obs_text(ctx, util.setting_names.c4_pr_source, util.setting_names.c4_pr)
end

layout_2p_monkey_ball_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.comm_name_box)
    obs.gs_image_file_free(data.game_frame)
    obs.gs_image_file_free(data.comm_pr_frame)
    obs.gs_image_file_free(data.empty_score)
    obs.gs_image_file_free(data.score)
    obs.obs_leave_graphics()
end

layout_2p_monkey_ball_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        -- Background
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)

        obs.obs_source_draw(data.game_frame.texture, 74, 23, 832, 625, false)
        obs.obs_source_draw(data.game_frame.texture, 1015, 23, 832, 625, false)

        -- TODO: Add score rendering

        local row_indx = 0
        local box_start_x = 31
        local box_start_y = 915
        local box_width = 236
        local box_height = 37
        local x_off = box_width + 16
        local y_off = box_height + 16
        -- Draw commentator boxes
        for i = 1, comm_amt do
            obs.obs_source_draw(data.comm_name_box.texture, box_start_x + x_off * (i - 1 - row_indx * 2),
                box_start_y + y_off * row_indx, box_width, box_height, false)
            obs.obs_source_draw(data.comm_pr_frame.texture, 183 + x_off * (i - 1 - row_indx * 2), 920 + y_off * row_indx,
                79, 26, false)
            if i % 2 == 0 then
                row_indx = row_indx + 1
            end
        end
    end

    obs.gs_matrix_pop()
    obs.gs_blend_state_pop()
end

layout_2p_monkey_ball_source_def.get_width = function(data)
    return 1920
end

layout_2p_monkey_ball_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_2p_monkey_ball_source_def)

require("util")

local obs = obslua
local bit = require("bit")

layout_1p_w_cam_4x3_source_def = {}
layout_1p_w_cam_4x3_source_def.scene_name = "FM 1 person w/ cam layout 1"
layout_1p_w_cam_4x3_source_def.id = "fm_2023_1_person_w_cam_4x3"
layout_1p_w_cam_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_1p_w_cam_4x3_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c4_source, false)
    util.set_item_visible(ctx, util.setting_names.c4_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
end

layout_1p_w_cam_4x3_source_def.get_name = function()
    return "FM 4x3 1 person with cam layout"
end

layout_1p_w_cam_4x3_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_1p_w_cam_4x3_source_def.id)
    ctx.scene = layout_1p_w_cam_4x3_source_def.scene_name
    ctx.game_width = 1340
    ctx.game_height = 850
    ctx.game_x = 560
    ctx.game_y = 23
    ctx.offset_x = ctx.game_x
    ctx.offset_y = ctx.game_y

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.logo = obs.gs_image_file()
    data.player_frame = obs.gs_image_file()
    data.runner_box = obs.gs_image_file()
    data.game_frame = obs.gs_image_file()
    data.estimate_frame = obs.gs_image_file()
    data.runner_pr_frame = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.comm_box = obs.gs_image_file()
    data.twitch_logo = obs.gs_image_file()
    data.timer_frame = obs.gs_image_file()
    data.fade_box = obs.gs_image_file()

    local img_path = script_path() .. util.layout_builder_path
    util.image_source_load(data.background, img_path .. "background.png")
    util.image_source_load(data.comm_name_box, img_path .. "comm_name_box.png")
    util.image_source_load(data.logo, img_path .. "logo.png")
    util.image_source_load(data.player_frame, img_path .. "player_frame_w_cam.png")
    util.image_source_load(data.runner_box, img_path .. "runner_box.png")
    util.image_source_load(data.game_frame, img_path .. "game_frame_4_3.png")
    util.image_source_load(data.estimate_frame, img_path .. "estimate_frame.png")
    util.image_source_load(data.runner_pr_frame, img_path .. "pronouns_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.comm_box, img_path .. "commentators_box.png")
    util.image_source_load(data.twitch_logo, img_path .. "twitch_logo.png")
    util.image_source_load(data.timer_frame, img_path .. "time_box.png")
    util.image_source_load(data.fade_box, img_path .. "fade_16_9_1p_left.png")

    return data
end

layout_1p_w_cam_4x3_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, util.setting_names.game_name, "i wanna be the guy")
    obs.obs_data_set_default_string(settings, util.setting_names.created_by, "Kayin")
    obs.obs_data_set_default_string(settings, util.setting_names.category, "full send%")
    obs.obs_data_set_default_string(settings, util.setting_names.estimate, "1:30:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_source, util.source_names.runner_1)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr_source, util.source_names.runner_1_pronouns)
    obs.obs_data_set_default_string(settings, util.setting_names.r1_name, "Runner 1")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_pr, "They/Them")
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

layout_1p_w_cam_4x3_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_1p_w_cam_4x3_source_def.id)
    ctx.props_def = obs.obs_properties_create()

    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_width, util.dashboard_names.game_width,
        1, 1920, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_height, util.dashboard_names.game_height,
        1, 1080, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_x, util.dashboard_names.game_x,
        0, 1920, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_y, util.dashboard_names.game_y,
        0, 1080, 1)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_1p_w_cam_4x3_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_1p_w_cam_4x3_source_def.id)
    ctx.props_settings = settings

    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    util.set_item_visible(ctx, util.setting_names.comms, false)
    if comm_amt > 0 then
        util.set_item_visible(ctx, util.setting_names.comms, true)
    end

    util.set_item_visible(ctx, util.setting_names.c1_source, true)
    util.set_item_visible(ctx, util.setting_names.c1_pr_source, true)
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
    if comm_amt <= 0 then
        util.set_item_visible(ctx, util.setting_names.c1_source, false)
        util.set_item_visible(ctx, util.setting_names.c1_pr_source, false)
    end

    ctx.game_width = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_width)
    ctx.game_height = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_height)
    ctx.game_x = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_x)
    ctx.game_y = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_y)
end

layout_1p_w_cam_4x3_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.comm_name_box)
    obs.gs_image_file_free(data.logo)
    obs.gs_image_file_free(data.player_frame)
    obs.gs_image_file_free(data.runner_box)
    obs.gs_image_file_free(data.game_frame)
    obs.gs_image_file_free(data.estimate_frame)
    obs.gs_image_file_free(data.runner_pr_frame)
    obs.gs_image_file_free(data.comm_pr_frame)
    obs.gs_image_file_free(data.comm_box)
    obs.gs_image_file_free(data.twitch_logo)
    obs.gs_image_file_free(data.timer_frame)
    obs.gs_image_file_free(data.fade_box)
    obs.obs_leave_graphics()
end

layout_1p_w_cam_4x3_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_1p_w_cam_4x3_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)
        obs.obs_source_draw(data.fade_box.texture, 0, 81, 546, 995, false)
        obs.obs_source_draw(data.player_frame.texture, 30, 90, 494, 349, false)
        obs.obs_source_draw(data.runner_box.texture, 34, 479, 490, 59, false)

        if comm_amt ~= 0 then
            obs.obs_source_draw(data.comm_box.texture, 39, 603, 478, 33, false)
        end

        -- obs.obs_source_draw(data.twitch_logo.texture, 75, 492, 30, 30, false)

        obs.obs_source_draw(data.logo.texture, 160, 769, 230, 232, false)
        obs.obs_source_draw(data.game_frame.texture, ctx.game_x, ctx.game_y, ctx.game_width, ctx.game_height, false)
        -- Actual estimate frame
        obs.obs_source_draw(data.estimate_frame.texture, 1511, 968, 257, 38, false)
        -- Category frame
        obs.obs_source_draw(data.estimate_frame.texture, 1234, 968, 257, 38, false)
        obs.obs_source_draw(data.runner_pr_frame.texture, 410, 493, 92, 31, false)
        local row_indx = 0
        local x_off = 287 - 35
        local y_off = 697 - 652
        -- Draw commentator boxes
        for i = 1, comm_amt do
            obs.obs_source_draw(data.comm_name_box.texture, 35 + x_off * (i - 1 - row_indx * 2), 648 + y_off * row_indx,
                235, 35, false)
            obs.obs_source_draw(data.comm_pr_frame.texture, 185 + x_off * (i - 1 - row_indx * 2), 652 + y_off * row_indx,
                79, 26, false)
            if i % 2 == 0 then
                row_indx = row_indx + 1
            end
        end
        obs.obs_source_draw(data.timer_frame.texture, 587, 915, 492, 90, false)
    end

    obs.gs_blend_state_pop()
end

layout_1p_w_cam_4x3_source_def.get_width = function(data)
    return 1920
end

layout_1p_w_cam_4x3_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_1p_w_cam_4x3_source_def)

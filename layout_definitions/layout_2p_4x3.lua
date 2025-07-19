require("util")

local obs = obslua
local bit = require("bit")

local show_commentators = function(ctx)
    util.set_prop_visible(ctx, util.setting_names.c2_name, true)
    util.set_prop_visible(ctx, util.setting_names.c2_pr, true)
end

layout_2p_4x3_source_def = {}
layout_2p_4x3_source_def.scene_name = "FM 2 person layout"
layout_2p_4x3_source_def.id = "fm_2023_2_person_4x3"
layout_2p_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_2p_4x3_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
end

layout_2p_4x3_source_def.hide_finish_times = function(ctx)
    util.set_item_visible(ctx, util.setting_names.r1_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r2_time_source, false)
end

layout_2p_4x3_source_def.get_name = function()
    return "FM 4x3 2 person layout"
end

layout_2p_4x3_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_2p_4x3_source_def.id)
    ctx.scene = layout_2p_4x3_source_def.scene_name

    ctx.game_resolutions = {
        {
            offset_x = 76,
            offset_y = 23,
            width = 832,
            height = 625,
            game_x = 76,
            game_y = 23
        },
        {
            offset_x = 1854,
            offset_y = 23,
            width = 832,
            height = 625,
            game_x = 1854,
            game_y = 23
        }
    }

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
    local template_path = script_path() .. util.layout_templates_path
    util.image_source_load(data.background, template_path .. "2_person_background.png")
    util.image_source_load(data.comm_name_box, img_path .. "2p_comm_name_box.png")
    util.image_source_load(data.logo, img_path .. "background_delfruit.png")
    util.image_source_load(data.player_frame, img_path .. "2p_4x3_player_frame.png")
    util.image_source_load(data.runner_box, img_path .. "2p_runner_box.png")
    util.image_source_load(data.game_frame, img_path .. "game_frame_4_3.png")
    util.image_source_load(data.estimate_frame, img_path .. "estimate_frame.png")
    util.image_source_load(data.runner_pr_frame, img_path .. "2p_pronouns_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.comm_box, img_path .. "2p_commentators_box.png")
    util.image_source_load(data.twitch_logo, img_path .. "twitch_logo.png")
    util.image_source_load(data.timer_frame, img_path .. "time_box.png")
    util.image_source_load(data.fade_box, img_path .. "fade_4_3_2p_left.png")

    return data
end

layout_2p_4x3_source_def.get_defaults = function(settings)
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
end

layout_2p_4x3_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_2p_4x3_source_def.id)
    ctx.props_def = obs.obs_properties_create()

    obs.obs_properties_add_text(ctx.props_def, util.setting_names.game_name, util.dashboard_names.game_name,
        obs.OBS_TEXT_DEFAULT)
    for i = 1, 2 do
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_width .. tostring(i),
            util.dashboard_names.game_width .. " " .. tostring(i), 1, 832, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_height .. tostring(i),
            util.dashboard_names.game_height .. " " .. tostring(i), 1, 625, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_x .. tostring(i),
            util.dashboard_names.game_x .. " " .. tostring(i), 0, 1920, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_y .. tostring(i),
            util.dashboard_names.game_y .. " " .. tostring(i), 0, 1080, 1)
    end

    obs.obs_properties_add_path(ctx.props_def, util.setting_names.r1_avatar, util.dashboard_names.r1_avatar,
        obs.OBS_PATH_FILE, "Image files (*.bmp *.tga *.png *.jpeg *.jpg *.jxr *.gif *.psd *.webp)", nil)
    obs.obs_properties_add_path(ctx.props_def, util.setting_names.r2_avatar, util.dashboard_names.r2_avatar,
        obs.OBS_PATH_FILE, "Image files (*.bmp *.tga *.png *.jpeg *.jpg *.jxr *.gif *.psd *.webp)", nil)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_2p_4x3_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_2p_4x3_source_def.id)
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
    if comm_amt <= 1 then
        util.set_item_visible(ctx, util.setting_names.c2_source, false)
        util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
    end
    if comm_amt == 0 then
        util.set_item_visible(ctx, util.setting_names.c1_source, false)
        util.set_item_visible(ctx, util.setting_names.c1_pr_source, false)
    end

    util.set_obs_image_path(ctx, util.setting_names.r1_avatar_source, util.setting_names.r1_avatar)
    util.set_obs_image_path(ctx, util.setting_names.r2_avatar_source, util.setting_names.r2_avatar)

    for i = 1, 1 do
        ctx.game_resolutions[i].game_x = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_x .. tostring(i))
        ctx.game_resolutions[i].game_y = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_y .. tostring(i))
        ctx.game_resolutions[i].width = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_width .. tostring(i))
        ctx.game_resolutions[i].height = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_height .. tostring(i))
    end
end

layout_2p_4x3_source_def.destroy = function(data)
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

layout_2p_4x3_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_2p_4x3_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        -- Background
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)
        obs.obs_source_draw(data.logo.texture, 837, 751, 248, 252, false)
        obs.obs_source_draw(data.fade_box.texture, 0, 80, 597, 996, false)
        obs.obs_source_draw(data.fade_box.texture, 1323, 80, 597, 996, false)

        -- Runner 1
        obs.obs_source_draw(data.player_frame.texture, 75, 666, 453, 320, false)
        obs.obs_source_draw(data.runner_box.texture, 67, 996, 465, 56, false)
        -- obs.obs_source_draw(data.twitch_logo.texture, 107, 1008, 30, 30, false)
        obs.obs_source_draw(data.runner_pr_frame.texture, 427, 1011, 88, 29, false)
        -- Runner 2
        obs.obs_source_draw(data.player_frame.texture, 1402, 666, 453, 320, false)
        obs.obs_source_draw(data.runner_box.texture, 1393, 996, 465, 56, false)
        -- obs.obs_source_draw(data.twitch_logo.texture, 1432, 1008, 30, 30, false)
        obs.obs_source_draw(data.runner_pr_frame.texture, 1750, 1011, 88, 29, false)

        if comm_amt > 0 then
            obs.obs_source_draw(data.comm_box.texture, 693, 971, 534, 33, false)
        end

        for i = 1, 2 do
            obs.obs_source_draw(data.game_frame.texture, ctx.game_resolutions[i].game_x, ctx.game_resolutions[i].game_y,
                ctx.game_resolutions[i].width, ctx.game_resolutions[i].height, false)
        end

        -- Actual estimate frame
        obs.obs_source_draw(data.estimate_frame.texture, 979, 892, 257, 38, false)
        -- Category frame
        obs.obs_source_draw(data.estimate_frame.texture, 702, 892, 257, 38, false)

        local x_off = 283
        -- Draw commentator boxes
        for i = 1, comm_amt do
            obs.obs_source_draw(data.comm_name_box.texture, 693 + x_off * (i - 1), 1017,
                261, 35, false)
            obs.obs_source_draw(data.comm_pr_frame.texture, 868 + x_off * (i - 1), 1021,
                79, 26, false)
        end
        obs.obs_source_draw(data.timer_frame.texture, 715, 669, 492, 90, false)
    end

    obs.gs_blend_state_pop()
end

layout_2p_4x3_source_def.get_width = function(data)
    return 1920
end

layout_2p_4x3_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_2p_4x3_source_def)

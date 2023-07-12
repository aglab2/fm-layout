require("util")

local obs = obslua
local bit = require("bit")
local schedule = require("schedule.schedule")
local twitch = require("twitch_api.twitch")

local show_commentators = function(ctx)
    util.set_prop_visible(ctx, util.setting_names.c2_name, true)
    util.set_prop_visible(ctx, util.setting_names.c2_pr, true)
    util.set_prop_visible(ctx, util.setting_names.c3_name, true)
    util.set_prop_visible(ctx, util.setting_names.c3_pr, true)
    util.set_prop_visible(ctx, util.setting_names.c4_name, true)
    util.set_prop_visible(ctx, util.setting_names.c4_pr, true)
end

layout_1p_no_cam_16x9_source_def = {}
layout_1p_no_cam_16x9_source_def.scene_name = "FM 1 person no cam layout 2"
layout_1p_no_cam_16x9_source_def.id = "fm_2023_1_person_no_cam_16x9"
layout_1p_no_cam_16x9_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_1p_no_cam_16x9_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c4_source, false)
    util.set_item_visible(ctx, util.setting_names.c4_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
end

layout_1p_no_cam_16x9_source_def.get_name = function()
    return "FM 16x9 1 person no cam layout"
end

layout_1p_no_cam_16x9_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    ctx.scene = layout_1p_no_cam_16x9_source_def.scene_name
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
    util.image_source_load(data.player_frame, img_path .. "player_frame_no_cam.png")
    util.image_source_load(data.runner_box, img_path .. "runner_box.png")
    util.image_source_load(data.game_frame, img_path .. "game_frame_16_9.png")
    util.image_source_load(data.estimate_frame, img_path .. "estimate_frame.png")
    util.image_source_load(data.runner_pr_frame, img_path .. "pronouns_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.comm_box, img_path .. "commentators_box.png")
    util.image_source_load(data.twitch_logo, img_path .. "twitch_logo.png")
    util.image_source_load(data.timer_frame, img_path .. "time_box.png")
    util.image_source_load(data.fade_box, img_path .. "fade_16_9_1p_left.png")

    return data
end

layout_1p_no_cam_16x9_source_def.get_defaults = function(settings)
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

local slider_modified = function(props, p, settings)
    local ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
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

local update_run_info = function(props, p)
    local ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx)

    util.set_prop_text(ctx, util.setting_names.game_name, run_data.game_name)
    util.set_prop_text(ctx, util.setting_names.created_by, run_data.created_by)
    util.set_prop_text(ctx, util.setting_names.estimate, run_data.estimate)
    util.set_prop_text(ctx, util.setting_names.category, run_data.category)
    util.set_prop_text(ctx, util.setting_names.r1_name, run_data.runners[1].name)
    util.set_prop_text(ctx, util.setting_names.r1_pr, run_data.runners[1].pronouns)

    local comm_amt = #(run_data.commentators)
    util.set_item_visible(ctx, util.setting_names.comms, true)
    if comm_amt == 0 then
        util.set_item_visible(ctx, util.setting_names.comms, false)
        util.set_prop_text(ctx, util.setting_names.c1_name, "")
        util.set_prop_text(ctx, util.setting_names.c1_pr, "")
        util.set_prop_text(ctx, util.setting_names.c2_name, "")
        util.set_prop_text(ctx, util.setting_names.c2_pr, "")
        util.set_prop_text(ctx, util.setting_names.c3_name, "")
        util.set_prop_text(ctx, util.setting_names.c3_pr, "")
        util.set_prop_text(ctx, util.setting_names.c4_name, "")
        util.set_prop_text(ctx, util.setting_names.c4_pr, "")
    end

    if comm_amt > 4 then
        comm_amt = 4
    end

    for i = 1, comm_amt do
        if i == 1 then
            util.set_prop_text(ctx, util.setting_names.c1_name, run_data.commentators[i].name)
            util.set_prop_text(ctx, util.setting_names.c1_pr, run_data.commentators[i].pronouns)
        end
        if i == 2 then
            util.set_prop_text(ctx, util.setting_names.c2_name, run_data.commentators[i].name)
            util.set_prop_text(ctx, util.setting_names.c2_pr, run_data.commentators[i].pronouns)
        end
        if i == 3 then
            util.set_prop_text(ctx, util.setting_names.c3_name, run_data.commentators[i].name)
            util.set_prop_text(ctx, util.setting_names.c3_pr, run_data.commentators[i].pronouns)
        end
        if i == 4 then
            util.set_prop_text(ctx, util.setting_names.c4_name, run_data.commentators[i].name)
            util.set_prop_text(ctx, util.setting_names.c4_pr, run_data.commentators[i].pronouns)
        end
    end

    obs.obs_data_set_int(ctx.props_settings, util.setting_names.comm_amt, comm_amt)

    local max_size = {
        width = 1346,
        height = 850
    }

    local x, y, width, height = util.fit_screen(run_data.ratio.width, run_data.ratio.height, max_size.width,
        max_size.height)

    ctx.game_x = ctx.offset_x + x
    ctx.game_y = ctx.offset_y + y
    ctx.game_width = width
    ctx.game_height = height

    obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_width, ctx.game_width)
    obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_height, ctx.game_height)
    obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_x, ctx.game_x)
    obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_y, ctx.game_y)

    local avatars_path = script_path() .. util.avatars_path
    local avatar = avatars_path .. run_data.runners[1].name .. ".png"
    if util.file_exists(avatar) then
        obs.obs_data_set_string(ctx.props_settings, util.setting_names.r1_avatar,
            avatars_path .. run_data.runners[1].name .. ".png")
    else
        obs.obs_data_set_string(ctx.props_settings, util.setting_names.r1_avatar,
            avatars_path .. "placeholder.png")
    end

    layout_1p_no_cam_16x9_source_def.update(nil, ctx.props_settings)

    return true
end

local function update_twitch(props, p)
    local ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx)

    twitch.update_title(run_data.game_name, run_data.twitch_directory, run_data.runner_string, run_data.is_tas)
end

layout_1p_no_cam_16x9_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    local runs_list = obs.obs_properties_add_list(ctx.props_def, util.setting_names.runs_list,
        util.dashboard_names.runs_list, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)

    local runs = schedule.get_runs()
    local runs_amount = #(runs)
    for i = 1, runs_amount do
        obs.obs_property_list_add_int(runs_list, runs[i], i - 1)
    end

    obs.obs_properties_add_button(ctx.props_def, util.setting_names.update_run_info,
        util.dashboard_names.update_run_info, update_run_info)
    obs.obs_properties_add_button(ctx.props_def, util.setting_names.update_twitch,
        util.dashboard_names.update_twitch, update_twitch)

    obs.obs_properties_add_text(ctx.props_def, util.setting_names.game_name, util.dashboard_names.game_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_width, util.dashboard_names.game_width,
        1, 1920, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_height, util.dashboard_names.game_height,
        1, 1080, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_x, util.dashboard_names.game_x,
        0, 1920, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_y, util.dashboard_names.game_y,
        0, 1080, 1)
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
    obs.obs_properties_add_path(ctx.props_def, util.setting_names.r1_avatar, util.dashboard_names.r1_avatar,
        obs.OBS_PATH_FILE, "Image files (*.bmp *.tga *.png *.jpeg *.jpg *.jxr *.gif *.psd *.webp)", nil)

    local slider = obs.obs_properties_add_int_slider(ctx.props_def, util.setting_names.comm_amt,
        util.dashboard_names.comm_amt, 0, 4, 1)
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

layout_1p_no_cam_16x9_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    ctx.props_settings = settings

    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    util.set_item_visible(ctx, util.setting_names.comms, false)
    if comm_amt > 0 then
        util.set_item_visible(ctx, util.setting_names.comms, true)
    end
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

    util.set_obs_image_path(ctx, util.setting_names.r1_avatar_source, util.setting_names.r1_avatar)

    ctx.game_width = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_width)
    ctx.game_height = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_height)
    ctx.game_x = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_x)
    ctx.game_y = obs.obs_data_get_int(ctx.props_settings, util.setting_names.game_y)

    util.set_obs_text(ctx, util.setting_names.game_name_source, util.setting_names.game_name)
    util.set_obs_text(ctx, util.setting_names.created_by_source, util.setting_names.created_by, "Created by ")
    util.set_obs_text(ctx, util.setting_names.category_source, util.setting_names.category)
    util.set_obs_text(ctx, util.setting_names.estimate_source, util.setting_names.estimate)
    util.set_obs_text(ctx, util.setting_names.r1_source, util.setting_names.r1_name)
    util.set_obs_text(ctx, util.setting_names.r1_pr_source, util.setting_names.r1_pr)
    util.set_obs_text(ctx, util.setting_names.c1_source, util.setting_names.c1_name)
    util.set_obs_text(ctx, util.setting_names.c2_source, util.setting_names.c2_name)
    util.set_obs_text(ctx, util.setting_names.c3_source, util.setting_names.c3_name)
    util.set_obs_text(ctx, util.setting_names.c4_source, util.setting_names.c4_name)
    util.set_obs_text(ctx, util.setting_names.c1_pr_source, util.setting_names.c1_pr)
    util.set_obs_text(ctx, util.setting_names.c2_pr_source, util.setting_names.c2_pr)
    util.set_obs_text(ctx, util.setting_names.c3_pr_source, util.setting_names.c3_pr)
    util.set_obs_text(ctx, util.setting_names.c4_pr_source, util.setting_names.c4_pr)
end

layout_1p_no_cam_16x9_source_def.destroy = function(data)
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

layout_1p_no_cam_16x9_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
    local commentators_info = util.commentators_info(ctx, comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        -- obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)
        obs.obs_source_draw(data.fade_box.texture, 0, 81, 546, 995, false)
        obs.obs_source_draw(data.player_frame.texture, 132, 139, 300, 300, false)
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

        -- Runner pronouns
        obs.obs_source_draw(data.runner_pr_frame.texture, 410, 493, 92, 31, false)

        local row_indx = 0
        local x_off = 287 - 35
        local y_off = 697 - 652
        -- Draw commentator boxes
        for i = 1, comm_amt do
            if commentators_info[i].has_name then
                obs.obs_source_draw(data.comm_name_box.texture, 35 + x_off * (i - 1 - row_indx * 2),
                    648 + y_off * row_indx, 235, 35, false)
            end
            if commentators_info[i].has_name then
                obs.obs_source_draw(data.comm_pr_frame.texture, 185 + x_off * (i - 1 - row_indx * 2),
                    652 + y_off * row_indx, 79, 26, false)
            end
            if i % 2 == 0 then
                row_indx = row_indx + 1
            end
        end
        obs.obs_source_draw(data.timer_frame.texture, 587, 915, 492, 90, false)
    end

    obs.gs_blend_state_pop()
end

layout_1p_no_cam_16x9_source_def.get_width = function(data)
    return 1920
end

layout_1p_no_cam_16x9_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_1p_no_cam_16x9_source_def)

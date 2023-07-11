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

layout_3p_4x3_source_def = {}
layout_3p_4x3_source_def.scene_name = "FM 3 person layout"
layout_3p_4x3_source_def.id = "fm_2023_3_person_4x3"
layout_3p_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_3p_4x3_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c4_source, false)
    util.set_item_visible(ctx, util.setting_names.c4_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
end

layout_3p_4x3_source_def.hide_finish_times = function(ctx)
    util.set_item_visible(ctx, util.setting_names.r1_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r2_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r3_time_source, false)
end

layout_3p_4x3_source_def.get_name = function()
    return "FM 4x3 3 person layout"
end

layout_3p_4x3_source_def.create = function(settings, source)
    local data = {}
    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.game_frame = obs.gs_image_file()
    data.logo_frame = obs.gs_image_file()
    data.commentators_box = obs.gs_image_file()
    data.logo = obs.gs_image_file()

    local ctx = util.create_item_ctx(layout_3p_4x3_source_def.id)
    ctx.scene = layout_3p_4x3_source_def.scene_name

    ctx.game_resolutions = {
        {
            offset_x = 14,
            offset_y = 22,
            width = 670,
            height = 504,
            game_x = 14,
            game_y = 22
        },
        {
            offset_x = 1238,
            offset_y = 22,
            width = 670,
            height = 504,
            game_x = 1238,
            game_y = 22
        },
        {
            offset_x = 14,
            offset_y = 555,
            width = 670,
            height = 504,
            game_x = 14,
            game_y = 555
        },
        {
            offset_x = 1238,
            offset_y = 555,
            width = 670,
            height = 504,
            game_x = 1238,
            game_y = 555
        }
    }

    ctx.props_settings = settings

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    local template_path = script_path() .. util.layout_templates_path
    local img_path = script_path() .. util.layout_builder_path
    util.image_source_load(data.background, template_path .. "3_person_4x3.png")
    util.image_source_load(data.comm_name_box, img_path .. "3p_comm_name_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.game_frame, img_path .. "3p_game_frame.png")
    util.image_source_load(data.logo_frame, img_path .. "3p_logo_frame.png")
    util.image_source_load(data.commentators_box, img_path .. "3p_commentators_box.png")
    util.image_source_load(data.logo, img_path .. "logo.png")

    return data
end

layout_3p_4x3_source_def.get_defaults = function(settings)
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
    local ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
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
    local ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx)

    util.set_prop_text(ctx, util.setting_names.game_name, run_data.game_name)
    util.set_prop_text(ctx, util.setting_names.created_by, run_data.created_by)
    util.set_prop_text(ctx, util.setting_names.estimate, run_data.estimate)
    util.set_prop_text(ctx, util.setting_names.category, run_data.category)

    local runner_amount = #(run_data.runners)

    if runner_amount > 3 then
        runner_amount = 3
    end

    for i = 1, runner_amount do
        util.set_prop_text(ctx, util.setting_names["r" .. tostring(i) .. "_name"], run_data.runners[i].name)
        util.set_prop_text(ctx, util.setting_names["r" .. tostring(i) .. "_pr"], run_data.runners[i].pronouns)
    end

    local comm_amt = #(run_data.commentators)
    if comm_amt == 0 then
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
        width = 670,
        height = 504
    }

    -- TODO: Fix some games not fitting properly or getting weird offsets
    local x, y, width, height = util.fit_screen(run_data.ratio.width, run_data.ratio.height, max_size.width,
        max_size.height)

    for i = 1, 4 do
        ctx.game_resolutions[i].game_x = ctx.game_resolutions[i].offset_x + x
        ctx.game_resolutions[i].game_y = ctx.game_resolutions[i].offset_y + y
        ctx.game_resolutions[i].game_width = width
        ctx.game_resolutions[i].game_height = height
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_width .. tostring(i),
            ctx.game_resolutions[i].game_width)
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_height .. tostring(i),
            ctx.game_resolutions[i].game_height)
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_x .. tostring(i),
            ctx.game_resolutions[i].game_x)
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_y .. tostring(i),
            ctx.game_resolutions[i].game_y)
    end

    layout_3p_4x3_source_def.update(nil, ctx.props_settings)

    return true
end

local function update_twitch(props, p)
    local ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx)

    twitch.update_title(run_data.game_name, run_data.twitch_directory, run_data.runner_string)
end

layout_3p_4x3_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
    ctx.scene = layout_3p_4x3_source_def.scene_name
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

layout_3p_4x3_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
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
    util.set_obs_text(ctx, util.setting_names.r3_source, util.setting_names.r3_name)
    util.set_obs_text(ctx, util.setting_names.r3_pr_source, util.setting_names.r3_pr)
    util.set_obs_text(ctx, util.setting_names.r1_time_source, util.setting_names.r1_time)
    util.set_obs_text(ctx, util.setting_names.r2_time_source, util.setting_names.r2_time)
    util.set_obs_text(ctx, util.setting_names.r3_time_source, util.setting_names.r3_time)
    util.set_obs_text(ctx, util.setting_names.c1_source, util.setting_names.c1_name)
    util.set_obs_text(ctx, util.setting_names.c2_source, util.setting_names.c2_name)
    util.set_obs_text(ctx, util.setting_names.c3_source, util.setting_names.c3_name)
    util.set_obs_text(ctx, util.setting_names.c4_source, util.setting_names.c4_name)
    util.set_obs_text(ctx, util.setting_names.c1_pr_source, util.setting_names.c1_pr)
    util.set_obs_text(ctx, util.setting_names.c2_pr_source, util.setting_names.c2_pr)
    util.set_obs_text(ctx, util.setting_names.c3_pr_source, util.setting_names.c3_pr)
    util.set_obs_text(ctx, util.setting_names.c4_pr_source, util.setting_names.c4_pr)
end

layout_3p_4x3_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.comm_name_box)
    obs.gs_image_file_free(data.comm_pr_frame)
    obs.gs_image_file_free(data.commentators_box)
    obs.gs_image_file_free(data.game_frame)
    obs.gs_image_file_free(data.logo_frame)
    obs.gs_image_file_free(data.logo)
    obs.obs_leave_graphics()
end

layout_3p_4x3_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false);

        for i = 1, 3 do
            obs.obs_source_draw(data.game_frame.texture, ctx.game_resolutions[i].game_x, ctx.game_resolutions[i].game_y,
                ctx.game_resolutions[i].width, ctx.game_resolutions[i].height, false)
        end

        obs.obs_source_draw(data.logo_frame.texture, ctx.game_resolutions[4].game_x, ctx.game_resolutions[4].game_y,
            ctx.game_resolutions[4].width, ctx.game_resolutions[4].height, false)

        obs.obs_source_draw(data.logo.texture, 1453, 695, 230, 232, false)

        if comm_amt ~= 0 then
            obs.obs_source_draw(data.commentators_box.texture, 720, 834, 478, 33, false)
        end

        local row_indx = 0
        local box_start_x = 716
        local box_start_y = 877
        local box_width = 236
        local box_height = 37
        local x_off = box_width + 16
        local y_off = box_height + 16
        -- Draw commentator boxes
        for i = 1, comm_amt do
            obs.obs_source_draw(data.comm_name_box.texture, box_start_x + x_off * (i - 1 - row_indx * 2),
                box_start_y + y_off * row_indx, box_width, box_height, false)
            obs.obs_source_draw(data.comm_pr_frame.texture, 867 + x_off * (i - 1 - row_indx * 2), 883 + y_off * row_indx,
                79, 26, false)
            if i % 2 == 0 then
                row_indx = row_indx + 1
            end
        end
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

obs.obs_register_source(layout_3p_4x3_source_def)

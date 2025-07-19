require("util")

local obs = obslua
local bit = require("bit")

layout_4p_4x3_source_def = {}
layout_4p_4x3_source_def.scene_name = "FM 4 person layout"
layout_4p_4x3_source_def.id = "fm_2023_4_person_4x3"
layout_4p_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_4p_4x3_source_def.hide_commentators = function(ctx)
    util.set_item_visible(ctx, util.setting_names.c4_source, false)
    util.set_item_visible(ctx, util.setting_names.c4_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_source, false)
    util.set_item_visible(ctx, util.setting_names.c3_pr_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_source, false)
    util.set_item_visible(ctx, util.setting_names.c2_pr_source, false)
end

layout_4p_4x3_source_def.hide_finish_times = function(ctx)
    util.set_item_visible(ctx, util.setting_names.r1_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r2_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r3_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r4_time_source, false)
end

layout_4p_4x3_source_def.get_name = function()
    return "FM 4x3 4 person layout"
end

layout_4p_4x3_source_def.create = function(settings, source)
    local data = {}
    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.game_frame = obs.gs_image_file()
    data.commentators_box = obs.gs_image_file()

    local ctx = util.create_item_ctx(layout_4p_4x3_source_def.id)
    ctx.scene = layout_4p_4x3_source_def.scene_name

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
    util.image_source_load(data.background, template_path .. "4_person_4x3.png")
    util.image_source_load(data.comm_name_box, img_path .. "3p_comm_name_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.game_frame, img_path .. "3p_game_frame.png")
    util.image_source_load(data.commentators_box, img_path .. "3p_commentators_box.png")

    return data
end

layout_4p_4x3_source_def.get_defaults = function(settings)
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
    obs.obs_data_set_default_string(settings, util.setting_names.r4_name, "Runner 4")
    obs.obs_data_set_default_string(settings, util.setting_names.r4_pr, "They/Them")
    obs.obs_data_set_default_string(settings, util.setting_names.r1_time, "0:00:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r2_time, "0:00:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r3_time, "0:00:00")
    obs.obs_data_set_default_string(settings, util.setting_names.r4_time, "0:00:00")
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

layout_4p_4x3_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_4p_4x3_source_def.id)
    ctx.scene = layout_4p_4x3_source_def.scene_name
    ctx.props_def = obs.obs_properties_create()

    for i = 1, 4 do
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_width .. tostring(i),
            util.dashboard_names.game_width .. " " .. tostring(i), 1, 670, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_height .. tostring(i),
            util.dashboard_names.game_height .. " " .. tostring(i), 1, 504, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_x .. tostring(i),
            util.dashboard_names.game_x .. " " .. tostring(i), 0, 1920, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_y .. tostring(i),
            util.dashboard_names.game_y .. " " .. tostring(i), 0, 1080, 1)
    end

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_4p_4x3_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_4p_4x3_source_def.id)
    ctx.props_settings = settings

    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)
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
    if comm_amt == 0 then
        util.set_item_visible(ctx, util.setting_names.c1_source, false)
        util.set_item_visible(ctx, util.setting_names.c1_pr_source, false)
    end

    for i = 1, 4 do
        ctx.game_resolutions[i].game_x = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_x .. tostring(i))
        ctx.game_resolutions[i].game_y = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_y .. tostring(i))
        ctx.game_resolutions[i].width = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_width .. tostring(i))
        ctx.game_resolutions[i].height = obs.obs_data_get_int(ctx.props_settings,
            util.setting_names.game_height .. tostring(i))
    end

    util.set_obs_text(ctx, util.setting_names.r1_time_source, util.setting_names.r1_time)
    util.set_obs_text(ctx, util.setting_names.r2_time_source, util.setting_names.r2_time)
    util.set_obs_text(ctx, util.setting_names.r3_time_source, util.setting_names.r3_time)
    util.set_obs_text(ctx, util.setting_names.r4_time_source, util.setting_names.r4_time)
end

layout_4p_4x3_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.comm_name_box)
    obs.gs_image_file_free(data.comm_pr_frame)
    obs.gs_image_file_free(data.commentators_box)
    obs.gs_image_file_free(data.game_frame)
    obs.obs_leave_graphics()
end

layout_4p_4x3_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    local ctx = util.get_item_ctx(layout_4p_4x3_source_def.id)
    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        -- obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)

        for i = 1, 4 do
            obs.obs_source_draw(data.game_frame.texture, ctx.game_resolutions[i].game_x, ctx.game_resolutions[i].game_y,
                ctx.game_resolutions[i].width, ctx.game_resolutions[i].height, false)
        end

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

    obs.gs_blend_state_pop()
end

layout_4p_4x3_source_def.get_width = function(data)
    return 1920
end

layout_4p_4x3_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_4p_4x3_source_def)

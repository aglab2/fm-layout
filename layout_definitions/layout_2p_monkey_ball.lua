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

layout_2p_monkey_ball_source_def.hide_finish_times = function(ctx)
    util.set_item_visible(ctx, util.setting_names.r1_time_source, false)
    util.set_item_visible(ctx, util.setting_names.r2_time_source, false)
end

layout_2p_monkey_ball_source_def.get_name = function()
    return "FM 4x3 monkey ball tournament layout"
end

layout_2p_monkey_ball_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_2p_monkey_ball_source_def.id)
    ctx.scene = layout_2p_monkey_ball_source_def.scene_name

    ctx.game_resolutions = {
        {
            offset_x = 12,
            offset_y = 23,
            width = 936,
            height = 703,
            game_x = 12,
            game_y = 23
        },
        {
            offset_x = 974,
            offset_y = 23,
            width = 936,
            height = 703,
            game_x = 974,
            game_y = 23
        }
    }

    ctx.player_scores = {
        0,
        0
    }

    ctx.participants = {}

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.game_frame = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.commentators_box = obs.gs_image_file()
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
    util.image_source_load(data.commentators_box, img_path .. "2p_tournament_commentators_box.png")

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

local update_run_info = function(props, p)
    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx, true)

    ctx.participants = run_data.participants
    local participants_list_1 = obs.obs_properties_get(ctx.props_def, util.setting_names.participants_list_1)
    local participants_list_2 = obs.obs_properties_get(ctx.props_def, util.setting_names.participants_list_2)
    obs.obs_property_list_clear(participants_list_1)
    obs.obs_property_list_clear(participants_list_2)

    local participant_amount = #(ctx.participants)
    for i = 1, participant_amount do
        obs.obs_property_list_add_int(participants_list_1,
            ctx.participants[i].name .. "(" .. ctx.participants[i].pronouns .. ")", i)
        obs.obs_property_list_add_int(participants_list_2,
            ctx.participants[i].name .. "(" .. ctx.participants[i].pronouns .. ")", i)
    end



    util.set_prop_text(ctx, util.setting_names.game_name, run_data.game_name)
    util.set_prop_text(ctx, util.setting_names.created_by, run_data.created_by)
    util.set_prop_text(ctx, util.setting_names.estimate, run_data.estimate)
    util.set_prop_text(ctx, util.setting_names.category, run_data.category)

    local runner_amount = #(run_data.runners)

    if runner_amount > 2 then
        runner_amount = 2
    end

    for i = 1, runner_amount do
        util.set_prop_text(ctx, util.setting_names["r" .. tostring(i) .. "_name"], run_data.runners[i].name)
        util.set_prop_text(ctx, util.setting_names["r" .. tostring(i) .. "_pr"], run_data.runners[i].pronouns)
    end

    local comm_amt = #(run_data.commentators)
    -- util.set_item_visible(ctx, util.setting_names.comms, true)
    if comm_amt == 0 then
        -- util.set_item_visible(ctx, util.setting_names.comms, false)
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
        width = 936,
        height = 703
    }

    local x, y, width, height = util.fit_screen(run_data.ratio.width, run_data.ratio.height, max_size.width,
        max_size.height)

    for i = 1, 2 do
        ctx.game_resolutions[i].game_x = ctx.game_resolutions[i].offset_x + x
        ctx.game_resolutions[i].game_y = ctx.game_resolutions[i].offset_y + y
        ctx.game_resolutions[i].width = width
        ctx.game_resolutions[i].height = height
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_width .. tostring(i),
            ctx.game_resolutions[i].width)
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_height .. tostring(i),
            ctx.game_resolutions[i].height)
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_x .. tostring(i),
            ctx.game_resolutions[i].game_x)
        obs.obs_data_set_int(ctx.props_settings, util.setting_names.game_y .. tostring(i),
            ctx.game_resolutions[i].game_y)
    end

    layout_2p_monkey_ball_source_def.update(nil, ctx.props_settings)

    return true
end

local function update_twitch(props, p)
    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    local run_idx = obs.obs_data_get_int(ctx.props_settings, util.setting_names.runs_list)
    local run_data = schedule.get_run_data(run_idx, true)

    twitch.update_title(run_data.game_name, run_data.twitch_directory, run_data.runner_string, run_data.is_tas)
end

layout_2p_monkey_ball_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    local runs_list = obs.obs_properties_add_list(ctx.props_def, util.setting_names.runs_list,
        util.dashboard_names.runs_list, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    local runs = schedule.get_multiplayer_runs()
    local runs_amount = #(runs)
    for i = 1, runs_amount do
        obs.obs_property_list_add_int(runs_list, runs[i].name, runs[i].index - 1)
    end

    obs.obs_properties_add_bool(ctx.props_def, util.setting_names.fill_with_participant,
        util.dashboard_names.fill_with_participant)

    obs.obs_properties_add_button(ctx.props_def, util.setting_names.update_run_info,
        util.dashboard_names.update_run_info, update_run_info)
    obs.obs_properties_add_button(ctx.props_def, util.setting_names.update_twitch,
        util.dashboard_names.update_twitch, update_twitch)

    local participants_list_1 = obs.obs_properties_add_list(ctx.props_def, util.setting_names.participants_list_1,
        util.dashboard_names.participants_list_1, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    local participants_list_2 = obs.obs_properties_add_list(ctx.props_def, util.setting_names.participants_list_2,
        util.dashboard_names.participants_list_2, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)

    if #(ctx.participants) > 0 then
        local participant_amount = #(ctx.participants)
        for i = 1, participant_amount do
            obs.obs_property_list_add_int(participants_list_1,
                ctx.participants[i].name .. "(" .. ctx.participants[i].pronouns .. ")", i)
            obs.obs_property_list_add_int(participants_list_2,
                ctx.participants[i].name .. "(" .. ctx.participants[i].pronouns .. ")", i)
        end
    end

    obs.obs_properties_add_int(ctx.props_def, util.setting_names.player_1_score, util.dashboard_names.player_1_score, 0,
        3, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.player_2_score, util.dashboard_names.player_2_score, 0,
        3, 1)

    obs.obs_properties_add_text(ctx.props_def, util.setting_names.game_name, util.dashboard_names.game_name,
        obs.OBS_TEXT_DEFAULT)

    for i = 1, 2 do
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_width .. tostring(i),
            util.dashboard_names.game_width .. " " .. tostring(i), 1, 936, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_height .. tostring(i),
            util.dashboard_names.game_height .. " " .. tostring(i), 1, 703, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_x .. tostring(i),
            util.dashboard_names.game_x .. " " .. tostring(i), 0, 1920, 1)
        obs.obs_properties_add_int(ctx.props_def, util.setting_names.game_y .. tostring(i),
            util.dashboard_names.game_y .. " " .. tostring(i), 0, 1080, 1)
    end

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

    ctx.player_scores[1] = obs.obs_data_get_int(ctx.props_settings, util.setting_names.player_1_score)
    ctx.player_scores[2] = obs.obs_data_get_int(ctx.props_settings, util.setting_names.player_2_score)

    if obs.obs_data_get_bool(ctx.props_settings, util.setting_names.fill_with_participant) then
        local part_1_index = obs.obs_data_get_int(ctx.props_settings, util.setting_names.participants_list_1)
        local part_2_index = obs.obs_data_get_int(ctx.props_settings, util.setting_names.participants_list_2)

        local parts_amt = #(ctx.participants)
        if part_1_index ~= 0 and parts_amt > 0 and part_1_index <= parts_amt and part_2_index <= parts_amt then
            util.set_obs_text_no_source(ctx, util.setting_names.r1_source, ctx.participants[part_1_index].name)
            util.set_obs_text_no_source(ctx, util.setting_names.r1_pr_source, ctx.participants[part_1_index].pronouns)
            util.set_obs_text_no_source(ctx, util.setting_names.r2_source, ctx.participants[part_2_index].name)
            util.set_obs_text_no_source(ctx, util.setting_names.r2_pr_source, ctx.participants[part_2_index].pronouns)
        end
    else
        util.set_obs_text(ctx, util.setting_names.r1_source, util.setting_names.r1_name)
        util.set_obs_text(ctx, util.setting_names.r1_pr_source, util.setting_names.r1_pr)
        util.set_obs_text(ctx, util.setting_names.r2_source, util.setting_names.r2_name)
        util.set_obs_text(ctx, util.setting_names.r2_pr_source, util.setting_names.r2_pr)
    end

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
    obs.gs_image_file_free(data.commentators_box)
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

        for i = 1, 2 do
            obs.obs_source_draw(data.game_frame.texture, ctx.game_resolutions[i].game_x, ctx.game_resolutions[i].game_y,
                ctx.game_resolutions[i].width, ctx.game_resolutions[i].height, false)
        end

        if comm_amt ~= 0 then
            obs.obs_source_draw(data.commentators_box.texture, 31, 870, 534, 32, false)
        end

        local p1_score_x = 565
        local p1_score_y = 751
        local p2_score_x = 1331
        local p2_score_y = 751
        local p1_score_dif = ctx.player_scores[1] + 1
        local p2_score_dif = ctx.player_scores[2] + 1
        local score_dims = 28
        local score_offset = 40
        -- Draw empty scores
        for i = p1_score_dif, 3 do
            obs.obs_source_draw(data.empty_score.texture, p1_score_x + (i - 1) * score_offset, p1_score_y, score_dims,
                score_dims, false)
        end
        for i = p2_score_dif, 3 do
            obs.obs_source_draw(data.empty_score.texture, p2_score_x - (i - 1) * score_offset, p2_score_y, score_dims,
                score_dims, false)
        end

        -- Draw obtained scores
        for i = 1, ctx.player_scores[1] do
            obs.obs_source_draw(data.score.texture, p1_score_x + (i - 1) * score_offset, p1_score_y, score_dims,
                score_dims, false)
        end
        for i = 1, ctx.player_scores[2] do
            obs.obs_source_draw(data.score.texture, p2_score_x - (i - 1) * score_offset, p2_score_y, score_dims,
                score_dims, false)
        end

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

    obs.gs_blend_state_pop()
end

layout_2p_monkey_ball_source_def.get_width = function(data)
    return 1920
end

layout_2p_monkey_ball_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_2p_monkey_ball_source_def)

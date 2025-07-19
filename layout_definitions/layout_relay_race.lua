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

    ctx.last_render_clock = os.clock()

    ctx.participants = {}

    ctx.game_resolutions = {
        {
            offset_x = 79,
            offset_y = 23,
            width = 833,
            height = 627,
            game_x = 73,
            game_y = 23
        },
        {
            offset_x = 1000,
            offset_y = 23,
            width = 833,
            height = 627,
            game_x = 1000,
            game_y = 23
        }
    }

    ctx.relay_data = {
        started = false,
        yellow_team_data = {
            game = 1,
            finished = false,
            kid_current_position = {
                x = 788,
                y = 0
            },
            text_current_position = {
                x = 826,
                y = 0,
            },
            kid_frame = 0
        },
        red_team_data = {
            game = 1,
            finished = false,
            kid_current_position = {
                x = 788,
                y = 0
            },
            text_current_position = {
                x = 826,
                y = 0,
            },
            kid_frame = 0
        }
    }

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    data.background = obs.gs_image_file()
    data.comm_name_box = obs.gs_image_file()
    data.comm_pr_frame = obs.gs_image_file()
    data.kid = obs.gs_image_file()
    data.red_team_box = obs.gs_image_file()
    data.yellow_team_box = obs.gs_image_file()
    data.kid_idle = {
        obs.gs_image_file(),
        obs.gs_image_file(),
        obs.gs_image_file(),
        obs.gs_image_file()
    }
    data.kid_run = {
        obs.gs_image_file(),
        obs.gs_image_file(),
        obs.gs_image_file(),
        obs.gs_image_file()
    }

    local img_path = script_path() .. util.layout_builder_path
    local template_path = script_path() .. util.layout_templates_path

    util.image_source_load(data.background, template_path .. "relay_race.png")
    util.image_source_load(data.comm_name_box, img_path .. "2p_comm_name_box.png")
    util.image_source_load(data.comm_pr_frame, img_path .. "comm_pronouns_box.png")
    util.image_source_load(data.kid, img_path .. "relay_race_kid_run_static.png")
    util.image_source_load(data.red_team_box, img_path .. "relay_race_red_team_box.png")
    util.image_source_load(data.yellow_team_box, img_path .. "relay_race_yellow_team_box.png")

    for i = 1, 4 do
        util.image_source_load(data.kid_idle[i], img_path .. "kid_idle_1_" .. tostring(i) .. ".png")
        util.image_source_load(data.kid_run[i], img_path .. "kid_run_1_" .. tostring(i) .. ".png")
    end

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

local function start_relay(props, p)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    ctx.relay_data.started = true
end

local function yellow_team_finish_relay(props, p)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    ctx.relay_data.yellow_team_data.finished = not ctx.relay_data.yellow_team_data.finished
end

local function red_team_finish_relay(props, p)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    ctx.relay_data.red_team_data.finished = not ctx.relay_data.red_team_data.finished
end

layout_relay_race_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    ctx.props_def = obs.obs_properties_create()

    obs.obs_properties_add_bool(ctx.props_def, util.setting_names.fill_with_participant,
        "Fill runner names automatically")

    obs.obs_properties_add_button(ctx.props_def, util.setting_names.start_relay,
        util.dashboard_names.start_relay, start_relay)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.yellow_team_position,
        util.dashboard_names.yellow_team_position, 1, 5, 1)
    obs.obs_properties_add_int(ctx.props_def, util.setting_names.red_team_position,
        util.dashboard_names.red_team_position, 1, 5, 1)
    obs.obs_properties_add_button(ctx.props_def, util.setting_names.yellow_team_finish,
        util.dashboard_names.yellow_team_finish, yellow_team_finish_relay)
    obs.obs_properties_add_button(ctx.props_def, util.setting_names.red_team_finish,
        util.dashboard_names.red_team_finish, red_team_finish_relay)


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

    ctx.relay_data.yellow_team_data.game = obs.obs_data_get_int(ctx.props_settings,
        util.setting_names.yellow_team_position)
    ctx.relay_data.red_team_data.game = obs.obs_data_get_int(ctx.props_settings,
        util.setting_names.red_team_position)

    util.set_obs_text(ctx, util.setting_names.yellow_team_name_source, util.setting_names.yellow_team_name)
    util.set_obs_text(ctx, util.setting_names.red_team_name_source, util.setting_names.red_team_name)
    util.set_obs_text(ctx, util.setting_names.category_source, util.setting_names.category)
    util.set_obs_text(ctx, util.setting_names.estimate_source, util.setting_names.estimate)

    if #(ctx.participants) == 10 and obs.obs_data_get_bool(ctx.props_settings, util.setting_names.fill_with_participant) then
        util.set_obs_text_no_source(ctx, util.setting_names.r1_source,
            ctx.participants[ctx.relay_data.yellow_team_data.game].name)
        util.set_obs_text_no_source(ctx, util.setting_names.r2_source,
            ctx.participants[ctx.relay_data.red_team_data.game + 5].name)
    else
        util.set_obs_text(ctx, util.setting_names.r1_source, util.setting_names.r1_name)
        util.set_obs_text(ctx, util.setting_names.r2_source, util.setting_names.r2_name)
    end

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
    for i = 1, 4 do
        obs.gs_image_file_free(data.kid_idle[i])
        obs.gs_image_file_free(data.kid_run[i])
    end
    obs.obs_leave_graphics()
end

layout_relay_race_source_def.tick_players = function()
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    local r1_uuid = obs.obs_data_get_string(ctx.props_settings, util.setting_names.r1_source)
    local r2_uuid = obs.obs_data_get_string(ctx.props_settings, util.setting_names.r2_source)
    if not ctx.layout_objects[r1_uuid] then
        ctx.layout_objects[r1_uuid] = { x = 0, y = 0 }
    end
    if not ctx.layout_objects[r2_uuid] then
        ctx.layout_objects[r2_uuid] = { x = 0, y = 0 }
    end

    local r1_pos = ctx.layout_objects[r1_uuid]
    local r2_pos = ctx.layout_objects[r2_uuid]

    local to_game_offset = 236
    local yellow_team_position = ctx.relay_data.yellow_team_data.game - 1
    local red_team_position = ctx.relay_data.red_team_data.game - 1
    local yellow_text_target_position = r1_pos.x + to_game_offset * yellow_team_position
    ctx.relay_data.yellow_team_data.text_current_position.x =
        util.lerp(ctx.relay_data.yellow_team_data.text_current_position.x, yellow_text_target_position, 0.1)
    local red_text_target_position = r2_pos.x + to_game_offset * red_team_position
    ctx.relay_data.red_team_data.text_current_position.x =
        util.lerp(ctx.relay_data.red_team_data.text_current_position.x, red_text_target_position, 0.1)
    util.set_obs_position(ctx, util.setting_names.r1_source, {
        x = ctx.relay_data.yellow_team_data.text_current_position.x,
        y = r1_pos.y
    })
    util.set_obs_position(ctx, util.setting_names.r2_source, {
        x = ctx.relay_data.red_team_data.text_current_position.x,
        y = r2_pos.y
    })

    obs.remove_current_callback()
end

layout_relay_race_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    -- Defer updates to player locations, it is not allowed to update the position of sources in the video_render callback
    -- because lookups by uuid cause deadlocks
    obs.timer_add(layout_relay_race_source_def.tick_players, 1)
    -- util.bind_update(layout_relay_race_source_def.tick_players)
    local ctx = util.get_item_ctx(layout_relay_race_source_def.id)

    local delta = os.clock() - ctx.last_render_clock

    local comm_amt = obs.obs_data_get_int(ctx.props_settings, util.setting_names.comm_amt)

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        -- Background
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)

        obs.obs_source_draw(data.yellow_team_box.texture, ctx.game_resolutions[1].game_x, ctx.game_resolutions[1].game_y,
            ctx.game_resolutions[1].width, ctx.game_resolutions[1].height, false)
        obs.obs_source_draw(data.red_team_box.texture, ctx.game_resolutions[2].game_x, ctx.game_resolutions[2].game_y,
            ctx.game_resolutions[2].width, ctx.game_resolutions[2].height, false)

        local to_game_offset = 236
        local yellow_team_position = ctx.relay_data.yellow_team_data.game - 1
        local red_team_position = ctx.relay_data.red_team_data.game - 1
        local yellow_anim_speed = 8 * delta
        local red_anim_speed = 8 * delta
        local yellow_frame_data = data.kid_idle
        local red_frame_data = data.kid_idle
        if ctx.relay_data.started then
            yellow_frame_data = data.kid_run
            red_frame_data = data.kid_run
            yellow_anim_speed = 15 * delta
            red_anim_speed = yellow_anim_speed
        end
        if ctx.relay_data.yellow_team_data.finished then
            yellow_anim_speed = 8 * delta
            yellow_frame_data = data.kid_idle
        end
        if ctx.relay_data.red_team_data.finished then
            red_anim_speed = 8 * delta
            red_frame_data = data.kid_idle
        end
        ctx.relay_data.yellow_team_data.kid_frame = ctx.relay_data.yellow_team_data.kid_frame + yellow_anim_speed
        ctx.relay_data.red_team_data.kid_frame = ctx.relay_data.red_team_data.kid_frame + red_anim_speed
        if ctx.relay_data.yellow_team_data.kid_frame >= 4 then
            ctx.relay_data.yellow_team_data.kid_frame = 0
        end
        if ctx.relay_data.red_team_data.kid_frame >= 4 then
            ctx.relay_data.red_team_data.kid_frame = 0
        end

        local yellow_kid_texture = yellow_frame_data[math.floor(ctx.relay_data.yellow_team_data.kid_frame) + 1].texture
        local red_kid_texture = red_frame_data[math.floor(ctx.relay_data.red_team_data.kid_frame) + 1].texture

        local yellow_kid_target_position = 788 + to_game_offset * yellow_team_position
        ctx.relay_data.yellow_team_data.kid_current_position.x =
            util.lerp(ctx.relay_data.yellow_team_data.kid_current_position.x, yellow_kid_target_position, 0.1)
        -- Yellow team kid
        obs.obs_source_draw(yellow_kid_texture, ctx.relay_data.yellow_team_data.kid_current_position.x, 705, 72, 63,
            false)

        local red_kid_target_position = 788 + to_game_offset * red_team_position
        ctx.relay_data.red_team_data.kid_current_position.x =
            util.lerp(ctx.relay_data.red_team_data.kid_current_position.x, red_kid_target_position, 0.1)
        -- Red team kid
        obs.obs_source_draw(red_kid_texture, ctx.relay_data.red_team_data.kid_current_position.x, 846, 72, 63, false)

        local x_off = 245
        -- Draw commentator boxes
        for i = 1, comm_amt do
            obs.obs_source_draw(data.comm_name_box.texture, 79 + x_off * (i - 1), 908,
                228, 35, false)
            obs.obs_source_draw(data.comm_pr_frame.texture, 223 + x_off * (i - 1), 913,
                79, 26, false)
        end
    end

    obs.gs_blend_state_pop()

    ctx.last_render_clock = os.clock()
end

layout_relay_race_source_def.get_width = function(data)
    return 1920
end

layout_relay_race_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_relay_race_source_def)

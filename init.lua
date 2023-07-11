-- OBS API: https://obsproject.com/docs/index.html
--
-- To output to OBS script log window use `obs.script_log(obs.LOG_INFO, "Message")`

require("layout_source")
require("util")
require("timer_controller")
local obs = obslua
local json = require("cjson")
local schedule = require("schedule.schedule")
local twitch = require("twitch_api.twitch")

local description = [[
    <center><h2>Fangame Marathon 2023 Layout Program v1</h2></center>
    <p>
    <center><h3>Programmer Smartkin</h3></center>
    <center><h3>Layouts designer Oiivae</h3></center>
    <center><h3>Producers Cosmoing, Wolsk</h3></center>
    DO NOT delete any of the layout elements. This WILL break the Dashboard. Especially the Dashboard itself, it WILL force you to recreate ALL the layouts. Other than the scenes you are free to rename the elements inside them.
    <p>
    In the Dashboard itself DO NOT and I say DO NOT click the Defaults button under ANY circumstances. This WILL break the entire program and will force you to recreate the layouts.
    <p>
    After creating the layouts you can add new elements if you need to, but they won't be automated by the Dashboard provided for each scene.
    <p>
    MAKE SURE that you are logged into FangameMarathon Twitch account before pressing Connect Twitch button! Otherwise, title updating won't work!
    <p>
    <h1>!!!!!IF YOU RESTARTED THE OBS YOU NEED TO PRESS Connect Twitch BUTTON AGAIN!!!!!</h1>
]]

-- Creates a timer controller for the scene
local function create_timer_controller(new_scene, scene_name, timer, runners_amount, runner_finish_sources)
    local timer_data = obs.obs_data_create()
    obs.obs_data_set_int(timer_data, util.setting_names.runner_amt, runners_amount)
    obs.obs_data_set_string(timer_data, util.setting_names.timer_source, timer.uuid)
    obs.obs_data_set_string(timer_data, util.setting_names.scene, scene_name)
    if runner_finish_sources ~= nil then
        local runner_amt = #(runner_finish_sources)
        if runner_amt == 2 then
            obs.obs_data_set_string(timer_data, util.setting_names.left_runner, runner_finish_sources[1].uuid)
            obs.obs_data_set_string(timer_data, util.setting_names.right_runner, runner_finish_sources[2].uuid)
        elseif runner_amt == 3 then
            obs.obs_data_set_string(timer_data, util.setting_names.top_left_runner, runner_finish_sources[1].uuid)
            obs.obs_data_set_string(timer_data, util.setting_names.top_right_runner, runner_finish_sources[2].uuid)
            obs.obs_data_set_string(timer_data, util.setting_names.bottom_left_runner, runner_finish_sources[3].uuid)
        elseif runner_amt == 4 then
            obs.obs_data_set_string(timer_data, util.setting_names.top_left_runner, runner_finish_sources[1].uuid)
            obs.obs_data_set_string(timer_data, util.setting_names.top_right_runner, runner_finish_sources[2].uuid)
            obs.obs_data_set_string(timer_data, util.setting_names.bottom_left_runner, runner_finish_sources[3].uuid)
            obs.obs_data_set_string(timer_data, util.setting_names.bottom_right_runner, runner_finish_sources[4].uuid)
        end
    end

    local timer_controller = obs.obs_source_create(timer_controller.id, "Timer Controller", timer_data, nil)
    obs.obs_scene_add(new_scene, timer_controller)
    obs.obs_data_release(timer_data)
    obs.obs_source_release(timer_controller)

    local timer_controller_item = obs.obs_scene_sceneitem_from_source(new_scene, timer_controller)
    obs.obs_sceneitem_set_order(timer_controller_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(timer_controller_item)
end

function create_layouts(layout_props, btn_prop)
    -- obs.script_log(obs.LOG_INFO, "Creating layouts...")
    create_1p_no_cam_4x3_layout()
    create_1p_no_cam_16x9_layout()
    create_1p_w_cam_4x3_layout()
    create_1p_w_cam_16x9_layout()
    create_2p_4x3_layout()
    create_3p_4x3_layout()
    create_4p_4x3_layout()
    create_2p_tournament_layout()
    create_2p_monkey_ball_layout()
    create_relay_race_layout()
    create_fish_out_water_layout()
    create_kh2_randomizer_layout()
    create_lm2_randomizer_layout()
end

function init_twitch(layout_props, btn_prop)
    -- obs.script_log(obs.LOG_INFO, "Initializing Twitch")
    local auth_url = twitch.get_auth_url()
    os.execute('start "" "' .. auth_url .. '"')
    local client = twitch.auth_listener:accept()
    twitch.parse_auth_data(client:receive("*l"))
    client:receive("*a")
    client:close()
    twitch.auth_listener:close()
    twitch.auth_listener = nil

    twitch.get_auth_token()
end

function reload_schedule()
    schedule.get_schedule(true)
end

local previous_updates_size = 0
local can_update = false
function do_updates()
    local updates_size = #(util.delayed_update)
    local update_next_time = previous_updates_size ~= updates_size
    if can_update and updates_size > 0 then
        for i = 1, updates_size do
            util.delayed_update[i]()
        end
        util.delayed_update = {}
    end
    can_update = update_next_time
    previous_updates_size = updates_size
end

function script_load(settings)
    obs.timer_add(do_updates, 500)

    schedule.get_schedule()

    twitch.init()

    local settings_json = obs.obs_data_get_json(settings)
    local ctx_items = json.decode(settings_json)
    util.items_ctx = mergeTables(util.items_ctx, ctx_items)
end

function script_defaults(settings)
end

function script_save(settings)
    -- local start_time = os.clock()
    local util_ctx_copy = util.copy_exclude(util.items_ctx, nil, {
        props_def = "props_def",
        props_settings = "props_settings"
    })
    local json_string = json.encode(util_ctx_copy)
    local json_data = obs.obs_data_create_from_json(json_string)
    obs.obs_data_apply(settings, json_data)
    -- local end_time = os.clock() - start_time
    -- obs.script_log(obs.LOG_INFO, "It took " .. end_time .. " seconds to save the script settings")
    obs.obs_data_release(json_data)
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_button(props, "create_layouts", "Create layouts", create_layouts)
    obs.obs_properties_add_button(props, "reload_schedule", "Reload schedule file", reload_schedule)
    obs.obs_properties_add_button(props, "init_twitch", "Connect Twitch", init_twitch)
    return props
end

function script_description()
    return description
end

function create_1p_no_cam_4x3_layout()
    local new_scene = util.create_scene(layout_1p_no_cam_4x3_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 271, 488)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 455, 499)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 120, 652)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 368, 652)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Myrral", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 120, 697)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "Smartkin", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 368, 697)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 224, 657)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 476, 657)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "She/Her", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 224, 702)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 476, 702)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 1502, 885)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 1365, 975)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1638, 975)
    local timer = util.create_timer(new_scene, util.source_names.timer, 702, 900, 250, 70)
    local runner_avatar = util.create_image(new_scene, util.source_names.runner_1_avatar, 115 + 158, 147 + 145, 317, 289)
    local commentators_text = util.create_text_eaves(new_scene, "Regular", "COMMENTATORS", 26, util.text_halign.center,
        util.colors.white, util.source_names.commentators, 276, 607)

    -- Non-cached elements that will be static in the layout

    util.create_text_eaves(new_scene, "Book", "category", 24, util.text_halign.center, util.colors.white,
        util.source_names.category_static, 1365, 1016, obs.S_TRANSFORM_UPPERCASE)
    util.create_text_eaves(new_scene, "Book", "estimate", 24, util.text_halign.center, util.colors.white,
        util.source_names.estimate_static, 1638, 1016, obs.S_TRANSFORM_UPPERCASE)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.comms, commentators_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_avatar_source, runner_avatar.uuid)

    local layout_source = obs.obs_source_create(layout_1p_no_cam_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_1p_no_cam_4x3_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_1p_no_cam_4x3_source_def.id)
    scene_ctx.scene = layout_1p_no_cam_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[commentators_text.uuid] = commentators_text
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer
    scene_ctx.layout_objects[runner_avatar.uuid] = runner_avatar

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    layout_1p_no_cam_4x3_source_def.hide_commentators(util.get_item_ctx(layout_1p_no_cam_4x3_source_def.id))

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_1p_w_cam_4x3_layout()
    local new_scene = util.create_scene(layout_1p_w_cam_4x3_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 271, 488)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 455, 499)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 120, 652)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 368, 652)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Myrral", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 120, 697)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "Smartkin", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 368, 697)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 224, 657)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 476, 657)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "She/Her", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 224, 702)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 476, 702)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 1502, 885)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 1365, 975)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1638, 975)
    local timer = util.create_timer(new_scene, util.source_names.timer, 705, 900, 250, 70)
    local commentators_text = util.create_text_eaves(new_scene, "Regular", "COMMENTATORS", 26, util.text_halign.center,
        util.colors.white, util.source_names.commentators, 276, 607)

    -- Non-cached elements that will be static in the layout
    util.create_text_eaves(new_scene, "Book", "category", 24, util.text_halign.center, util.colors.white,
        util.source_names.category_static, 1365, 1016, obs.S_TRANSFORM_UPPERCASE)
    util.create_text_eaves(new_scene, "Book", "estimate", 24, util.text_halign.center, util.colors.white,
        util.source_names.estimate_static, 1638, 1016, obs.S_TRANSFORM_UPPERCASE)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.comms, commentators_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_1p_w_cam_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_1p_w_cam_4x3_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_1p_w_cam_4x3_source_def.id)
    scene_ctx.scene = layout_1p_w_cam_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[commentators_text.uuid] = commentators_text
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    layout_1p_w_cam_4x3_source_def.hide_commentators(util.get_item_ctx(layout_1p_w_cam_4x3_source_def.id))

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_2p_4x3_layout()
    local new_scene = util.create_scene(layout_2p_4x3_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 293, 1004)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 471, 1013)
    local runner_2_text = util.create_text_eaves(new_scene, "Bold", "Siglemic", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_2, 1616, 1004)
    local runner_2_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_2_pronouns, 1794, 1013)
    local runner_1_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_1_finish_time, 537, 667)
    local runner_2_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_2_finish_time, 1395, 667)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 783, 1020)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 1065, 1020)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 908, 1025)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 1191, 1025)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 968, 780)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 968, 836)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 826, 898)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1102, 898)
    local timer = util.create_timer(new_scene, util.source_names.timer, 831, 676, 250, 70)
    local border_size = 16
    local runner_1_avatar = util.create_image(new_scene, util.source_names.runner_1_avatar,
        302, 826, 324 - border_size, 324 - border_size)
    local runner_2_avatar = util.create_image(new_scene, util.source_names.runner_2_avatar,
        1645, 826, 324 - border_size, 324 - border_size)
    local commentators_text = util.create_text_eaves(new_scene, "Regular", "COMMENTATORS", 26, util.text_halign.center,
        util.colors.white, util.source_names.commentators, 968, 974)

    -- Non-cached elements that will be static in the layout
    util.create_text_eaves(new_scene, "Book", "category", 24, util.text_halign.center, util.colors.white,
        util.source_names.category_static, 831, 935, obs.S_TRANSFORM_UPPERCASE)
    util.create_text_eaves(new_scene, "Book", "estimate", 24, util.text_halign.center, util.colors.white,
        util.source_names.estimate_static, 1102, 935, obs.S_TRANSFORM_UPPERCASE)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_source, runner_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_pr_source, runner_2_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time_source, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time_source, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.comms, commentators_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_avatar_source, runner_1_avatar.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_avatar_source, runner_2_avatar.uuid)

    local layout_source = obs.obs_source_create(layout_2p_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_2p_4x3_source_def.scene_name, timer, 2, { runner_1_time, runner_2_time })

    local scene_ctx = util.get_item_ctx(layout_2p_4x3_source_def.id)
    scene_ctx.scene = layout_2p_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[runner_2_text.uuid] = runner_2_text
    scene_ctx.layout_objects[runner_2_pronouns.uuid] = runner_2_pronouns
    scene_ctx.layout_objects[runner_1_time.uuid] = runner_1_time
    scene_ctx.layout_objects[runner_2_time.uuid] = runner_2_time
    scene_ctx.layout_objects[commentators_text.uuid] = commentators_text
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer
    scene_ctx.layout_objects[runner_1_avatar.uuid] = runner_1_avatar
    scene_ctx.layout_objects[runner_2_avatar.uuid] = runner_2_avatar

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)

    obs.obs_sceneitem_release(layout_item)
    layout_2p_4x3_source_def.hide_commentators(util.get_item_ctx(layout_2p_4x3_source_def.id))
    layout_2p_4x3_source_def.hide_finish_times(util.get_item_ctx(layout_2p_4x3_source_def.id))
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_3p_4x3_layout()
    local new_scene = util.create_scene(layout_3p_4x3_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Regular", "Cosmoing", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_1, 705, 20)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 744, 54)
    local runner_2_text = util.create_text_eaves(new_scene, "Regular", "Oiivae", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_2, 1210, 20)
    local runner_2_pronouns = util.create_text_eaves(new_scene, "Heavy", "She/Her", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_2_pronouns, 1176, 54)
    local runner_3_text = util.create_text_eaves(new_scene, "Regular", "Literally Who?", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_3, 705, 1033)
    local runner_3_pronouns = util.create_text_eaves(new_scene, "Heavy", "Any", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_3_pronouns, 742, 1014)
    local runner_1_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_1_finish_time, 705, 70)
    local runner_2_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_2_finish_time, 1210, 70)
    local runner_3_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_3_finish_time, 705, 981)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 800, 882)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 1050, 882)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Myrral", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 800, 935)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "Smartkin", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 1050, 935)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 907, 888)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 1159, 888)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "She/Her", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 907, 941)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 1159, 941)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 58,
        util.text_halign.bottom_center, util.colors.blue, util.source_names.game_name, 960, 345)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 960, 350)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 960, 702)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 960, 608)
    local timer = util.create_timer(new_scene, util.source_names.timer, 831, 445, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_source, runner_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_pr_source, runner_2_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_source, runner_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_pr_source, runner_3_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time_source, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time_source, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_time, runner_3_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_time_source, runner_3_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_3p_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_3p_4x3_source_def.scene_name, timer, 3,
        { runner_1_time, runner_2_time, runner_3_time })

    local scene_ctx = util.get_item_ctx(layout_3p_4x3_source_def.id)
    scene_ctx.scene = layout_3p_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[runner_2_text.uuid] = runner_2_text
    scene_ctx.layout_objects[runner_2_pronouns.uuid] = runner_2_pronouns
    scene_ctx.layout_objects[runner_3_text.uuid] = runner_3_text
    scene_ctx.layout_objects[runner_3_pronouns.uuid] = runner_3_pronouns
    scene_ctx.layout_objects[runner_1_time.uuid] = runner_1_time
    scene_ctx.layout_objects[runner_2_time.uuid] = runner_2_time
    scene_ctx.layout_objects[runner_3_time.uuid] = runner_3_time
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    layout_3p_4x3_source_def.hide_commentators(util.get_item_ctx(layout_3p_4x3_source_def.id))
    layout_3p_4x3_source_def.hide_finish_times(util.get_item_ctx(layout_3p_4x3_source_def.id))
    obs.obs_sceneitem_release(layout_item)
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_4p_4x3_layout()
    local new_scene = util.create_scene(layout_4p_4x3_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Regular", "Cosmoing", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_1, 705, 20)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 744, 54)
    local runner_2_text = util.create_text_eaves(new_scene, "Regular", "Oiivae", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_2, 1210, 20)
    local runner_2_pronouns = util.create_text_eaves(new_scene, "Heavy", "She/Her", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_2_pronouns, 1176, 54)
    local runner_3_text = util.create_text_eaves(new_scene, "Regular", "Literally Who?", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_3, 705, 1033)
    local runner_3_pronouns = util.create_text_eaves(new_scene, "Heavy", "Any", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_3_pronouns, 742, 1014)
    local runner_4_text = util.create_text_eaves(new_scene, "Regular", "Nobody", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_4, 1210, 1033)
    local runner_4_pronouns = util.create_text_eaves(new_scene, "Heavy", "Any", 14, util.text_halign.center,
        util.colors.white, util.source_names.runner_4_pronouns, 1183, 1014)
    local runner_1_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_1_finish_time, 705, 70)
    local runner_2_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_2_finish_time, 1210, 70)
    local runner_3_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_3_finish_time, 705, 981)
    local runner_4_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.right,
        util.colors.blue, util.source_names.runner_4_finish_time, 1210, 981)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 800, 882)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 1050, 882)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Myrral", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 800, 935)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "Smartkin", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 1050, 935)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 907, 888)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 1159, 888)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "She/Her", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 907, 941)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 1159, 941)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 58,
        util.text_halign.bottom_center, util.colors.blue, util.source_names.game_name, 960, 345)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 960, 350)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 960, 702)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 960, 608)
    local timer = util.create_timer(new_scene, util.source_names.timer, 831, 445, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_source, runner_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_pr_source, runner_2_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_source, runner_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_pr_source, runner_3_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r4_source, runner_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r4_pr_source, runner_4_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time_source, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time_source, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_time, runner_3_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r3_time_source, runner_3_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r4_time, runner_4_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r4_time_source, runner_4_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_4p_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_4p_4x3_source_def.scene_name, timer, 4,
        { runner_1_time, runner_2_time, runner_3_time, runner_4_time })

    local scene_ctx = util.get_item_ctx(layout_4p_4x3_source_def.id)
    scene_ctx.scene = layout_4p_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[runner_2_text.uuid] = runner_2_text
    scene_ctx.layout_objects[runner_2_pronouns.uuid] = runner_2_pronouns
    scene_ctx.layout_objects[runner_3_text.uuid] = runner_3_text
    scene_ctx.layout_objects[runner_3_pronouns.uuid] = runner_3_pronouns
    scene_ctx.layout_objects[runner_4_text.uuid] = runner_4_text
    scene_ctx.layout_objects[runner_4_pronouns.uuid] = runner_4_pronouns
    scene_ctx.layout_objects[runner_1_time.uuid] = runner_1_time
    scene_ctx.layout_objects[runner_2_time.uuid] = runner_2_time
    scene_ctx.layout_objects[runner_3_time.uuid] = runner_3_time
    scene_ctx.layout_objects[runner_3_time.uuid] = runner_4_time
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    layout_4p_4x3_source_def.hide_commentators(util.get_item_ctx(layout_4p_4x3_source_def.id))
    layout_4p_4x3_source_def.hide_finish_times(util.get_item_ctx(layout_4p_4x3_source_def.id))
    obs.obs_sceneitem_release(layout_item)
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_1p_no_cam_16x9_layout()
    local new_scene = util.create_scene(layout_1p_no_cam_16x9_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 271, 488)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 455, 499)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 120, 652)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 368, 652)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Myrral", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 120, 697)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "Smartkin", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 368, 697)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 224, 657)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 476, 657)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "She/Her", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 224, 702)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 476, 702)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 1502, 885)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 1365, 975)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1638, 975)
    local timer = util.create_timer(new_scene, util.source_names.timer, 702, 900, 250, 70)
    local runner_avatar = util.create_image(new_scene, util.source_names.runner_1_avatar, 115 + 158, 147 + 145, 317, 289)
    local commentators_text = util.create_text_eaves(new_scene, "Regular", "COMMENTATORS", 26, util.text_halign.center,
        util.colors.white, util.source_names.commentators, 276, 607)

    -- Non-cached elements that will be static in the layout
    util.create_text_eaves(new_scene, "Book", "category", 24, util.text_halign.center, util.colors.white,
        util.source_names.category_static, 1365, 1016, obs.S_TRANSFORM_UPPERCASE)
    util.create_text_eaves(new_scene, "Book", "estimate", 24, util.text_halign.center, util.colors.white,
        util.source_names.estimate_static, 1638, 1016, obs.S_TRANSFORM_UPPERCASE)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.comms, commentators_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_avatar_source, runner_avatar.uuid)

    local layout_source = obs.obs_source_create(layout_1p_no_cam_16x9_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_1p_no_cam_16x9_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id)
    scene_ctx.scene = layout_1p_no_cam_16x9_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[commentators_text.uuid] = commentators_text
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer
    scene_ctx.layout_objects[runner_avatar.uuid] = runner_avatar

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    layout_1p_no_cam_16x9_source_def.hide_commentators(util.get_item_ctx(layout_1p_no_cam_16x9_source_def.id))

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_1p_w_cam_16x9_layout()
    local new_scene = util.create_scene(layout_1p_w_cam_16x9_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 271, 488)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 455, 499)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 120, 652)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 368, 652)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Myrral", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 120, 697)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "Smartkin", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 368, 697)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 224, 657)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 476, 657)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "She/Her", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 224, 702)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 476, 702)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 1502, 885)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 1365, 975)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1638, 975)
    local timer = util.create_timer(new_scene, util.source_names.timer, 705, 900, 250, 70)
    local commentators_text = util.create_text_eaves(new_scene, "Regular", "COMMENTATORS", 26, util.text_halign.center,
        util.colors.white, util.source_names.commentators, 276, 607)

    -- Non-cached elements that will be static in the layout
    util.create_text_eaves(new_scene, "Book", "category", 24, util.text_halign.center, util.colors.white,
        util.source_names.category_static, 1365, 1016, obs.S_TRANSFORM_UPPERCASE)
    util.create_text_eaves(new_scene, "Book", "estimate", 24, util.text_halign.center, util.colors.white,
        util.source_names.estimate_static, 1638, 1016, obs.S_TRANSFORM_UPPERCASE)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.comms, commentators_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_1p_w_cam_16x9_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_1p_w_cam_16x9_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_1p_w_cam_16x9_source_def.id)
    scene_ctx.scene = layout_1p_w_cam_16x9_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[commentators_text.uuid] = commentators_text
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    layout_1p_w_cam_16x9_source_def.hide_commentators(util.get_item_ctx(layout_1p_w_cam_16x9_source_def.id))

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_2p_monkey_ball_layout()
    local new_scene = util.create_scene(layout_2p_monkey_ball_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 280, 746)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 469, 759)
    local runner_2_text = util.create_text_eaves(new_scene, "Bold", "Siglemic", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_2, 1607, 747)
    local runner_2_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_2_pronouns, 1792, 759)
    -- local runner_1_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.center,
    --     util.colors.blue, util.source_names.runner_1_finish_time, 283, 806)
    -- local runner_2_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.center,
    --     util.colors.blue, util.source_names.runner_2_finish_time, 1608, 806)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 119, 918)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 371, 918)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 119, 972)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 371, 972)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 223, 924)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 474, 924)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 223, 976)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 474, 976)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 968, 805)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 968, 861)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 826, 928)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1110, 928)
    local timer = util.create_timer(new_scene, util.source_names.timer, 1498, 880, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_source, runner_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_pr_source, runner_2_pronouns.uuid)
    -- obs.obs_data_set_string(layout_data, util.setting_names.r1_time, runner_1_time.uuid)
    -- obs.obs_data_set_string(layout_data, util.setting_names.r1_time_source, runner_1_time.uuid)
    -- obs.obs_data_set_string(layout_data, util.setting_names.r2_time, runner_2_time.uuid)
    -- obs.obs_data_set_string(layout_data, util.setting_names.r2_time_source, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_2p_monkey_ball_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_2p_monkey_ball_source_def.scene_name, timer, 1)
    -- { runner_1_time, runner_2_time })

    local scene_ctx = util.get_item_ctx(layout_2p_monkey_ball_source_def.id)
    scene_ctx.scene = layout_2p_monkey_ball_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[runner_2_text.uuid] = runner_2_text
    scene_ctx.layout_objects[runner_2_pronouns.uuid] = runner_2_pronouns
    -- scene_ctx.layout_objects[runner_1_time.uuid] = runner_1_time
    -- scene_ctx.layout_objects[runner_2_time.uuid] = runner_2_time
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)

    obs.obs_sceneitem_release(layout_item)
    layout_2p_monkey_ball_source_def.hide_commentators(util.get_item_ctx(layout_2p_monkey_ball_source_def.id))
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_2p_tournament_layout()
    local new_scene = util.create_scene(layout_2p_tournament_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1, 280, 746)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_1_pronouns, 469, 759)
    local runner_2_text = util.create_text_eaves(new_scene, "Bold", "Siglemic", 40, util.text_halign.center,
        util.colors.blue, util.source_names.runner_2, 1607, 747)
    local runner_2_pronouns = util.create_text_eaves(new_scene, "Heavy", "He/Him", 18, util.text_halign.center,
        util.colors.white, util.source_names.runner_2_pronouns, 1792, 759)
    local runner_1_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.center,
        util.colors.blue, util.source_names.runner_1_finish_time, 283, 806)
    local runner_2_time = util.create_text_eaves(new_scene, "Heavy", "0:00:00", 32, util.text_halign.center,
        util.colors.blue, util.source_names.runner_2_finish_time, 1608, 806)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 119, 918)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 371, 918)
    local comm_3_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_3, 119, 972)
    local comm_4_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_4, 371, 972)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 223, 924)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 474, 924)
    local comm_3_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_3, 223, 976)
    local comm_4_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_4, 474, 976)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 968, 805)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 968, 861)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 826, 930)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 1110, 930)
    local timer = util.create_timer(new_scene, util.source_names.timer, 1498, 880, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_source, runner_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_pr_source, runner_2_pronouns.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_time_source, runner_1_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_time_source, runner_2_time.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_source, comm_3_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_source, comm_4_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c3_pr_source, comm_3_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c4_pr_source, comm_4_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_2p_tournament_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_2p_tournament_source_def.scene_name, timer, 2,
        { runner_1_time, runner_2_time })

    local scene_ctx = util.get_item_ctx(layout_2p_tournament_source_def.id)
    scene_ctx.scene = layout_2p_tournament_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
    scene_ctx.layout_objects[runner_2_text.uuid] = runner_2_text
    scene_ctx.layout_objects[runner_2_pronouns.uuid] = runner_2_pronouns
    scene_ctx.layout_objects[runner_1_time.uuid] = runner_1_time
    scene_ctx.layout_objects[runner_2_time.uuid] = runner_2_time
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_3_text.uuid] = comm_3_text
    scene_ctx.layout_objects[comm_4_text.uuid] = comm_4_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[comm_3_pr_text.uuid] = comm_3_pr_text
    scene_ctx.layout_objects[comm_4_pr_text.uuid] = comm_4_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)

    obs.obs_sceneitem_release(layout_item)
    layout_2p_tournament_source_def.hide_commentators(util.get_item_ctx(layout_2p_tournament_source_def.id))
    layout_2p_tournament_source_def.hide_finish_times(util.get_item_ctx(layout_2p_tournament_source_def.id))
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_fish_out_water_layout()
    local new_scene = util.create_scene(layout_fish_out_water_source_def.scene_name)

    local timer = util.create_timer(new_scene, util.source_names.timer, 1463, 686, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_fish_out_water_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_fish_out_water_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_relay_race_layout()
    local new_scene = util.create_scene(layout_relay_race_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Bold", "Cosmoing", 26, util.text_halign.center,
        util.colors.yellow, util.source_names.runner_1, 826, 671)
    local runner_2_text = util.create_text_eaves(new_scene, "Bold", "Siglemic", 26, util.text_halign.center,
        util.colors.red, util.source_names.runner_2, 826, 812)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 159, 913)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 401, 913)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 262, 916)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 508, 916)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 189, 784)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.estimate, 438, 784)
    local yellow_team_text = util.create_text_eaves(new_scene, "Bold", "Indecision Gang", 24,
        util.text_halign.bottom_center, util.colors.yellow, util.source_names.yellow_team_name, 742, 810,
        obs.S_TRANSFORM_UPPERCASE)
    local red_team_text = util.create_text_eaves(new_scene, "Bold", "Indecision Gang Too", 24,
        util.text_halign.bottom_center, util.colors.red, util.source_names.red_team_name, 742, 926,
        obs.S_TRANSFORM_UPPERCASE)
    local timer = util.create_timer(new_scene, util.source_names.timer, 188, 970, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r2_source, runner_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.yellow_team_name_source, yellow_team_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.red_team_name_source, red_team_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.category_source, category_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.estimate_source, estimate_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_relay_race_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_relay_race_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_relay_race_source_def.id)
    scene_ctx.scene = layout_relay_race_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_2_text.uuid] = runner_2_text
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[yellow_team_text.uuid] = yellow_team_text
    scene_ctx.layout_objects[red_team_text.uuid] = red_team_text
    scene_ctx.layout_objects[category_text.uuid] = category_text
    scene_ctx.layout_objects[estimate_text.uuid] = estimate_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)

    obs.obs_sceneitem_release(layout_item)
    layout_relay_race_source_def.hide_commentators(util.get_item_ctx(layout_relay_race_source_def.id))
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_kh2_randomizer_layout()
    local new_scene = util.create_scene(layout_kh2_randomizer_source_def.scene_name)
    local comm_1_text = util.create_text_eaves(new_scene, "Regular", "Wolsk", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_1, 120, 1012)
    local comm_2_text = util.create_text_eaves(new_scene, "Regular", "KrakkaCafe", 26, util.text_halign.center,
        util.colors.blue, util.source_names.comm_2, 368, 1012)
    local comm_1_pr_text = util.create_text_eaves(new_scene, "Heavy", "He/Him", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_1, 224, 1018)
    local comm_2_pr_text = util.create_text_eaves(new_scene, "Heavy", "They/Them", 16, util.text_halign.center,
        util.colors.white, util.source_names.comm_pr_2, 476, 1018)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 1502, 885)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local timer = util.create_timer(new_scene, util.source_names.timer, 702, 900, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.c1_source, comm_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_source, comm_2_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c1_pr_source, comm_1_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.c2_pr_source, comm_2_pr_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_kh2_randomizer_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_kh2_randomizer_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_kh2_randomizer_source_def.id)
    scene_ctx.scene = layout_kh2_randomizer_source_def.scene_name
    scene_ctx.layout_objects[comm_1_text.uuid] = comm_1_text
    scene_ctx.layout_objects[comm_2_text.uuid] = comm_2_text
    scene_ctx.layout_objects[comm_1_pr_text.uuid] = comm_1_pr_text
    scene_ctx.layout_objects[comm_2_pr_text.uuid] = comm_2_pr_text
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    layout_kh2_randomizer_source_def.hide_commentators(util.get_item_ctx(layout_kh2_randomizer_source_def.id))

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_lm2_randomizer_layout()
    local new_scene = util.create_scene(layout_lm2_randomizer_source_def.scene_name)
    local game_name_text = util.create_text_eaves(new_scene, "Heavy", "My own video game", 50, util.text_halign.center,
        util.colors.blue, util.source_names.game_name, 1502, 885)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local timer = util.create_timer(new_scene, util.source_names.timer, 702, 911, 250, 70)

    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.game_name_source, game_name_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.created_by_source, created_by_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.timer_source, timer.uuid)

    local layout_source = obs.obs_source_create(layout_lm2_randomizer_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    create_timer_controller(new_scene, layout_lm2_randomizer_source_def.scene_name, timer, 1)

    local scene_ctx = util.get_item_ctx(layout_lm2_randomizer_source_def.id)
    scene_ctx.scene = layout_lm2_randomizer_source_def.scene_name
    scene_ctx.layout_objects[game_name_text.uuid] = game_name_text
    scene_ctx.layout_objects[created_by_text.uuid] = created_by_text
    scene_ctx.layout_objects[timer.uuid] = timer

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)

    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

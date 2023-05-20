-- OBS API: https://obsproject.com/docs/index.html
--
-- To output to OBS script log window use `obs.script_log(obs.LOG_INFO, "Message")`
require("layout_source")
require("util")
local obs = obslua

local description = [[
    <center><h2>Fangame Marathon 2023 Layout Program v1</h2></center>
    <p>
    <center><h3>Program coded by Smartkin</h3></center>
    <center><h3>Layouts designed by Oiivae</h3></center>
    <center><h3>Producer Cosmoing</h3></center>
    <p>
    DO NOT delete any of the layout elements. This WILL break the Dashboard. Other than the scenes you are free to rename them.
    <p>
    After creating the layouts you can add new elements if you need to, but they won't be automated by the Dashboard provided for each scene.
]]

function create_layouts(layout_props, btn_prop)
    obs.script_log(obs.LOG_INFO, "Creating layouts...")
    create_1p_no_cam_4x3_layout()
    create_3p_4x3_layout()
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_button(props, "create_layouts", "Create layouts", create_layouts)
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
        util.colors.blue, util.source_names.game_name, 1502, 885, obs.S_TRANSFORM_STARTCASE)
    local created_by_text = util.create_text_eaves(new_scene, "Regular", "Created by Smartkin", 24,
        util.text_halign.center, util.colors.blue, util.source_names.created_by, 1502, 931)
    local category_text = util.create_text_eaves(new_scene, "Heavy", "Full send%", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 1365, 975)
    local estimate_text = util.create_text_eaves(new_scene, "Heavy", "1:30:00", 24, util.text_halign.center,
        util.colors.white, util.source_names.category, 1638, 975)

    -- Non-cached elements that will be static in the layout
    util.create_text_eaves(new_scene, "Regular", "COMMENTATORS", 26, util.text_halign.center, util.colors.white,
        util.source_names.commentators, 276, 607)
    util.create_text_eaves(new_scene, "Regular", "#FangameMarathon", 41, util.text_halign.center, util.colors.blue,
        util.source_names.hashtag, 276, 1010)
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

    local layout_source = obs.obs_source_create(layout_1p_no_cam_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    local scene_ctx = util.get_layout_ctx(layout_1p_no_cam_4x3_source_def.id)
    scene_ctx.scene = layout_1p_no_cam_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns
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

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_3p_4x3_layout()
    local new_scene = util.create_scene(layout_3p_4x3_source_def.scene_name)
    local runner_1_text = util.create_text_eaves(new_scene, "Regular", "Cosmoing", 32, util.text_halign.left,
        util.colors.blue, util.source_names.runner_1, 705, 20)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "Regular", "He/Him", 18, util.text_halign.left,
        util.colors.white, util.source_names.runner_1_pronouns, 720, 53)
    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text.uuid)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns.uuid)

    local layout_source = obs.obs_source_create(layout_3p_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)

    local scene_ctx = util.get_layout_ctx(layout_3p_4x3_source_def.id)
    scene_ctx.scene = layout_3p_4x3_source_def.scene_name
    scene_ctx.layout_objects[runner_1_text.uuid] = runner_1_text
    scene_ctx.layout_objects[runner_1_pronouns.uuid] = runner_1_pronouns

    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

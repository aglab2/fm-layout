-- OBS API: https://obsproject.com/docs/index.html
--
-- To output to OBS script log window use Lua's `print` function
require("layout_source")
require("util")
local obs = obslua

local description = [[
    <center><h2>Fangame Marathon 2023 Layout Program v1</h2></center>
    <p>
    <center><h3>Program created by Smartkin, Cosmoing, Oiivae</h3></center>
    <p>
    After creating the layouts DO NOT change the name of any elements in the scenes!
    This WILL break the program!
    <p>
    You can, after creating the layouts, add new elements if you need to but they won't be automated by the Dashboard provided for each scene
]]

function create_layouts()
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
    local new_scene = util.create_scene("FM 1 person no cam 4x3 layout")
    local runner_1_text = util.create_text_eaves(new_scene, "Cosmoing", 32, "center", 0xFF5500,
        util.source_names.runner_1, 222, 494)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "He/Him", 18, "left", 0xFFFFFF,
        util.source_names.runner_1_pronouns, 422, 502)
    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns)
    local layout_source = obs.obs_source_create(layout_1p_no_cam_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)
    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

function create_3p_4x3_layout()
    local new_scene = util.create_scene("FM 3 person 4x3 layout")
    local runner_1_text = util.create_text_eaves(new_scene, "Cosmoing", 32, "left", 0xFF5500,
        util.source_names.runner_1, 705, 20)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "He/Him", 18, "left", 0xFFFFFF,
        util.source_names.runner_1_pronouns, 720, 53)
    local layout_data = obs.obs_data_create()
    obs.obs_data_set_string(layout_data, util.setting_names.r1_source, runner_1_text)
    obs.obs_data_set_string(layout_data, util.setting_names.r1_pr_source, runner_1_pronouns)
    local layout_source = obs.obs_source_create(layout_3p_4x3_source_def.id, "Dashboard", layout_data, nil)
    obs.obs_scene_add(new_scene, layout_source)
    local layout_item = obs.obs_scene_sceneitem_from_source(new_scene, layout_source)
    obs.obs_sceneitem_set_order(layout_item, obs.OBS_ORDER_MOVE_BOTTOM)
    obs.obs_sceneitem_release(layout_item)
    obs.obs_data_release(layout_data)
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

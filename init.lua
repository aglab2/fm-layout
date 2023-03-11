-- OBS API: https://obsproject.com/docs/index.html
--
-- To output to OBS script log window use Lua's `print` function
require("layout_source")
require("util")
obs = obslua


local description = [[
    <center><h2>Fangame Marathon 2023 Layout Program v1</h2></center>
    <p>
    <center><h3>Program created by Smartkin, Cosmoing, Oiivae</h3></center>
]]

function create_layouts()
    obs.script_log(obs.LOG_INFO, "Creating layouts...")
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

function create_3p_4x3_layout()
    local new_scene = util.create_scene("FM 3 person 4x3 layout")
    local layout_source = obs.obs_source_create(layout_3p_4x3_source_def.id, "Dashboard", nil, nil)
    --layout_source.text_sources.runner_1_text = runner_1_text
    obs.obs_scene_add(new_scene, layout_source)
    local runner_1_text = util.create_text_eaves(new_scene, "Cosmoing", 32, "left", 0xFF5500, "Runner 1", 705, 20)
    local runner_1_pronouns = util.create_text_eaves(new_scene, "He/Him", 18, "left", 0xFFFFFF, "Runner 1 Pronouns", 720,
        53)
    layout_3p_4x3_settings.text_sources.runner_1_text = runner_1_text
    layout_3p_4x3_settings.text_sources.runner_1_pronouns = runner_1_pronouns
    obs.obs_source_release(layout_source)
    obs.obs_scene_release(new_scene)
end

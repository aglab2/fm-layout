local table_to_string = require("table_to_string")
local obs = obslua

util = {}

util.image_source_load = function(image, file)
    obs.obs_enter_graphics();
    obs.gs_image_file_free(image);
    obs.obs_leave_graphics();

    obs.gs_image_file_init(image, file);

    obs.obs_enter_graphics();
    obs.gs_image_file_init_texture(image);
    obs.obs_leave_graphics();

    if not image.loaded then
        print("failed to load texture " .. file);
    end
end

-- This function returns an OPEN handler for the scene so you have to manually free it
-- using `obs.obs_scene_release`
util.create_scene = function(scene_name)
    local new_scene = obs.obs_scene_create(scene_name)

    return new_scene
end

util.layout_ctx = {}

util.source_names = {
    runner_1 = "Runner 1",
    runner_1_pronouns = "Runner 1 Pronouns",
    runner_2 = "Runner 2",
    runner_2_pronouns = "Runner 2 Pronouns",
    runner_3 = "Runner 3",
    runner_3_pronouns = "Runner 3 Pronouns"
}

util.dashboard_names = {
    r1_name = "Runner 1 name",
    r1_pr = "Runner 1 pronouns",
    r2_name = "Runner 2 name",
    r2_pr = "Runner 2 pronouns",
    r3_name = "Runner 3 name",
    r3_pr = "Runner 3 pronouns",
}

util.setting_names = {
    r1_source = "runner_1_text_source",
    r1_pr_source = "runner_1_pronouns_source",
    r1_name = "runner_1_name",
    r1_pr = "runner_1_pronouns",
    r2_source = "runner_2_text_source",
    r2_pr_source = "runner_2_pronouns_source",
    r2_name = "runner_2_name",
    r2_pr = "runner_2_pronouns",
    r3_source = "runner_3_text_source",
    r3_pr_source = "runner_3_pronouns_source",
    r3_name = "runner_3_name",
    r3_pr = "runner_3_pronouns"
}

-- For color OBS uses BGR so for blue use 0xFF0000 instead of 0x0000FF
util.create_text = function(face, size, style, text, align, color, name, scene, x, y)
    local uuid = nil

    local pos = obs.vec2()

    local text_settings = obs.obs_data_create()
    local text_font_object = obs.obs_data_create_from_json('{}')
    obs.obs_data_set_string(text_font_object, "face", face)
    obs.obs_data_set_int(text_font_object, "flags", 0)
    obs.obs_data_set_int(text_font_object, "size", size)
    obs.obs_data_set_string(text_font_object, "style", style)
    obs.obs_data_set_obj(text_settings, "font", text_font_object)
    obs.obs_data_set_int(text_settings, "color", color)
    obs.obs_data_set_string(text_settings, "text", text)
    obs.obs_data_set_string(text_settings, "align", align)
    local text_source = obs.obs_source_create("text_gdiplus", name, text_settings, nil)
    obs.obs_scene_add(scene, text_source)

    local text_sceneitem = obs.obs_scene_find_source(scene, name)
    local text_location = pos
    if text_sceneitem then
        text_location.x = x
        text_location.y = y
        obs.obs_sceneitem_set_pos(text_sceneitem, text_location)
    end

    uuid = obs.obs_source_get_uuid(text_source)

    obs.obs_source_update(text_source, text_settings)
    obs.obs_data_release(text_settings)
    obs.obs_data_release(text_font_object)
    obs.obs_source_release(text_source)

    return uuid
end

util.create_text_eaves = function(scene, text, size, align, color, name, x, y)
    return util.create_text("MrEavesXLModOT-Reg", size, "Regular", text, align, color, name, scene, x, y)
end

util.set_obs_text_source_text = function(uuid, text)
    local source = obs.obs_get_source_by_uuid(uuid)
    local settings = obs.obs_data_create()
    obs.obs_data_set_string(settings, "text", text)
    obs.obs_source_update(source, settings)
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

util.create_layout_ctx = function(layout_id)
    util.layout_ctx[layout_id] = {
        props_def = nil,
        props_settings = nil,
        source_uuids = {}
    }
    obs.script_log(obs.LOG_INFO, "Created layout context " .. table_to_string.convert(util.layout_ctx[layout_id]))
end

util.get_layout_ctx = function(layout_id)
    return util.layout_ctx[layout_id]
end

obs = obslua
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

util.create_scene = function(scene_name)
    local new_scene = obs.obs_scene_create(scene_name)

    return new_scene
end

-- For color OBS uses BGR so for blue use 0xFF0000 instead of 0x0000FF
util.create_text = function(face, size, style, text, align, color, name, scene, x, y)
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

    obs.obs_source_update(text_source, text_settings)
    obs.obs_data_release(text_settings)
    obs.obs_data_release(text_font_object)
    obs.obs_source_release(text_source)

    return name
end

util.create_text_eaves = function(scene, text, size, align, color, name, x, y)
    return util.create_text("MrEavesXLModOT-Reg", size, "Regular", text, align, color, name, scene, x, y)
end

util.set_obs_text_source_text = function(name, text)
    local source = obs.obs_get_source_by_name(name)
    local settings = obs.obs_data_create()
    obs.obs_data_set_string(settings, "text", text)
    obs.obs_source_update(source, settings)
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

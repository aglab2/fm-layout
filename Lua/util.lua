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
        obs.script_log(obs.LOG_INFO, "Failed to load texture " .. file);
    end
end

util.lerp = function(a, b, t) return a * (1 - t) + b * t end

util.set_item_position = function(sceneitem, item_object)
    local item_location = obs.vec2()
    item_location.x = item_object.x
    item_location.y = item_object.y
    obs.obs_sceneitem_set_pos(sceneitem, item_location)
end

util.add_to_item_position = function(sceneitem, translation)
    local item_location = obs.vec2()
    local sceneitem_pos = obs.vec2()
    obs.obs_sceneitem_get_pos(sceneitem, sceneitem_pos)
    item_location.x = translation.x + sceneitem_pos.x
    item_location.y = translation.y + sceneitem_pos.y
    obs.obs_sceneitem_set_pos(sceneitem, item_location)
end

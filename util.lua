local table_to_string = require("table_to_string")
local obs = obslua
local bit = require("bit")

obs.OBS_ALIGN_CENTER = 0
obs.OBS_ALIGN_LEFT = bit.lshift(1, 0)
obs.OBS_ALIGN_RIGHT = bit.lshift(1, 1)
obs.OBS_ALIGN_TOP = bit.lshift(1, 2)
obs.OBS_ALIGN_BOTTOM = bit.lshift(1, 3)

obs.S_TRANSFORM_NONE = 0
obs.S_TRANSFORM_UPPERCASE = 1
obs.S_TRANSFORM_LOWERCASE = 2
obs.S_TRANSFORM_STARTCASE = 3

util = {}

util.layout_builder_path = "layout-builder-pictures/"

util.layout_ctx = {}

util.text_halign = {
    left = "left",
    center = "center",
    right = "right"
}

util.colors = {
    blue = 0x01CAB8,
    white = 0xFFFFFF
}

util.source_names = {
    game_name = "Game Name",
    created_by = "Created By",
    category = "Category",
    estimate = "Estimate",
    hashtag = "Hashtag",
    category_static = "Category Static",
    estimate_static = "Estimate Static",
    timer = "Timer",
    runner_1 = "Runner 1",
    runner_1_pronouns = "Runner 1 Pronouns",
    runner_2 = "Runner 2",
    runner_2_pronouns = "Runner 2 Pronouns",
    runner_3 = "Runner 3",
    runner_3_pronouns = "Runner 3 Pronouns",
    runner_4 = "Runner 4",
    runner_4_pronouns = "Runner 4 Pronouns",
    commentators = "Commentators",
    comm_1 = "Commentator 1",
    comm_pr_1 = "Commentator 1 pronouns",
    comm_2 = "Commentator 2",
    comm_pr_2 = "Commentator 2 pronouns",
    comm_3 = "Commentator 3",
    comm_pr_3 = "Commentator 3 pronouns",
    comm_4 = "Commentator 4",
    comm_pr_4 = "Commentator 4 pronouns",
}

util.dashboard_names = {
    game_name = "Game Name",
    created_by = "Created By",
    category = "Category",
    estimate = "Estimate",
    r1_name = "Runner 1 name",
    r1_pr = "Runner 1 pronouns",
    r2_name = "Runner 2 name",
    r2_pr = "Runner 2 pronouns",
    r3_name = "Runner 3 name",
    r3_pr = "Runner 3 pronouns",
    r4_name = "Runner 4 name",
    r4_pr = "Runner 4 pronouns",
    comm_amt = "Commentators amount",
    c1_name = "Commentator 1 name",
    c1_pr = "Commentator 1 pronouns",
    c2_name = "Commentator 2 name",
    c2_pr = "Commentator 2 pronouns",
    c3_name = "Commentator 3 name",
    c3_pr = "Commentator 3 pronouns",
    c4_name = "Commentator 4 name",
    c4_pr = "Commentator 4 pronouns",
}

util.setting_names = {
    game_name_source = "game_name_source",
    game_name = "game_name",
    created_by_source = "created_by_source",
    created_by = "created_by",
    category_source = "category_source",
    category = "category",
    estimate_source = "estimate_source",
    estimate = "estimate",
    timer_source = "timer_source",
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
    r3_pr = "runner_3_pronouns",
    r4_source = "runner_4_text_source",
    r4_pr_source = "runner_4_pronouns_source",
    r4_name = "runner_4_name",
    r4_pr = "runner_4_pronouns",
    comm_amt = "comm_amount",
    c1_source = "commentator_1_text_source",
    c1_pr_source = "commentator_1_pronouns_source",
    c1_name = "Commentator 1 name",
    c1_pr = "Commentator 1 pronouns",
    c2_source = "commentator_2_text_source",
    c2_pr_source = "commentator_2_pronouns_source",
    c2_name = "Commentator 2 name",
    c2_pr = "Commentator 2 pronouns",
    c3_source = "commentator_3_text_source",
    c3_pr_source = "commentator_3_pronouns_source",
    c3_name = "Commentator 3 name",
    c3_pr = "Commentator 3 pronouns",
    c4_source = "commentator_4_text_source",
    c4_pr_source = "commentator_4_pronouns_source",
    c4_name = "Commentator 4 name",
    c4_pr = "Commentator 4 pronouns",
}

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

-- Creates a text source on the scene. Returns its unique `UUID` if failes returns `nil`
util.create_text = function(face, size, style, text, align, color, name, scene, x, y, transform)
    if transform == nil then
        transform = obs.S_TRANSFORM_NONE
    end

    local uuid = nil

    -- Equates to `((color & 0xFF0000) >> 16) | (color & 0x00FF00) | ((color & 0xFF) << 16)`
    --
    -- Swizzles color from RGB to BGR
    local bgr_col = bit.bor(bit.bor(bit.rshift(bit.band(color, 0xFF0000), 16), bit.band(color, 0x00FF00)),
        bit.lshift(bit.band(color, 0xFF), 16))

    local text_settings = obs.obs_data_create()
    local text_font_object = obs.obs_data_create_from_json('{}')
    obs.obs_data_set_string(text_font_object, "face", face)
    obs.obs_data_set_int(text_font_object, "flags", 0)
    obs.obs_data_set_int(text_font_object, "size", size)
    obs.obs_data_set_string(text_font_object, "style", style)
    obs.obs_data_set_obj(text_settings, "font", text_font_object)
    obs.obs_data_set_int(text_settings, "color", bgr_col)
    obs.obs_data_set_string(text_settings, "text", text)
    obs.obs_data_set_string(text_settings, "align", align)
    obs.obs_data_set_int(text_settings, "transform", transform)

    local text_source = obs.obs_source_create("text_gdiplus", name, text_settings, nil)
    obs.obs_scene_add(scene, text_source)

    uuid = obs.obs_source_get_uuid(text_source)

    local text_object = {
        uuid = uuid,
        x = x,
        y = y
    }

    local text_sceneitem = obs.obs_scene_sceneitem_from_source(scene, text_source)
    local halign = bit.bor(obs.OBS_ALIGN_LEFT, obs.OBS_ALIGN_TOP)
    if align == util.text_halign.center then
        halign = bit.bor(obs.OBS_ALIGN_CENTER, obs.OBS_ALIGN_TOP)
    elseif align == util.text_halign.right then
        halign = bit.bor(obs.OBS_ALIGN_RIGHT, obs.OBS_ALIGN_TOP)
    end
    if text_sceneitem then
        obs.obs_sceneitem_set_alignment(text_sceneitem, halign)
        util.set_item_position(text_sceneitem, text_object)
    end

    obs.obs_source_update(text_source, text_settings)
    obs.obs_data_release(text_settings)
    obs.obs_data_release(text_font_object)
    obs.obs_source_release(text_source)
    obs.obs_sceneitem_release(text_sceneitem)

    return text_object
end

local style_to_name_map = {
    ["Regular"] = "Reg",
    ["RegularItalic"] = "RegItalic",
    ["Bold"] = "Bold",
    ["BoldItalic"] = "BoldItalic",
    ["Book"] = "Book",
    ["Heavy"] = "Heavy",
    ["HeavyItalic"] = "HeavyItalic",
    ["Light"] = "Light",
    ["LightItalic"] = "LightItalic",
    ["Thin"] = "Thin",
    ["ThinItalic"] = "ThinItalic",
    ["Ultra"] = "Ultra",
    ["UltraItalic"] = "UltraItalic"
}

-- Creates a text source on the scene using `MrEavesXLModOT` font. Returns text object in format `{ uuid = uuid, x = x, y = y }`
util.create_text_eaves = function(scene, style, text, size, align, color, name, x, y, transform)
    return util.create_text("MrEavesXLModOT-" .. style_to_name_map[style], size, "Regular", text, align, color, name,
        scene, x, y, transform)
end

util.set_obs_text_source_text = function(ctx, uuid, text)
    local source = obs.obs_get_source_by_uuid(uuid)
    local settings = obs.obs_data_create()
    -- local text_object = ctx.layout_objects[uuid]
    obs.obs_data_set_string(settings, "text", text)

    obs.obs_source_update(source, settings)
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

local set_sceneitem_visible = function(ctx, uuid, visible)
    local source = obs.obs_get_source_by_uuid(uuid)
    local scene = obs.obs_get_scene_by_name(ctx.scene)
    local sceneitem = obs.obs_scene_sceneitem_from_source(scene, source)
    obs.obs_sceneitem_set_visible(sceneitem, visible)

    obs.obs_source_release(source)
    obs.obs_sceneitem_release(sceneitem)
    obs.obs_scene_release(scene)
end

util.set_item_visible = function(ctx, src_name, visible)
    set_sceneitem_visible(ctx, obs.obs_data_get_string(ctx.props_settings, src_name), visible)
end

util.set_prop_visible = function(ctx, prop_name, visible)
    local prop = obs.obs_properties_get(ctx.props_def, prop_name)
    obs.obs_property_set_visible(prop, visible)
end

util.set_item_position = function(sceneitem, item_object)
    local text_location = obs.vec2()
    text_location.x = item_object.x
    text_location.y = item_object.y
    obs.obs_sceneitem_set_pos(sceneitem, text_location)
end

util.set_obs_text = function(ctx, src_name, setting_name, add_text)
    if add_text == nil then
        add_text = ""
    end

    util.set_obs_text_source_text(ctx, obs.obs_data_get_string(ctx.props_settings, src_name),
        add_text .. obs.obs_data_get_string(ctx.props_settings, setting_name))
end

util.create_timer = function(scene, name, x, y, w, h)
    local uuid = nil

    local timer_settings = obs.obs_data_create()
    obs.obs_data_set_int(timer_settings, "width", w)
    obs.obs_data_set_int(timer_settings, "height", h)
    obs.obs_data_set_string(timer_settings, "layout_path", script_path() .. "livesplit-layouts/default.lsl")

    local timer = obs.obs_source_create("livesplit-one", name, timer_settings, nil)
    obs.obs_scene_add(scene, timer)

    uuid = obs.obs_source_get_uuid(timer)

    local timer_object = {
        uuid = uuid,
        x = x,
        y = y
    }

    local timer_sceneitem = obs.obs_scene_sceneitem_from_source(scene, timer)
    if timer_sceneitem then
        util.set_item_position(timer_sceneitem, timer_object)
    end

    obs.obs_source_update(timer, timer_settings)
    obs.obs_data_release(timer_settings)
    obs.obs_source_release(timer)
    obs.obs_sceneitem_release(timer_sceneitem)

    return timer_object
end

util.create_layout_ctx = function(layout_id)
    util.layout_ctx[layout_id] = {
        props_def = nil,
        props_settings = nil,
        scene = "",
        layout_objects = {}
    }
    obs.script_log(obs.LOG_INFO, "Created layout context " .. table_to_string.convert(util.layout_ctx[layout_id]))
    return util.layout_ctx[layout_id]
end

util.get_layout_ctx = function(layout_id)
    return util.layout_ctx[layout_id]
end

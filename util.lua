-- The classic lazy util module that does a lot of heavy lifting and should have been split into actual
-- proper modules that do their proper stuff but it is what it is and it's too late to go back

local table_to_string = require("table_to_string")
local obs = obslua
local bit = require("bit")

--- Additional imports into obslua that aren't provided by OBS API due to them being macro in OBS's source code

obs.OBS_ALIGN_CENTER = 0
obs.OBS_ALIGN_LEFT = bit.lshift(1, 0)
obs.OBS_ALIGN_RIGHT = bit.lshift(1, 1)
obs.OBS_ALIGN_TOP = bit.lshift(1, 2)
obs.OBS_ALIGN_BOTTOM = bit.lshift(1, 3)

obs.S_TRANSFORM_NONE = 0
obs.S_TRANSFORM_UPPERCASE = 1
obs.S_TRANSFORM_LOWERCASE = 2
obs.S_TRANSFORM_STARTCASE = 3

--- End OBS export

util = {}

util.delayed_update = {} -- Array of delayed updates

-- Binds the function call to an update callback that will be called later
util.bind_update = function(f, ...)
    local args = { ... }
    table.insert(util.delayed_update, function() return f(unpack(args)) end)
end

util.layout_builder_path = "layout-builder-pictures/"
util.layout_templates_path = "layout-templates/"
util.avatars_path = "avatars/"

util.items_ctx = {}

util.text_halign = {
    left = "left",
    center = "center",
    right = "right",
    bottom_center = "bottom_center"
}

util.colors = {
    blue = 0x01CAB8,
    white = 0xFFFFFF,
    red = 0xFF0600,
    yellow = 0xFFDF8C
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
    yellow_team_name = "Yellow team name",
    red_team_name = "Red team name",
    runner_1_avatar = "Runner 1 Avatar",
    runner_1 = "Runner 1",
    runner_1_pronouns = "Runner 1 Pronouns",
    runner_2_avatar = "Runner 2 Avatar",
    runner_2 = "Runner 2",
    runner_2_pronouns = "Runner 2 Pronouns",
    runner_3 = "Runner 3",
    runner_3_pronouns = "Runner 3 Pronouns",
    runner_4 = "Runner 4",
    runner_4_pronouns = "Runner 4 Pronouns",
    runner_1_finish_time = "Runner 1 Finish Time",
    runner_2_finish_time = "Runner 2 Finish Time",
    runner_3_finish_time = "Runner 3 Finish Time",
    runner_4_finish_time = "Runner 4 Finish Time",
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
    runs_list = "Marathon Runs",
    participants_list_1 = "Participant 1",
    participants_list_2 = "Participant 2",
    fill_with_participant = "Fill with participants",
    update_run_info = "Fill run information",
    update_twitch = "Update Twitch title",
    player_1_score = "Player 1 score",
    player_2_score = "Player 2 score",
    start_relay = "Start the Relay Race",
    yellow_team_finish = "Yellow team finished",
    red_team_finish = "Red team finished",
    yellow_team_position = "Yellow team's game",
    red_team_position = "Red team's game",
    yellow_team = "Yellow team name",
    red_team = "Red team name",
    game_name = "Game Name",
    game_width = "Game Width",
    game_height = "Game Height",
    game_x = "Game X",
    game_y = "Game Y",
    created_by = "Created By",
    category = "Category",
    estimate = "Estimate",
    r1_avatar = "Runner 1 avatar",
    r1_name = "Runner 1 name",
    r1_pr = "Runner 1 pronouns",
    r2_avatar = "Runner 2 avatar",
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

util.timer_controller_names = {
    runner = "Runner",
    reset_runner_times = "Reset runner times",
    left_runner = "Set time for left runner",
    right_runner = "Set time for right runner",
    top_left_runner = "Set time for top left runner",
    top_right_runner = "Set time for top right runner",
    bottom_left_runner = "Set time for bottom left runner",
    bottom_right_runner = "Set time for bottom right runner",
    timer_start = "Start",
    timer_finish = "Finish",
    timer_reset = "Reset",
    timer_pause = "Pause",
    timer_continue = "Continue"
}

util.timer_states = {
    stopped = 0,
    running = 1,
    paused = 2,
    finished = 3,
}

util.setting_names = {
    scene = "scene",
    runs_list = "runs_list",
    participants_list_1 = "participants_list_1",
    participants_list_2 = "participants_list_2",
    fill_with_participant = "fill_with_participant",
    update_run_info = "update_run_info",
    update_twitch = "update_twitch",
    player_1_score = "player_1_score",
    player_2_score = "player_2_score",
    start_relay = "start_relay",
    yellow_team_finish = "yellow_team_finish",
    red_team_finish = "red_team_finish",
    yellow_team_position = "yellow_team_position",
    yellow_team_name = "yellow_team_name",
    yellow_team_name_source = "yellow_team_name_source",
    red_team_position = "red_team_position",
    red_team_name = "red_team_name",
    red_team_name_source = "red_team_name_source",
    game_name_source = "game_name_source",
    game_name = "game_name",
    game_width = "game_width",
    game_height = "game_height",
    game_x = "game_x",
    game_y = "game_y",
    created_by_source = "created_by_source",
    created_by = "created_by",
    category_source = "category_source",
    category = "category",
    estimate_source = "estimate_source",
    estimate = "estimate",
    timer_source = "timer_source",
    r1_avatar = "runner_1_avatar",
    r1_avatar_source = "runner_1_avatar_source",
    r1_source = "runner_1_text_source",
    r1_pr_source = "runner_1_pronouns_source",
    r1_name = "runner_1_name",
    r1_pr = "runner_1_pronouns",
    r2_avatar = "runner_2_avatar",
    r2_avatar_source = "runner_2_avatar_source",
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
    r1_time = "runner_1_time",
    r1_time_source = "runner_1_time_source",
    r2_time = "runner_2_time",
    r2_time_source = "runner_2_time_source",
    r3_time = "runner_3_time",
    r3_time_source = "runner_3_time_source",
    r4_time = "runner_4_time",
    r4_time_source = "runner_4_time_source",
    comm_amt = "comm_amount",
    comms = "commentators",
    c1_source = "commentator_1_text_source",
    c1_pr_source = "commentator_1_pronouns_source",
    c1_name = "commentator_1_name",
    c1_pr = "commentator_1_pronouns",
    c2_source = "commentator_2_text_source",
    c2_pr_source = "commentator_2_pronouns_source",
    c2_name = "commentator_2_name",
    c2_pr = "commentator_2_pronouns",
    c3_source = "commentator_3_text_source",
    c3_pr_source = "commentator_3_pronouns_source",
    c3_name = "commentator_3_name",
    c3_pr = "commentator_3_pronouns",
    c4_source = "commentator_4_text_source",
    c4_pr_source = "commentator_4_pronouns_source",
    c4_name = "commentator_4_name",
    c4_pr = "commentator_4_pronouns",
    runner_amt = "runner_amount",
    left_runner = "left_runner",
    right_runner = "right_runner",
    top_left_runner = "top_left_runner",
    top_right_runner = "top_right_runner",
    bottom_left_runner = "bottom_left_runner",
    bottom_right_runner = "bottom_right_runner"
}

util.image_source_load = function(image, file)
    obs.obs_enter_graphics();
    obs.gs_image_file_free(image);
    obs.obs_leave_graphics();

    obs.gs_image_file_init(image, file);

    obs.obs_enter_graphics();
    obs.gs_image_file_init_texture(image);
    obs.obs_leave_graphics();

    -- if not image.loaded then
    --     obs.script_log(obs.LOG_INFO, "Failed to load texture " .. file);
    -- end
end

-- This function returns an OPEN handler for the scene so you have to manually free it
-- using `obs.obs_scene_release`
util.create_scene = function(scene_name)
    local new_scene = obs.obs_scene_create(scene_name)

    return new_scene
end

-- Creates an image source on the scene. Returns table in format `{ uuid = uuid, x = x, y = y }`
util.create_image = function(scene, name, x, y, w, h)
    local uuid = nil

    local image_settings = obs.obs_data_create()
    local image_source = obs.obs_source_create("image_source", name, image_settings, nil)
    obs.obs_scene_add(scene, image_source)

    uuid = obs.obs_source_get_uuid(image_source)

    local image_object = util.create_object(uuid, x, y)
    image_object.width = w
    image_object.height = h

    local image_sceneitem = obs.obs_scene_sceneitem_from_source(scene, image_source)
    if image_sceneitem then
        obs.obs_sceneitem_set_alignment(image_sceneitem, obs.OBS_ALIGN_CENTER)
        util.set_item_position(image_sceneitem, image_object)
        util.set_item_scale(image_sceneitem, 1, 1)
    end

    obs.obs_source_update(image_source, image_settings)
    obs.obs_data_release(image_settings)
    obs.obs_source_release(image_source)
    obs.obs_sceneitem_release(image_sceneitem)

    return image_object
end

-- Creates a text source on the scene. Returns table in format `{ uuid = uuid, x = x, y = y }`
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
    local text_align = align
    if text_align == util.text_halign.bottom_center then
        text_align = util.text_halign.center
    end
    obs.obs_data_set_string(text_settings, "align", text_align)
    obs.obs_data_set_int(text_settings, "transform", transform)

    local text_source = obs.obs_source_create("text_gdiplus", name, text_settings, nil)
    obs.obs_scene_add(scene, text_source)

    uuid = obs.obs_source_get_uuid(text_source)

    local text_object = util.create_object(uuid, x, y)

    local text_sceneitem = obs.obs_scene_sceneitem_from_source(scene, text_source)
    local halign = bit.bor(obs.OBS_ALIGN_LEFT, obs.OBS_ALIGN_TOP)
    if align == util.text_halign.center then
        halign = bit.bor(obs.OBS_ALIGN_CENTER, obs.OBS_ALIGN_TOP)
    elseif align == util.text_halign.right then
        halign = bit.bor(obs.OBS_ALIGN_RIGHT, obs.OBS_ALIGN_TOP)
    elseif align == util.text_halign.bottom_center then
        halign = bit.bor(obs.OBS_ALIGN_BOTTOM, obs.OBS_ALIGN_CENTER)
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

-- Creates a text source on the scene using `MrEavesXLModOT` font. Returns table in format `{ uuid = uuid, x = x, y = y }`
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

util.set_obs_text = function(ctx, src_name, setting_name, add_text)
    if add_text == nil then
        add_text = ""
    end

    util.set_obs_text_source_text(ctx, obs.obs_data_get_string(ctx.props_settings, src_name),
        add_text .. obs.obs_data_get_string(ctx.props_settings, setting_name))
end

util.set_obs_text_no_source = function(ctx, src_name, text)
    util.set_obs_text_source_text(ctx, obs.obs_data_get_string(ctx.props_settings, src_name), text)
end

util.set_obs_position = function(ctx, src_name, position)
    local source = obs.obs_get_source_by_uuid(obs.obs_data_get_string(ctx.props_settings, src_name))
    local scene = obs.obs_get_scene_by_name(ctx.scene)
    local sceneitem = obs.obs_scene_sceneitem_from_source(scene, source)
    util.set_item_position(sceneitem, {
        x = position.x,
        y = position.y
    })

    obs.obs_source_release(source)
    obs.obs_sceneitem_release(sceneitem)
    obs.obs_scene_release(scene)
end

util.lerp = function(a, b, t) return a * (1 - t) + b * t end

util.update_image_scale = function(ctx, src_name)
    local uuid = obs.obs_data_get_string(ctx.props_settings, src_name)
    local source = obs.obs_get_source_by_uuid(uuid)
    local scene = obs.obs_get_scene_by_name(ctx.scene)
    local sceneitem = obs.obs_scene_sceneitem_from_source(scene, source)

    if sceneitem and ctx then
        local frame_width = ctx.layout_objects[uuid].width
        local frame_height = ctx.layout_objects[uuid].height
        local image_width = obs.obs_source_get_width(source)
        local image_height = obs.obs_source_get_height(source)
        local image_fit_value = math.max(image_width, image_height)
        local scale_x = 1
        local scale_y = 1
        if (image_width ~= 0) and (image_height ~= 0) then
            scale_x = frame_width / image_fit_value
            scale_y = frame_height / image_fit_value
        end
        util.set_item_scale(sceneitem, scale_x, scale_y)
    end

    obs.obs_source_release(source)
    obs.obs_sceneitem_release(sceneitem)
    obs.obs_scene_release(scene)
end

util.set_obs_image_path = function(ctx, src_name, setting_name)
    local uuid = obs.obs_data_get_string(ctx.props_settings, src_name)
    local source = obs.obs_get_source_by_uuid(uuid)
    local settings = obs.obs_data_create()
    local image_path = obs.obs_data_get_string(ctx.props_settings, setting_name)
    obs.obs_data_set_string(settings, "file", image_path)
    obs.obs_source_update(source, settings)

    if image_path ~= "" then
        -- After updating the source OBS doesn't update image's height and width instantly so we have to update the scale on OBS's next render frame
        util.bind_update(util.update_image_scale, ctx, src_name)
    end

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

util.set_prop_text = function(ctx, prop_name, text)
    obs.obs_data_set_string(ctx.props_settings, prop_name, text)
end

util.set_item_position = function(sceneitem, item_object)
    local item_location = obs.vec2()
    item_location.x = item_object.x
    item_location.y = item_object.y
    obs.obs_sceneitem_set_pos(sceneitem, item_location)
end

util.set_item_scale = function(sceneitem, x, y)
    local scale = obs.vec2()
    scale.x = x
    scale.y = y
    obs.obs_sceneitem_set_scale(sceneitem, scale)
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

    local timer_object = util.create_object(uuid, x, y)

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

util.file_exists = function(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

util.commentators_info = function(ctx, comm_amt)
    local result_array = {}
    local result = {}

    result[util.setting_names.c1_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
        util.setting_names.c1_name)) ~= 0
    result[util.setting_names.c1_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
        util.setting_names.c1_pr)) ~= 0
    if comm_amt == 2 then
        result[util.setting_names.c2_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c2_name)) ~= 0
        result[util.setting_names.c2_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c2_pr)) ~= 0
    elseif comm_amt == 3 then
        result[util.setting_names.c2_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c2_name)) ~= 0
        result[util.setting_names.c3_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c3_name)) ~= 0
        result[util.setting_names.c2_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c2_pr)) ~= 0
        result[util.setting_names.c3_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c3_pr)) ~= 0
    elseif comm_amt == 4 then
        result[util.setting_names.c2_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c2_name)) ~= 0
        result[util.setting_names.c3_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c3_name)) ~= 0
        result[util.setting_names.c4_name] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c4_name)) ~= 0
        result[util.setting_names.c2_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c2_pr)) ~= 0
        result[util.setting_names.c3_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c3_pr)) ~= 0
        result[util.setting_names.c4_pr] = string.len(obs.obs_data_get_string(ctx.props_settings,
            util.setting_names.c4_pr)) ~= 0
    end

    for i = 1, comm_amt do
        local flag_table = {
            has_name = false,
            has_prs = false
        }
        if i == 1 then
            flag_table.has_name = result[util.setting_names.c1_name]
            flag_table.has_prs = result[util.setting_names.c1_pr]
        end
        if i == 2 then
            flag_table.has_name = result[util.setting_names.c2_name]
            flag_table.has_prs = result[util.setting_names.c2_pr]
        end
        if i == 3 then
            flag_table.has_name = result[util.setting_names.c3_name]
            flag_table.has_prs = result[util.setting_names.c3_pr]
        end
        if i == 4 then
            flag_table.has_name = result[util.setting_names.c4_name]
            flag_table.has_prs = result[util.setting_names.c4_pr]
        end

        table.insert(result_array, flag_table)
    end

    return result_array
end

util.fit_screen = function(source_width, source_height, target_width, target_height)
    local ratio = source_height / source_width
    local new_width = target_height / ratio
    local new_height

    if new_width > target_width then
        new_width = target_width
        new_height = new_width * ratio
    else
        new_height = target_height
    end

    local x = math.floor((target_width - new_width) / 2)
    local y = math.floor((target_height - new_height) / 2)

    return x, y, math.floor(new_width), math.floor(new_height)
end

util.create_object = function(uuid, x, y)
    return {
        uuid = uuid,
        x = x,
        y = y,
    }
end

util.create_item_ctx = function(item_id)
    util.items_ctx[item_id] = mergeTables({
        props_def = nil,
        props_settings = nil,
        scene = "",
        layout_objects = {},
        state = nil
    }, util.items_ctx[item_id] or {})
    return util.items_ctx[item_id]
end

util.get_item_ctx = function(item_id)
    return util.items_ctx[item_id]
end

util.copy_exclude = function(obj, seen, excluded_keys)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do
        if excluded_keys[k] == nil then
            res[util.copy_exclude(k, s, excluded_keys)] = util.copy_exclude(v, s, excluded_keys)
        end
    end
    return res
end

function mergeTables(table1, table2)
    local mergedTable = {}

    for k, v in pairs(table1) do
        if type(v) == 'table' and type(table2[k]) == 'table' then
            mergedTable[k] = mergeTables(v, table2[k])
        else
            mergedTable[k] = v
        end
    end

    for k, v in pairs(table2) do
        if type(v) == 'table' and type(table1[k]) == 'table' then
            mergedTable[k] = mergeTables(table1[k], v)
        else
            mergedTable[k] = v
        end
    end

    return mergedTable
end

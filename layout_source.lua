-- obs = obslua
-- bit = require("bit")

-- source_def = {}
-- source_def.id = "fm_layout"
-- source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW), obs.OBS_SOURCE_CAP_DISABLED)
-- source_def.icon_type = obs.OBS_ICON_TYPE_IMAGE

-- function image_source_load(image, file)
--     obs.obs_enter_graphics();
--     obs.gs_image_file_free(image);
--     obs.obs_leave_graphics();

--     obs.gs_image_file_init(image, file);

--     obs.obs_enter_graphics();
--     obs.gs_image_file_init_texture(image);
--     obs.obs_leave_graphics();

--     if not image.loaded then
--         print("failed to load texture " .. file);
--     end
-- end

-- source_def.get_name = function()
--     return "FM2023 Layout"
-- end

-- source_def.create = function(settings, source)
--     local data = {}
--     data.layout = obs.gs_image_file()

--     image_source_load(data.layout, script_path() .. settings.layout_path)

--     return data
-- end

-- source_def.destroy = function(data)
--     obs.obs_enter_graphics()
--     obs.gs_image_file_free(data.layout)
--     obs.obs_leave_graphics()
-- end

-- source_def.video_render = function(data, effect)
--     if not data.image.texture then
--         return
--     end

--     effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

--     obs.gs_blend_state_push()
--     obs.gs_reset_blend_state()

--     while obs.gs_effect_loop(effect, "Draw") do
--         obs.obs_source_draw(data.layout.texture, 0, 0, data.layout.cx, data.layout.cy, false)
--     end

--     obs.gs_matrix_pop()
--     obs.gs_blend_state_pop()
-- end

-- source_def.get_width = function(data)
--     return 1920
-- end

-- source_def.get_height = function(data)
--     return 1080
-- end

-- obs.obs_register_source(source_def)
require("util")

local obs = obslua
local bit = require("bit")

local ctx = {
    props_def = nil,
    props_settings = nil
}

layout_3p_4x3_settings = {}
layout_3p_4x3_settings.text_sources = {
    runner_1_text = nil,
    runner_1_pronouns = nil
}

layout_3p_4x3_source_def = {}
layout_3p_4x3_source_def.id = "fm_2023_3_person_4x3"
layout_3p_4x3_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

function image_source_load(image, file)
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

layout_3p_4x3_source_def.get_name = function()
    return "FM 4x3 3 person layout"
end

layout_3p_4x3_source_def.create = function(settings, source)
    local data = {}
    data.layout_template = obs.gs_image_file()
    data.text_sources = {
        runner_1_text = nil
    }
    obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))
    image_source_load(data.layout_template, script_path() .. "layout-templates/3_person_4x3.png")

    return data
end

layout_3p_4x3_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, "runner_1_name", "Runner 1")
    obs.obs_data_set_default_string(settings, "runner_1_pronouns", "They/Them")
    obs.obs_data_set_default_string(settings, "runner_2_name", "Runner 2")
    obs.obs_data_set_default_string(settings, "runner_2_pronouns", "They/Them")
    obs.obs_data_set_default_string(settings, "runner_3_name", "Runner 3")
    obs.obs_data_set_default_string(settings, "runner_3_pronouns", "They/Them")
end

layout_3p_4x3_source_def.get_properties = function(data)
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, "runner_1_name", "Runner name 1",
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, "runner_1_pronouns", "Runner 1 pronouns",
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, "runner_2_name", "Runner name 2",
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, "runner_2_pronouns", "Runner 2 pronouns",
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, "runner_3_name", "Runner name 3",
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, "runner_3_pronouns", "Runner 3 pronouns",
        obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)
    return ctx.props_def
end

layout_3p_4x3_source_def.update = function(data, settings)
    ctx.props_settings = settings

    if layout_3p_4x3_settings.text_sources.runner_1_text ~= nil then
        util.set_obs_text_source_text(layout_3p_4x3_settings.text_sources.runner_1_text,
            obs.obs_data_get_string(ctx.props_settings, "runner_1_name"))
        util.set_obs_text_source_text(layout_3p_4x3_settings.text_sources.runner_1_pronouns,
            obs.obs_data_get_string(ctx.props_settings, "runner_1_pronouns"))
    end
end

layout_3p_4x3_source_def.destroy = function(data)
    obs.obs_enter_graphics();
    obs.gs_image_file_free(data.layout_template);
    obs.obs_leave_graphics();
end

layout_3p_4x3_source_def.video_render = function(data, effect)
    if not data.layout_template.texture then
        return;
    end

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.layout_template.texture, 0, 0, 1920, 1080, false);
    end

    obs.gs_matrix_pop()

    obs.gs_blend_state_pop()
end

layout_3p_4x3_source_def.get_width = function(data)
    return 1920
end

layout_3p_4x3_source_def.get_height = function(data)
    return 1080
end


obs.obs_register_source(layout_3p_4x3_source_def)

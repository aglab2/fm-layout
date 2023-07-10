require("util")

local obs = obslua
local bit = require("bit")

layout_lm2_randomizer_source_def = {}
layout_lm2_randomizer_source_def.scene_name = "FM La-Mulana 2 randomizer layout"
layout_lm2_randomizer_source_def.id = "fm_2023_lm2_randomizer"
layout_lm2_randomizer_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_lm2_randomizer_source_def.get_name = function()
    return "FM La-Mulana 2 randomizer"
end

layout_lm2_randomizer_source_def.create = function(settings, source)
    local data = {}
    local ctx = util.create_item_ctx(layout_lm2_randomizer_source_def.id)
    ctx.scene = layout_lm2_randomizer_source_def.scene_name

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    ctx.props_settings = settings

    data.background = obs.gs_image_file()

    local template_path = script_path() .. util.layout_templates_path
    util.image_source_load(data.background, template_path .. "lm2_randomizer.png")

    return data
end

layout_lm2_randomizer_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, util.setting_names.game_name, "i wanna be the guy")
    obs.obs_data_set_default_string(settings, util.setting_names.created_by, "Kayin")
end

layout_lm2_randomizer_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_lm2_randomizer_source_def.id)
    ctx.props_def = obs.obs_properties_create()
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.game_name, util.dashboard_names.game_name,
        obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(ctx.props_def, util.setting_names.created_by, util.dashboard_names.created_by,
        obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_lm2_randomizer_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_lm2_randomizer_source_def.id)
    ctx.props_settings = settings

    util.set_obs_text(ctx, util.setting_names.game_name_source, util.setting_names.game_name)
    util.set_obs_text(ctx, util.setting_names.created_by_source, util.setting_names.created_by, "Created by ")
end

layout_lm2_randomizer_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.obs_leave_graphics()
end

layout_lm2_randomizer_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false)
    end

    obs.gs_matrix_pop()
    obs.gs_blend_state_pop()
end

layout_lm2_randomizer_source_def.get_width = function(data)
    return 1920
end

layout_lm2_randomizer_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_lm2_randomizer_source_def)

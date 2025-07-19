require("util")

local obs = obslua
local bit = require("bit")


layout_fish_out_water_source_def = {}
layout_fish_out_water_source_def.scene_name = "FM fish out of water layout"
layout_fish_out_water_source_def.id = "fm_2023_fish_out_water"
layout_fish_out_water_source_def.output_flags = bit.bor(bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW),
    obs.OBS_SOURCE_CAP_DISABLED)

layout_fish_out_water_source_def.get_name = function()
    return "FM fish out of water layout"
end

layout_fish_out_water_source_def.create = function(settings, source)
    local data = {}
    data.background = obs.gs_image_file()
    data.wolfie_special = obs.gs_image_file()

    local ctx = util.create_item_ctx(layout_fish_out_water_source_def.id)
    ctx.scene = layout_fish_out_water_source_def.scene_name

    ctx.props_settings = settings

    -- obs.script_log(obs.LOG_INFO, obs.obs_data_get_json(settings))

    local template_path = script_path() .. util.layout_templates_path
    local img_path = script_path() .. util.layout_builder_path
    util.image_source_load(data.background, template_path .. "fishout_of_water.png")
    util.image_source_load(data.wolfie_special, img_path .. "fish_out_of_water_swap.png")

    return data
end

layout_fish_out_water_source_def.get_defaults = function(settings)
end


layout_fish_out_water_source_def.get_properties = function(data)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    ctx.scene = layout_fish_out_water_source_def.scene_name
    ctx.props_def = obs.obs_properties_create()

    obs.obs_properties_apply_settings(ctx.props_def, ctx.props_settings)

    return ctx.props_def
end

layout_fish_out_water_source_def.update = function(data, settings)
    local ctx = util.get_item_ctx(layout_fish_out_water_source_def.id)
    ctx.props_settings = settings
end

layout_fish_out_water_source_def.destroy = function(data)
    obs.obs_enter_graphics()
    obs.gs_image_file_free(data.background)
    obs.gs_image_file_free(data.wolfie_special)
    obs.obs_leave_graphics()
end

layout_fish_out_water_source_def.video_render = function(data, effect)
    if not data.background.texture then
        return;
    end

    effect = obs.obs_get_base_effect(obs.OBS_EFFECT_DEFAULT)

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    -- TODO: Fish out of water specific images
    while obs.gs_effect_loop(effect, "Draw") do
        obs.obs_source_draw(data.background.texture, 0, 0, 1920, 1080, false);
        obs.obs_source_draw(data.wolfie_special.texture, 55, 570, 578, 452, false);
    end

    obs.gs_blend_state_pop()
end

layout_fish_out_water_source_def.get_width = function(data)
    return 1920
end

layout_fish_out_water_source_def.get_height = function(data)
    return 1080
end

obs.obs_register_source(layout_fish_out_water_source_def)

require("util")

scriptContext = {}

local obs = obslua
local bit = require("bit")

local function UpdateTextPositions()
    for _, value in pairs(scriptContext) do
        if value.allowUpdates and value.textSourceName ~= nil and value.sceneName ~= nil and value.textSourceName ~= "" and value.sceneName ~= "" and value.deltaPosition.move.x ~= 0 then
            local associatedTextSourceName = value.textSourceName
            local source = obs.obs_get_source_by_name(associatedTextSourceName)
            local scene = obs.obs_get_scene_by_name(value.sceneName)
            local sceneitem = obs.obs_scene_sceneitem_from_source(scene, source)
            util.add_to_item_position(sceneitem, {
                x = value.deltaPosition.move.x,
                y = value.deltaPosition.move.y
            })
            obs.obs_source_release(source)
            obs.obs_sceneitem_release(sceneitem)
            obs.obs_scene_release(scene)
        end
    end
end

function script_tick()
    UpdateTextPositions()
end

function script_load(settings)
    obs.obs_register_source(relay_race_renderer_source_def)
end

function script_description()
    return "This adds a new source to render the sprites for the relay race layout :)"
end

local function FreeImages(data)
    obs.obs_enter_graphics()

    if data.imageStorage ~= nil then
        for _, v in pairs(data.imageStorage) do
            local frames = v.frames
            for i = 1, frames do
                obs.gs_image_file_free(v.images[i])
            end
        end
    end

    obs.obs_leave_graphics()
end

relay_race_renderer_source_def = {}
relay_race_renderer_source_def.id = "fm_relay_race_renderer"
relay_race_renderer_source_def.output_flags = bit.bor(obs.OBS_SOURCE_VIDEO, obs.OBS_SOURCE_CUSTOM_DRAW)

relay_race_renderer_source_def.get_name = function()
    return "FM Relay Race Player Renderer"
end

local function parseReceivedData(data, settings)
    local loadImages = obs.obs_data_get_bool(settings, "loadImages")
    if loadImages then
        local reloadImages = obs.obs_data_get_bool(settings, "reloadImages")
        if reloadImages then
            FreeImages(data)
        end
        obs.obs_data_set_bool(settings, "reloadImages", false)

        data.imageStorage = {}
        local images = obs.obs_data_get_array(settings, "images")
        local imagesAmount = obs.obs_data_array_count(images)
        for index = 0, imagesAmount - 1 do
            local imageObj = obs.obs_data_array_item(images, index)
            local framesAmount = obs.obs_data_get_int(imageObj, "frames")
            local filePath = obs.obs_data_get_string(imageObj, "file")
            local imageName = obs.obs_data_get_string(imageObj, "name")
            local animationSpeed = obs.obs_data_get_int(imageObj, "animationSpeed")

            data.imageStorage[imageName] = {}
            data.imageStorage[imageName].currentFrame = 1
            data.imageStorage[imageName].animationSpeed = animationSpeed
            data.imageStorage[imageName].frames = framesAmount
            data.imageStorage[imageName].images = {}
            for i = 1, framesAmount do
                table.insert(data.imageStorage[imageName].images, obs.gs_image_file())
                util.image_source_load(data.imageStorage[imageName].images[i], filePath .. tostring(i) .. ".png")
            end

            obs.obs_data_release(imageObj)
        end

        obs.obs_data_array_release(images)

        data.loadedImages = true
    end
    obs.obs_data_set_bool(settings, "loadImages", false)

    if data.initialPosition == nil then
        data.initialPosition = {}
        data.initialPosition.x = 0
        data.initialPosition.y = 0
    end

    if data.currentPosition == nil then
        data.currentPosition = {}
        data.currentPosition.x = 0
        data.currentPosition.y = 0
    end

    if data.nextPosition == nil then
        data.nextPosition = {}
        data.nextPosition.x = 0
        data.nextPosition.y = 0
    end

    if data.deltaPosition == nil then
        data.deltaPosition = {}
        data.deltaPosition.x = 0
        data.deltaPosition.y = 0
        data.deltaPosition.move = {}
        data.deltaPosition.move.x = 0
        data.deltaPosition.move.y = 0
        data.deltaPosition.time = 0
        data.deltaPosition.duration = 1
    end

    data.sceneName = obs.obs_data_get_string(settings, "sceneName")
    data.textSourceName = obs.obs_data_get_string(settings, "textSourceName")
    data.currentImage = obs.obs_data_get_string(settings, "currentImage")

    local setInitialPosition = obs.obs_data_get_bool(settings, "setInitialPosition")
    if setInitialPosition then
        local position = obs.obs_data_get_obj(settings, "initialPosition")
        data.initialPosition.x = obs.obs_data_get_double(position, "x")
        data.initialPosition.y = obs.obs_data_get_double(position, "y")
        data.nextPosition.x = data.initialPosition.x
        data.nextPosition.y = data.initialPosition.y
        obs.obs_data_release(position)
    end
    obs.obs_data_set_bool(settings, "setInitialPosition", false)

    local setToInitialPosition = obs.obs_data_get_bool(settings, "setToInitialPosition")
    if setToInitialPosition then
        data.currentPosition.x = data.initialPosition.x
        data.currentPosition.y = data.initialPosition.y
    end
    obs.obs_data_set_bool(settings, "setToInitialPosition", false)

    data.idleImage = obs.obs_data_get_string(settings, "idleImage")
    data.runImage = obs.obs_data_get_string(settings, "runImage")

    local goToNextPosition = obs.obs_data_get_bool(settings, "goToNextPosition")
    if goToNextPosition then
        local nextPosition = obs.obs_data_get_obj(settings, "nextPosition")
        data.nextPosition.x = obs.obs_data_get_double(nextPosition, "x")
        data.nextPosition.y = obs.obs_data_get_double(nextPosition, "y")

        data.deltaPosition.time = 0
        data.deltaPosition.x = data.nextPosition.x - data.currentPosition.x
        data.deltaPosition.y = data.nextPosition.y - data.currentPosition.y
        data.deltaPosition.duration = obs.obs_data_get_double(nextPosition, "duration")
    end
    obs.obs_data_set_bool(settings, "goToNextPosition", false)

    local setCurrentImage = obs.obs_data_get_bool(settings, "setCurrentImage")
    if setCurrentImage then
        data.currentImage = obs.obs_data_get_string(settings, "currentImage")
    end
    obs.obs_data_set_bool(settings, "setCurrentImage", false)

    return data
end

relay_race_renderer_source_def.create = function(settings, source)
    local data = {}
    scriptContext[source] = data

    data.allowUpdates = obs.obs_data_get_bool(settings, "allowUpdates")
    data.source = source
    data.last_render_clock = os.clock()

    if data.effect == nil then
        obs.obs_enter_graphics()
        data.effect = obs.gs_effect_create(shader, nil, nil)
        if data.effect ~= nil then
            data.params = {}
            data.params.flipH = obs.gs_effect_get_param_by_name(data.effect, "flipH")
        end
        obs.obs_leave_graphics()
    end


    data = parseReceivedData(data, settings)

    return data
end

relay_race_renderer_source_def.get_defaults = function(settings)
    obs.obs_data_set_default_string(settings, "currentImage", "")
    obs.obs_data_set_default_string(settings, "idleImage", "")
    obs.obs_data_set_default_string(settings, "runImage", "")
    obs.obs_data_set_default_string(settings, "textSourceName", "")
    obs.obs_data_set_default_string(settings, "sceneName", "")
    obs.obs_data_set_default_bool(settings, "websocketUpdate", false)
    obs.obs_data_set_default_bool(settings, "setInitialPosition", false)
    obs.obs_data_set_default_bool(settings, "loadImages", false)
    obs.obs_data_set_default_bool(settings, "reloadImages", false)
    obs.obs_data_set_default_array(settings, "images", obs.obs_data_array_create())
    obs.obs_data_set_default_bool(settings, "setToInitialPosition", false)
    obs.obs_data_set_default_bool(settings, "goToNextPosition", false)
    obs.obs_data_set_default_bool(settings, "allowUpdates", false)
end

relay_race_renderer_source_def.update = function(data, settings)
    data.allowUpdates = obs.obs_data_get_bool(settings, "allowUpdates")

    if data.effect == nil then
        obs.obs_enter_graphics()
        data.effect = obs.gs_effect_create(shader, nil, nil)
        if data.effect ~= nil then
            data.params = {}
            data.params.flipH = obs.gs_effect_get_param_by_name(data.effect, "flipH")
        end
        obs.obs_leave_graphics()
    end

    local websocketUpdate = obs.obs_data_get_bool(settings, "websocketUpdate")
    if not websocketUpdate then
        return
    end
    obs.obs_data_set_bool(settings, "websocketUpdate", false)

    parseReceivedData(data, settings)
end

relay_race_renderer_source_def.destroy = function(data)
    FreeImages(data)

    if data.effect ~= nil then
        obs.obs_enter_graphics()
        obs.gs_effect_destroy(data.effect)
        obs.obs_leave_graphics()
    end

    data.loadImages = true
end

relay_race_renderer_source_def.video_render = function(data, effect)
    if not data.loadedImages or data.currentImage == "" or data.effect == nil then
        return
    end

    local delta = os.clock() - data.last_render_clock

    effect = data.effect

    obs.gs_effect_set_bool(data.params.flipH, (data.deltaPosition.x < 0))

    obs.gs_blend_state_push()
    obs.gs_reset_blend_state()

    while obs.gs_effect_loop(effect, "Draw") do
        local currentAnimation = data.currentImage
        local framesAmount = data.imageStorage[currentAnimation].frames
        local animationSpeed = data.imageStorage[currentAnimation].animationSpeed * delta
        local frameData = data.imageStorage[currentAnimation].images

        data.imageStorage[currentAnimation].currentFrame =
            data.imageStorage[currentAnimation].currentFrame + animationSpeed
        if data.imageStorage[currentAnimation].currentFrame >= framesAmount + 1 then
            data.imageStorage[currentAnimation].currentFrame = 1
        end

        local imageTexture = frameData[math.floor(data.imageStorage[currentAnimation].currentFrame)].texture
        if data.allowUpdates then
            local dt = delta
            if data.deltaPosition.time + dt >= data.deltaPosition.duration then
                dt = data.deltaPosition.duration - data.deltaPosition.time
            end

            local moveX = data.deltaPosition.x * (dt / data.deltaPosition.duration)
            local moveY = data.deltaPosition.y * (dt / data.deltaPosition.duration)

            data.currentPosition.x = data.currentPosition.x + moveX
            data.currentPosition.y = data.currentPosition.y + moveY
            data.deltaPosition.move.x = moveX
            data.deltaPosition.move.y = moveY

            data.deltaPosition.time = data.deltaPosition.time + dt
            if data.deltaPosition.time >= data.deltaPosition.duration then
                data.deltaPosition.x = 0
                data.deltaPosition.y = 0
            end
        end

        obs.obs_source_draw(imageTexture, data.currentPosition.x, data.currentPosition.y, 72, 63,
            false)
    end

    obs.gs_blend_state_pop()

    data.last_render_clock = os.clock()
end

relay_race_renderer_source_def.get_width = function(data)
    return 1920
end

relay_race_renderer_source_def.get_height = function(data)
    return 1080
end


shader = [[
uniform float4x4 ViewProj;
uniform texture2d image;
uniform bool flipH = false;

sampler_state def_sampler {
	Filter   = Point;
	AddressU = Mirror;
	AddressV = Clamp;
};

struct VertInOut {
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;
};

VertInOut VSDefault(VertInOut vert_in)
{
	VertInOut vert_out;
	vert_out.pos = mul(float4(vert_in.pos.xyz, 1.0), ViewProj);
	vert_out.uv  = vert_in.uv;
	return vert_out;
}

float4 PSDrawBare(VertInOut vert_in) : TARGET
{
    float2 resultUv = vert_in.uv;
    if (flipH)
    {
        resultUv.x = 1.0 - resultUv.x;
    }
	return image.Sample(def_sampler, resultUv);
}

technique Draw
{
	pass
	{
		vertex_shader = VSDefault(vert_in);
		pixel_shader  = PSDrawBare(vert_in);
	}
}

]]

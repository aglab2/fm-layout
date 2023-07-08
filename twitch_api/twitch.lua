-- Provides access to Twitch API to change marathon channel's information
local json = require("cjson")
local network = require("network")
local url_lib = require("socket.url")
local socket = require("socket")

twitch = {
    initialized = false,
    client_secret = "",
    client_id = "",
    redirect_url = "",
    redirect_port = -1,
    token = "",
    refresh_token = "",
    token_type = "",
    games_database = {},
    marathon_id = -1,
    auth_listener = nil,
    accept_token_routine = nil,
    auth_code = ""
}

local API = "https://api.twitch.tv/helix/"

local end_points = {
    users = "users",
    channels = "channels",
    games = "games"
}

local function get_client_params()
    return "client_id=" .. twitch.client_id .. "&client_secret=" .. twitch.client_secret
end

local function get_grant(grant_type)
    return "grant_type=" .. grant_type
end

local function get_scope()
    return "scope=channel%3Amanage%3Abroadcast"
end

local function build_twitch_params(grant_type)
    return get_client_params() ..
        "&" ..
        get_grant(grant_type) ..
        "&" ..
        get_scope() ..
        "&code=" .. twitch.auth_code ..
        "&redirect_uri=" .. twitch.redirect_url .. ":" .. twitch.redirect_port .. "/"
end

local function get_auth_header()
    return "Bearer " .. twitch.token
end

--- Safety function that attempts to request a Twitch's API and if authorization fails refreshes the token and reattempts the request
---@param request function
---@param url string
---@param headers table
---@param postparams? string
---@return string, integer
local function check_request(request, url, headers, postparams)
    local body, code = network.perform(request, url, headers, postparams)

    if code == 401 then
        twitch.get_refresh_token()

        local h = {
            ["Authorization"] = get_auth_header(),
            ["Client-Id"] = twitch.client_id
        }
        headers["Authorization"] = h["Authorization"]
        headers["Client-Id"] = h["Client-Id"]

        body, code = network.perform(request, url, headers, postparams)
        assert(code == 200, "Failed to refresh the AUTH token " .. body)
    end

    return body, code
end

local function append_param(params, param_name, new_param)
    return params .. "&" .. param_name .. "=" .. new_param
end

twitch.init = function()
    local twitch_credentials = assert(io.open(script_path() .. "/credentials.secret", "r"), "Credentials file not found!")
    local json_data = twitch_credentials:read("*a")
    local decoded_info = json.decode(json_data)
    twitch.client_secret = decoded_info.secret
    twitch.client_id = decoded_info.id
    twitch.redirect_url = decoded_info.redirect
    twitch.redirect_port = decoded_info.port
    twitch.initialized = true

    twitch.auth_listener = socket.bind("127.0.0.1", twitch.redirect_port)
end

twitch.get_refresh_token = function()
    assert(twitch.initialized, "TWITCH API NOT INITIALIZED")

    local refresh_request = "https://id.twitch.tv/oauth2/token"
    local params = "grant_type=refresh_token"
    append_param(params, "client_id", twitch.client_id)
    append_param(params, "refresh_token", twitch.refresh_token)
    append_param(params, "client_secret", twitch.client_secret)
    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded"
    }
    local body, code = network.post(refresh_request, headers, params)
    assert(code == 200, "Failed to refresh Twitch token! " .. body)

    local auth_info = json.decode(body)
    twitch.token = auth_info.access_token
    twitch.token_type = auth_info.token_type
    twitch.refresh_token = auth_info.refresh_token
end

twitch.get_auth_token = function()
    assert(twitch.initialized, "TWITCH API NOT INITIALIZED")

    local token_request = "https://id.twitch.tv/oauth2/token"
    local params = build_twitch_params("authorization_code")
    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded"
    }
    local body, code = network.post(token_request, headers, params)
    assert(code == 200, "Authentication failed!")

    local auth_info = json.decode(body)
    twitch.token = auth_info.access_token
    twitch.token_type = auth_info.token_type
    twitch.refresh_token = auth_info.refresh_token
end

twitch.get_marathon_id = function()
    if twitch.marathon_id ~= -1 then
        return twitch.marathon_id
    end

    assert(twitch.initialized, "TWITCH API NOT INITIALIZED")

    local url = API .. end_points.users .. "?login=FangameMarathon"
    local headers = {
        ["Authorization"] = get_auth_header(),
        ["Client-Id"] = twitch.client_id
    }
    local body, code = check_request(network.get, url, headers)
    print(body)
    print(tostring(code))
    local user_info = json.decode(body)
    twitch.marathon_id = user_info.data[1].id
    return twitch.marathon_id
end

twitch.get_game_id = function(game_name)
    if twitch.games_database[game_name] then
        return twitch.games_database[game_name]
    end

    assert(twitch.initialized, "TWITCH API NOT INITIALIZED")

    local url = API .. end_points.games .. "?name=" .. game_name
    local headers = {
        ["Authorization"] = get_auth_header(),
        ["Client-Id"] = twitch.client_id
    }
    local body, code = check_request(network.get, url, headers)
    local game_info = json.decode(body)
    twitch.games_database[game_name] = game_info.data[1].id

    return twitch.games_database[game_name]
end

twitch.update_title = function(game, runner, is_tas)
    assert(twitch.initialized, "TWITCH API NOT INITIALIZED")

    if not is_tas then
        is_tas = false
    end

    local url = API .. end_points.channels .. "?broadcaster_id=" .. twitch.get_marathon_id()
    local headers = {
        ["Authorization"] = get_auth_header(),
        ["Client-Id"] = twitch.client_id,
        ["Content-Type"] = "application/json"
    }

    local game_string = game
    if is_tas then
        game_string = game_string .. " (TAS)"
    end

    local title = "FM2023 || " .. game_string .. ", by " .. runner

    -- Use this title after done testing "Fangame Marathon 2023 || July 12-16" and set game as "Special Events"
    game = url_lib.escape(game)

    local data = {
        title = title,
        game_id = twitch.get_game_id(game)
    }
    local encoded_data = json.encode(data)

    check_request(network.patch, url, headers, encoded_data)
end

function twitch.get_auth_url()
    assert(twitch.initialized, "TWITCH API NOT INITIALIZED")

    twitch.auth_url = "https://id.twitch.tv/oauth2/authorize?response_type=code"
    twitch.auth_url = twitch.auth_url .. "&client_id=" .. twitch.client_id
    twitch.auth_url = twitch.auth_url .. "&redirect_uri=" .. twitch.redirect_url .. ":" .. twitch.redirect_port .. "/"
    twitch.auth_url = twitch.auth_url .. "&" .. get_scope()
    return twitch.auth_url
end

---This is dumb parsing
---@param data string
function twitch.parse_auth_data(data)
    -- I hate it here
    for word in data:gmatch("%S+") do
        print(word)
        if word ~= "GET" and word ~= "HTTP/1.1" then
            local code_keyword = ""
            local code_seen = false
            for char in word:gmatch(".") do
                if char ~= "/" and char ~= "?" then
                    if not code_seen then
                        code_keyword = code_keyword .. char
                        if code_keyword == "code=" then
                            code_seen = true
                        end
                    else
                        if char == "&" then
                            break
                        end
                        twitch.auth_code = twitch.auth_code .. char
                    end
                end
            end
            break
        end
    end
end

return twitch

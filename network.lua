-- Wrappers for using cURL library

local curl = require("cURL")

network = {}


---Converts headers table to a string array
---@param headers table
---@return table
local function headers_to_string_array(headers)
    local headers_array = {}
    for k, v in pairs(headers) do
        local header_string = k .. ": "
        header_string = header_string .. v
        table.insert(headers_array, header_string)
    end

    return headers_array
end


---Performs any request
---@param request function
---@param url string
---@param headers table
---@param postparams? string
function network.perform(request, url, headers, postparams)
    if postparams then
        return request(url, headers, postparams)
    end
    return request(url, headers)
end

---Performs a GET request
---@param url string
---@param headers table
function network.get(url, headers)
    local reply = {}
    local c = curl.easy {
        url = url,
        httpheader = headers_to_string_array(headers)
    }
    c:setopt_writefunction(table.insert, reply)

    local ok, err = c:perform()
    if not ok then
        print(err)
    end

    local code = c:getinfo_response_code()

    c:close()

    return table.concat(reply), code
end

---Performs a POST request
---@param url string
---@param headers table
---@param postparams string
function network.post(url, headers, postparams)
    local reply = {}
    local c = curl.easy {
        url = url,
        post = true,
        postfields = postparams,
        httpheader = headers_to_string_array(headers)
    }
    c:setopt_writefunction(table.insert, reply)

    local ok, err = c:perform()
    if not ok then
        print(err)
    end

    local code = c:getinfo_response_code()

    c:close()

    return table.concat(reply), code
end

---Performs a PATCH request
---@param url string
---@param headers table
---@param postparams string
function network.patch(url, headers, postparams)
    local reply = {}
    local c = curl.easy {
        url = url,
        httpheader = headers_to_string_array(headers),
        postfields = postparams
    }
    c:setopt(curl.OPT_CUSTOMREQUEST, "PATCH")
    c:setopt_writefunction(table.insert, reply)

    local ok, err = c:perform()
    if not ok then
        print(err)
    end

    local code = c:getinfo_response_code()

    c:close()

    return table.concat(reply), code
end

return network

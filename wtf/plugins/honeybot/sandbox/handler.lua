local require = require
local cjson = require("cjson")
local tools = require("wtf.core.tools")
local Plugin = require("wtf.core.classes.plugin")
local http = require "resty.http"

local _M = Plugin:extend()
_M.name = "honeybot.sandbox"

function _M:access(...)
    local get, post, files = require("resty.reqargs")()
    local server = self:get_mandatory_parameter('server')
    local args = {}
    local msg = ""
    for key,val in pairs(get) do args[key]=val end
    for key,val in pairs(post) do args[key]=val end
    for key,val in pairs(files) do args[key]=val end
    local instance = select(1, ...)
    local redis=instance:get_storage("redis_local")
    if args then
        for key,val in pairs(args) do
            local m=string.match(key,"^<%?p?h?p?%s*(.*)%s*%?>$")
            if m and val== true then val=m end
            local exists = redis:get(val)
            if tostring(exists) ~= "" and tostring(exists) ~= "userdata: NULL" then
                msg = exists
            else
                if tostring(exists) ~= "" then
                    local httpc = http.new()
                    local res, err = httpc:request_uri(
                        "https://"..server.."/",
                        {
                            method="POST",
                            body=cjson.encode({bash=val,php=val}),
                            headers={
                                ["Content-Type"]="application/json"
                            },
                            ssl_verify=false
                        })
                    if res and res.body then
                        local body=cjson.decode(res.body)
                        if body.message then
                            for i,j in pairs({ php=true, bash=true }) do
                                if body.message[i].stderr then
                                    msg = msg .. body.message[i].stderr .. "\n"
                                end
                                if body.message[i].stdout then
                                    msg = msg .. body.message[i].stdout .. "\n"
                                end
                                redis:set(val, msg)
                            end
                        end
                    end
                end
            end
        end
        if msg ~= "" then
            ngx.status = 200 
            ngx.print(msg)
            ngx.exit(ngx.HTTP_OK)
        end
    end
end

return _M


local cjson = require "cjson"
local stringy = require "stringy"
local BasePlugin = require "kong.plugins.base_plugin"
local header_filter = require "kong.plugins.headerrewrite.header_filter"
local url = require "kong.plugins.headerrewrite.url"

local HeaderrewriteHandler = BasePlugin:extend()

--- Function which returns a Kong compliant upstream URL.
-- This function returns a Kong compliant upstream URL.
-- When https protocol is used and no port is defined, Kong (v0.9.3) adds port 443 to the URL;
-- therefore this function will have to do the same in order to be able to make comparisons.
-- see also : https://github.com/Mashape/kong/issues/869
-- @function get_upstream_url
-- @return kong compliant upstream URL
local function get_upstream_url()
    -- return ngx.ctx.api.upstream_url
    local upstream_url = ngx.ctx.api.upstream_url
   local upstream_url_parts = url.parse(upstream_url)
   if (upstream_url_parts.scheme == "https" and upstream_url_parts.port == 443) or (upstream_url_parts.scheme == "http" and upstream_url_parts.port == 80) then
      upstream_url = upstream_url_parts.scheme .."://" .. upstream_url_parts.host .. upstream_url_parts.path
      if tostring(upstream_url_parts.query) ~= "" then
         upstream_url= upstream_url .. "?" .. tostring(upstream_url_parts.query)
      end
   end
   return upstream_url
end

local function get_downstream_url()
    local api = ngx.ctx.api
    ngx.log(ngx.DEBUG, "API Value:" .. ngx.var.request_uri)
    if ngx.var.request_uri then
        local request_uri =
            ngx.var.scheme .. "://" .. ngx.var.host .. ":" .. ngx.var.server_port .. ngx.var.request_uri .. "/"
        ngx.log(ngx.DEBUG, "Downstream url:" .. request_uri)
        return request_uri
    end
    ngx.log(ngx.DEBUG, "Returning nil")
    return nil
end
---------------------------
-- Plugin implementation --
---------------------------

function HeaderrewriteHandler:new()
    HeaderrewriteHandler.super.new(self, "headerrewrite")
end

function HeaderrewriteHandler:header_filter(config)
    HeaderrewriteHandler.super.header_filter(self)
    if config.headers then
        for k,v in pairs(config.headers) do 
            ngx.log(ngx.DEBUG, "Header found:" .. v)
            header_value = ngx.header[v]
            if header_value then
                ngx.header[v] = header_filter.execute(stringy.strip(header_value):lower(), get_upstream_url(), get_downstream_url())
            else 
                ngx.log(ngx.DEBUG, "Header not found in response:")
            end
        end
    end
end

return HeaderrewriteHandler

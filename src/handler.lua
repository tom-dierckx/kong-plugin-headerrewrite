local cjson = require "cjson"
local stringy = require "stringy"
local BasePlugin = require "kong.plugins.base_plugin"
local header_filter = require "kong.plugins.headerrewrite.header_filter"
local url = require "kong.plugins.headerrewrite.url"

local HeaderrewriteHandler = BasePlugin:extend()

local function isempty(s)
    return s == nil or s == ''
end

-- Kong 11 removes the ports if default values are used for http (80) ans https (443), remove them in these cases for comparison
local function get_upstream_url()
   local upstream_url = ngx.ctx.api.upstream_url
   local upstream_url_parts = url.parse(upstream_url)
   if (upstream_url_parts.scheme == "https" and upstream_url_parts.port == 443) or (upstream_url_parts.scheme == "http" and upstream_url_parts.port == 80) then
      upstream_url = upstream_url_parts.scheme .."://" .. upstream_url_parts.host .. upstream_url_parts.path
      if tostring(upstream_url_parts.query) ~= "" then
         upstream_url= upstream_url .. "?" .. tostring(upstream_url_parts.query)
      end
   end
   ngx.log(ngx.DEBUG, "Upstream url:" .. upstream_url)
   return upstream_url
end

local function get_downstream_url()
    ngx.log(ngx.DEBUG, "API Value:" .. ngx.var.request_uri)
    -- Loadbalancer fix
    forwarded_proto = ngx.req.get_headers()['x-forwarded-proto']
    if ngx.var.request_uri then
        if isempty(forwarded_proto) then
            ngx.log(ngx.DEBUG, "X-Forwarded-Proto is leeg")
            return ngx.var.scheme .. "://" .. ngx.var.host .. ":" .. ngx.var.server_port .. ngx.var.request_uri .. "/"
        else
            -- only support for http / https on the default ports
            ngx.log(ngx.DEBUG, "X-Forwarded-Proto gevonden")
            return forwarded_proto .. "://" .. ngx.var.host .. ":" .. ngx.var.request_uri .. "/"
        end
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
            header_value = ngx.header[v]
            if header_value then
                ngx.log(ngx.DEBUG, "Found header:" .. v .. ":" .. stringy.strip(header_value):lower())
                ngx.header[v] = header_filter.execute(stringy.strip(header_value):lower(), get_upstream_url(), get_downstream_url())
                ngx.req.set_header(v, header_filter.execute(stringy.strip(header_value):lower(), get_upstream_url(), get_downstream_url()))
            else 
                ngx.log(ngx.DEBUG, "Header not found in response:")
            end
        end
    end
end

return HeaderrewriteHandler

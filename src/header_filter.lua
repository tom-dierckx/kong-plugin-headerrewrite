local utils = require "kong.tools.utils"
local stringy = require "stringy"
local dkjson = require ("dkjson")

local HeaderFilter = {}

function literalize(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
end

---------------------------
-- Filter implementation --
---------------------------
function HeaderFilter.execute(header, upstream_url, downstream_url)
	return_value = header
	ngx.log(ngx.DEBUG, "Upstream and downstream are set header=" .. header .. " upstream=" .. upstream_url .. " downstream=" .. downstream_url)
	if upstream_url and downstream_url then
		if header then
			return_value = string.gsub(header,literalize(upstream_url),downstream_url)
		end
	end
	return return_value
end

return HeaderFilter 

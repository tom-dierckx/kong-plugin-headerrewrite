local utils = require "kong.tools.utils"
local stringy = require "stringy"
local dkjson = require ("dkjson")

local HeaderFilter = {}

---------------------------
-- Filter implementation --
---------------------------
function HeaderFilter.execute(header, upstream_url, downstream_url)
	if upstream_url and downstream_url then
		if header then
			return string.gsub(header,upstream_url,downstream_url)
		end
	end
	return header
end

return HeaderFilter 

package = "kong-plugin-headerrewrite"
version = "0.0-1"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/tom-dierckx/kong-plugin-headerrewrite",
  tag = "master"
}
description = {
  summary = "The Kong Headerrewrite plugin.",
  license = "MIT",
  detailed = [[
      The headerrewrite plugin rewrites header containing backend url's with gateway url.
  ]],
}
dependencies = {
  "lua ~> 5.1",
  "dkjson ~> 2.5-2"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.headerrewrite.handler"] = "src/handler.lua",
    ["kong.plugins.headerrewrite.schema"] = "src/schema.lua",
    ["kong.plugins.headerrewrite.url"] = "src/url.lua",
    ["kong.plugins.headerrewrite.header_filter"] = "src/header_filter.lua"
  }
}
package = "kong-plugin-jwt-claim-to-header-matcher"  -- hint: rename, must match the info in the filename of this rockspec!
                                  -- as a convention; stick to the prefix: `kong-plugin-`
version = "0.2.0-1"               -- hint: renumber, must match the info in the filename of this rockspec!
-- The version '0.0.1' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- TODO: This is the name to set in the Kong configuration `plugins` setting.
-- Here we extract it from the package name.
local pluginName = package:match("^kong%-plugin%-(.+)$")  -- "myPlugin"

supported_platforms = {"linux", "macosx"}
source = {
  url = "https://github.com/Abhishek-Govula/kong-plugin-jwt-claim-to-header-matcher",
  branch = "master",
--  tag = "0.0.1"
-- hint: "tag" could be used to match tag in the repository
}

description = {
  summary = "This Kong plugin enables you to verify if the claims passed in the JWT and the request header matches.",
  homepage = "https://github.com/Abhishek-Govula/kong-plugin-jwt-claim-to-header-matcher",
  license = "Apache 2.0",
}

dependencies = {
   "lua >= 5.1"
   -- other dependencies should appear here
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".jwt_parser"] = "kong/plugins/"..pluginName.."/jwt_parser.lua",
  }
}
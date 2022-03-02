-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------

local jwt_decoder = require "kong.plugins.jwt-claim-to-header-matcher.jwt_parser"

local constants = require "kong.constants"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"


local fmt = string.format
local kong = kong
local type = type
local error = error
local ipairs = ipairs
local tostring = tostring
local re_gmatch = ngx.re.gmatch

local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}



-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]



--[[ runs in the 'ssl_certificate_by_lua_block'
-- IMPORTANT: during the `certificate` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]


--- Retrieve a JWT in a request.
-- Checks for the JWT in URI parameters, then in cookies, and finally
-- in the configured header_names (defaults to `[Authorization]`).
-- @param request ngx request object
-- @param conf Plugin configuration
-- @return token JWT token contained in request (can be a table) or nil
-- @return err
local function retrieve_token(conf)
  local request_headers = kong.request.get_headers()
  local token_header = request_headers["authorization"]
  if token_header then
    if type(token_header) == "table" then
      token_header = token_header[1]
    end
    local iterator, iter_err = re_gmatch(token_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      kong.log.err(iter_err)
      break
    end

    local m, err = iterator()
    if err then
      kong.log.err(err)
      break
    end

    if m and #m > 0 then
      return m[1]
    end
  end
end

local function do_wid_validation(conf)
  local token, err = retrieve_token(conf)
  if err then
    return error(err)
  end

  local token_type = type(token)
  if token_type ~= "string" then
    if token_type == "nil" then
      return false, { status = 401, message = "Unauthorized" }
    elseif token_type == "table" then
      return false, { status = 401, message = "Multiple tokens provided" }
    else
      return false, { status = 401, message = "Unrecognizable token" }
    end
  end

  kong.log.debug(token)

  

  -- Decode token to find out who the caller is
  local jwt, err = jwt_decoder:new(token)
  if err then
    return false, { status = 401, message = "Bad token; " .. tostring(err) }
  end

  local claims = jwt.claims
  
  -- Checking if the request wid is same as claims wid
  if claims["wid"] == "nil" then
    return false, { status = 401, message = "WID missing in token" }
  elseif claims["wid"] == kong.request.get_header("wid")
    return true
  return false
end


-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)

  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  kong.service.request.set_header(plugin_conf.request_header, "this is on a request")

  -- Reading the access token
  do_wid_validation(plugin_conf)

end --]]


-- runs in the 'header_filter_by_lua_block'
-- function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  -- kong.response.set_header(plugin_conf.response_header, "this is on the response")

-- end --]]


--[[ runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'body_filter' handler")

end --]]


--[[ runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")

end --]]


-- return our plugin object
return plugin
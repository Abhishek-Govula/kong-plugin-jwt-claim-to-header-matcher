local typedefs = require "kong.db.schema.typedefs"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

return {
  name = "jwt-claim-to-header-matcher",
  fields = {
    { config = {
        type = "record",
        fields = {
          { keys_to_check = colon_string_record },
        },
      },
    },
  },
}
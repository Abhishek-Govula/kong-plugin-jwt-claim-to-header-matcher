local colon_string_array = {
  type = "array",
  default = {},
  elements = { type = "string", match = "^[^:]+:.*$" },
}

local colon_string_record = {
  type = "record",
  fields = {
    { json = colon_string_array },
  },
}
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
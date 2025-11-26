local pesde = require(script.Parent.pesde)

local PLUGIN_NAME = "Starlight"
local PLUGIN_ID = "starlight"

return {
	PLUGIN_TITLE = `{PLUGIN_NAME} {pesde.version}`,
	PLUGIN_NAME = PLUGIN_NAME,
	PLUGIN_ID = PLUGIN_ID,
	PLUGIN_VERSION = pesde.version,
}

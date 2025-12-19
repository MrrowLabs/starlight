local Selection = game:GetService("Selection")
local App = require(script.App)
local Theme = require(script.Theme)
local constants = require(script.constants)
local Fusion = require(script.packages.Fusion)
local types = require(script.types)
local assetRegistry = require(script.utils.assetRegistry)
local getAssetTypeFromInstance = require(script.utils.getAssetTypeFromInstance)
local json = require(script.utils.json)

local scoped = Fusion.scoped
local doCleanup = Fusion.doCleanup
local peek = Fusion.peek
local Children = Fusion.Children

local pluginScope = scoped(Fusion, {
	Theme = Theme,
	plugin = plugin,
})

local savedAssetIndices = plugin:GetSetting("AssetIndices") :: (types.AssetIndices | string)?

local assetIndices: Fusion.Value<types.AssetIndices> =
	pluginScope:Value(if savedAssetIndices and typeof(savedAssetIndices) == "string"
		then json.decode(savedAssetIndices)
		else savedAssetIndices or {
			assets = {},
			assetUids = {},
			assetRepos = {},
			assetTags = {},
			favorites = {},
		})

table.insert(
	pluginScope,
	plugin.Unloading:Connect(function()
		plugin:SetSetting("AssetIndices", json.encode(peek(assetIndices)))
		doCleanup(pluginScope)
	end)
)

-- tag pruning
for tag, assetUids in peek(assetIndices).assetTags do
	if next(assetUids) ~= nil then
		continue
	end

	peek(assetIndices).assetTags[tag] = nil
end

-- TODO: most likely wait a bit until actually saving, could be causing a LOT of lag

pluginScope:Observer(assetIndices):onChange(function()
	-- plugin:SetSetting("AssetIndices", json.encode(peek(assetIndices)))
	-- task.spawn(plugin.SetSetting, plugin, "AssetIndicies", json.encode(peek(assetIndices)))
	-- task.spawn(function()
	-- 	plugin:SetSetting("AssetIndices", json.encode(peek(assetIndices)))
	-- end)
end)

if plugin:GetSetting("AssetIndices") == nil then
	-- most likely a first install
	print("installing default starlight repo...")
	assetRegistry.importAssetRepoFromUri(
		assetIndices,
		"https://raw.githubusercontent.com/MrrowLabs/starlight-megarepo/refs/heads/main/starlight.repo.json"
	)
	assetRegistry.update(assetIndices)
end

local rawSelection: Fusion.Value<{ Instance }> = pluginScope:Value(Selection:Get())

table.insert(
	pluginScope,
	Selection.SelectionChanged:Connect(function()
		rawSelection:set(Selection:Get())
	end)
)

local selection: Fusion.Computed<{ Instance }> = pluginScope:Computed(function(use)
	local selection: { Instance } = {}

	for _, instance in use(rawSelection) do
		if not getAssetTypeFromInstance(instance) then
			continue
		end

		table.insert(selection, instance)
	end

	return selection
end)

local appWidget = plugin:CreateDockWidgetPluginGuiAsync(
	constants.PLUGIN_ID,
	DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 270, 360, 270, 360)
)
appWidget.Title = `{constants.PLUGIN_NAME} {constants.PLUGIN_VERSION}`
appWidget.Name = appWidget.Title
appWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local appScope: types.AppScope = pluginScope:deriveScope({
	plugin = plugin,
	modals = {
		createRepo = pluginScope:Value(false),
	},
})

appScope:Hydrate(appWidget) {
	Name = constants.PLUGIN_TITLE,
	Title = constants.PLUGIN_TITLE,

	[Children] = App(appScope, {
		theme = pluginScope:Theme(),
		assetIndices = assetIndices,
		rawSelection = rawSelection,
		selection = selection,
	}),
}

local pluginToolbar = plugin:CreateToolbar(constants.PLUGIN_NAME)

local appToolbarButton = pluginToolbar:CreateButton(
	constants.PLUGIN_ID,
	"Quickly sift through a library of assets",
	"rbxassetid://108513556336860"
)

appToolbarButton.Click:Connect(function()
	appWidget.Enabled = not appWidget.Enabled
	appToolbarButton:SetActive(false)
end)

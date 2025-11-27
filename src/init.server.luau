local Selection = game:GetService("Selection")
local App = require(script.App)
local Theme = require(script.Theme)
local constants = require(script.constants)
local Fusion = require(script.packages.Fusion)
local types = require(script.types)
local assetRegistry = require(script.utils.assetRegistry)
local getAssetTypeFromInstance = require(script.utils.getAssetTypeFromInstance)

local scoped = Fusion.scoped
local doCleanup = Fusion.doCleanup
local peek = Fusion.peek
local Children = Fusion.Children

local pluginScope = scoped(Fusion, {
	Theme = Theme,
	plugin = plugin,
})

table.insert(
	pluginScope,
	plugin.Unloading:Connect(function()
		doCleanup(pluginScope)
	end)
)

local assetIndicies: Fusion.Value<types.AssetIndicies> =
	pluginScope:Value(plugin:GetSetting("AssetIndicies") :: types.AssetIndicies? or {
		assets = {},
		assetUids = {},
		assetRepos = {},
		assetTags = {},
		favorites = {},
	})

if plugin:GetSetting("AssetIndicies") == nil then
	-- most likely a first install
	print("installing default starlight repo...")
	assetRegistry.importAssetRepoFromUri(
		assetIndicies,
		"https://raw.githubusercontent.com/MrrowLabs/starlight/refs/heads/master/starlight.repo.json"
	)
	assetRegistry.update(assetIndicies)
end

-- tag pruning
for tag, assetUids in peek(assetIndicies).assetTags do
	if next(assetUids) ~= nil then
		continue
	end

	peek(assetIndicies).assetTags[tag] = nil
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

pluginScope:Observer(assetIndicies):onChange(function()
	plugin:SetSetting("AssetIndicies", peek(assetIndicies))
end)

local appWidget = plugin:CreateDockWidgetPluginGui(
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
		assetIndicies = assetIndicies,
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

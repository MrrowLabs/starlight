local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local Border = require(script.Parent.components.Border)
local Button = require(script.Parent.components.Button)

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

type AssetRepoButtonProps = {
	theme: Theme.ThemeContext,
	text: Fusion.UsedAs<string>,
	selected: Fusion.UsedAs<boolean>,
	onClick: () -> (),
}

local function AssetRepoButton(scope: Fusion.Scope<typeof(Fusion)>, props: AssetRepoButtonProps)
	local scope = scope:deriveScope({
		Button = Button,
		Border = Border,
	})

	return scope:Button {
		theme = props.theme,
		size = UDim2.new(1, 0, 0, 32),
		automaticSize = Enum.AutomaticSize.Y,
		backgroundColor = scope:Computed(function(use)
			return if use(props.selected) then use(props.theme.primary) else use(props.theme.bg_light)
		end),
		text = props.text,
		textColor = scope:Computed(function(use)
			return if use(props.selected) then use(props.theme.bg) else use(props.theme.text)
		end),
		onClick = props.onClick,

		[Children] = {
			scope:Border {
				theme = props.theme,
				radius = UDim.new(0, 6),
			},
		},
	}
end

type AssetRepoListProps = {
	theme: Theme.ThemeContext,
	assetIndices: Fusion.Value<types.AssetIndices>,
	selectedAssetRepo: Fusion.Value<types.AssetRepo?>,
	createRepoModalOpen: Fusion.Value<boolean>,
	importRepoModalOpen: Fusion.Value<boolean>,
	exportRepoModalOpen: Fusion.Value<boolean>,
}

local function AssetRepoList(scope: types.AppScope, props: AssetRepoListProps)
	local scope = scope:deriveScope({
		AssetRepoButton = AssetRepoButton,
		Border = Border,
	})

	return scope:New "ImageButton" {
		BackgroundColor3 = props.theme.bg,
		Size = UDim2.fromScale(1, 1),

		[Children] = Child {
			scope:Border {
				theme = props.theme,
				radius = UDim.new(0, 8),
			},

			scope:New "ScrollingFrame" {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				CanvasSize = UDim2.fromScale(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 0,

				[Children] = Child {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

					scope:New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
					},

					scope:AssetRepoButton {
						theme = props.theme,
						text = "All",
						selected = scope:Computed(function(use)
							return use(props.selectedAssetRepo) == nil
						end),
						onClick = function()
							props.selectedAssetRepo:set(nil)
						end,
					},

					scope:New "Frame" {
						BackgroundColor3 = props.theme.border_muted,
						Size = UDim2.new(1, 0, 0, 1),
					},

					scope:New "Frame" {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,

						[Children] = Child {
							scope:New "UIListLayout" {
								Padding = UDim.new(0, 8),
								SortOrder = Enum.SortOrder.LayoutOrder,
							},

							scope:Computed(function(use, scope: typeof(scope))
								local assetRepoButtons = {}

								for _, assetRepo in use(props.assetIndices).assetRepos do
									table.insert(
										assetRepoButtons,
										scope:AssetRepoButton {
											theme = props.theme,
											text = assetRepo.name,
											selected = scope:Computed(function(use)
												return use(props.selectedAssetRepo) == assetRepo
											end),
											onClick = function()
												props.selectedAssetRepo:set(assetRepo)
											end,
										}
									)
								end

								return assetRepoButtons
							end),
						},
					},

					scope:New "Frame" {
						BackgroundColor3 = props.theme.border_muted,
						Size = UDim2.new(1, 0, 0, 1),
					},

					scope:AssetRepoButton {
						theme = props.theme,
						text = "Create Repo",
						selected = false,
						onClick = function()
							props.createRepoModalOpen:set(true)
						end,
					},

					scope:AssetRepoButton {
						theme = props.theme,
						text = "Import Repo",
						selected = false,
						onClick = function()
							props.importRepoModalOpen:set(true)
						end,
					},

					scope:AssetRepoButton {
						theme = props.theme,
						text = "Export Repo",
						selected = false,
						onClick = function()
							if not peek(props.selectedAssetRepo) then
								return
							end

							props.exportRepoModalOpen:set(true)
						end,
					},
				},
			},
		},
	}
end

return AssetRepoList

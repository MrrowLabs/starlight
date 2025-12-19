local Input = require(script.Parent.Input)
local Modal = require(script.Parent.Parent.Modal)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.Parent.types)
local AssetRender = require(script.Parent.Parent.AssetRender)
local applyAsset = require(script.Parent.Parent.Parent.utils.applyAsset)
local assetRegistry = require(script.Parent.Parent.Parent.utils.assetRegistry)
local TagsRender = require(script.Parent.Parent.TagsRender)
local Border = require(script.Parent.Parent.components.Border)
local Button = require(script.Parent.Parent.components.Button)
local Text = require(script.Parent.Parent.components.Text)
local TextBox = require(script.Parent.Parent.components.TextBox)

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

type AssetDetailsModalProps = {
	theme: Theme.ThemeContext,
	assetIndices: Fusion.Value<types.AssetIndices>,
	rawSelection: Fusion.Value<{ Instance }>,
	asset: types.Asset,
	selectedAsset: Fusion.Value<types.Asset?>,
	editAssetModalOpen: Fusion.Value<boolean>,
	assetDetailsModalOpen: Fusion.Value<boolean>,
}

local function AssetDetailsModal(scope: types.AppScope, props: AssetDetailsModalProps)
	local scope = scope:deriveScope({
		AssetRender = AssetRender,
		TagsRender = TagsRender,
		Modal = Modal,
		Input = Input,
		Button = Button,
		TextBox = TextBox,
		Text = Text,
		Border = Border,
	})

	return scope:Modal {
		theme = props.theme,

		[Children] = Child {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			scope:New "Frame" {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				[Children] = {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
					},

					scope:New "Frame" {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,

						[Children] = {
							scope:New "UIListLayout" {
								Padding = UDim.new(0, 4),
								SortOrder = Enum.SortOrder.LayoutOrder,
							},

							scope:Text {
								theme = props.theme,
								text = props.asset.name,
								textSize = 24,
								textWrapped = true,
								fontWeight = Enum.FontWeight.Bold,
							},

							scope:Text {
								theme = props.theme,
								text = `<b>by:</b> {props.asset.credits}`,
								textColor = props.theme.text_muted,
								textWrapped = true,
								visible = props.asset.credits:match("^%s*$") == nil,
							},

							scope:Text {
								theme = props.theme,
								text = `<b>in:</b> {props.asset.assetRepo}`,
								textColor = props.theme.text_muted,
								textWrapped = true,
								visible = props.asset.assetRepo ~= nil,
							},

							scope:Text {
								theme = props.theme,
								text = `<b>uid:</b> {props.asset.uid}`,
								textColor = props.theme.text_muted,
								textWrapped = true,
							},

							scope:TagsRender {
								theme = props.theme,
								tags = props.asset.tags,
							},
						},
					},

					scope:New "Frame" {
						BackgroundColor3 = props.theme.bg_light,
						Size = UDim2.fromOffset(128, 128),

						[Children] = Child {
							scope:New "UIFlexItem" {},

							scope:Border {
								theme = props.theme,
								radius = UDim.new(0, 6),
							},

							scope:AssetRender {
								theme = props.theme,

								asset = props.asset,

								[Children] = scope:Border {
									theme = props.theme,
									radius = UDim.new(0, 6),
									strokeSize = 0,
								},
							},
						},
					},
				},
			},

			scope:Button {
				theme = props.theme,
				backgroundColor = props.theme.bg_light,
				size = UDim2.new(1, 0, 0, 32),
				text = scope:Computed(function(use)
					return if use(props.assetIndices).favorites[props.asset.uid] then "Unfavorite" else "Favorite"
				end),
				automaticSize = Enum.AutomaticSize.Y,

				onClick = function()
					props.selectedAsset:set(nil)

					if peek(props.assetIndices).favorites[props.asset.uid] then
						assetRegistry.unfavoriteAsset(props.assetIndices, props.asset.uid)
					else
						assetRegistry.favoriteAsset(props.assetIndices, props.asset.uid)
					end

					assetRegistry.update(props.assetIndices)
				end,

				[Children] = scope:Border {
					theme = props.theme,
					radius = UDim.new(0, 6),
				},
			},

			scope:New "Frame" {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = Child {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
					},

					scope:Button {
						theme = props.theme,
						backgroundColor = props.theme.bg_light,
						size = UDim2.new(1, 0, 0, 32),
						text = "Close",
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							props.selectedAsset:set(nil)
							props.assetDetailsModalOpen:set(false)
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},

					scope:Computed(function(use)
						local assetIndices = use(props.assetIndices)
						local assetRepo = if props.asset.assetRepo
							then assetIndices.assetRepos[props.asset.assetRepo]
							else nil

						return if not assetRepo or not assetRepo.readonly
							then scope:Button {
								theme = props.theme,
								backgroundColor = props.theme.bg_light,
								size = UDim2.new(1, 0, 0, 32),
								text = "Edit",
								automaticSize = Enum.AutomaticSize.Y,

								onClick = function()
									props.assetDetailsModalOpen:set(false)
									props.editAssetModalOpen:set(true)
								end,

								[Children] = scope:Border {
									theme = props.theme,
									radius = UDim.new(0, 6),
								},
							}
							else nil
					end),

					scope:Button {
						theme = props.theme,
						size = UDim2.new(1, 0, 0, 32),
						text = "Apply",
						textColor = props.theme.bg,
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							props.selectedAsset:set(nil)
							props.assetDetailsModalOpen:set(false)

							applyAsset(props.asset, peek(props.rawSelection))
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},
				},
			},
		},
	}
end

return AssetDetailsModal

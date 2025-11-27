local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local AssetRender = require(script.Parent.AssetRender)
local applyAsset = require(script.Parent.Parent.utils.applyAsset)
local assetRegistry = require(script.Parent.Parent.utils.assetRegistry)
local Border = require(script.Parent.components.Border)
local Button = require(script.Parent.components.Button)
local Text = require(script.Parent.components.Text)

-- TODO: turn this into a setting
local MAX_PAGE_SIZE = 100

local peek = Fusion.peek
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children
local Child = Fusion.Child

type AssetListProps = {
	theme: Theme.ThemeContext,
	assets: Fusion.UsedAs<{ types.Asset }>,
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	rawSelection: Fusion.Value<{ Instance }>,
	selectedAsset: Fusion.Value<types.Asset?>,
	assetDetailsModalOpen: Fusion.Value<boolean>,
	bulkDeleteMode: Fusion.Value<boolean>,
}

local function AssetList(scope: Fusion.Scope<typeof(Fusion)>, props: AssetListProps)
	local scope = scope:deriveScope({
		AssetRender = AssetRender,
		Text = Text,
		Button = Button,
		Border = Border,
	})

	local currentPage = scope:Value(0)
	local maxPage = scope:Computed(function(use)
		return math.ceil(#use(props.assets) / MAX_PAGE_SIZE - 1)
	end)
	local pageSlice: Fusion.Computed<{ types.Asset }> = scope:Computed(function(use)
		local startIndex = use(currentPage) * MAX_PAGE_SIZE + 1
		local endIndex = (use(currentPage) + 1) * MAX_PAGE_SIZE

		return table.move(use(props.assets), startIndex, endIndex, 1, {})
	end)

	return scope:New "Frame" {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Children] = {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalFlex = Enum.UIFlexAlignment.Fill,
			},

			scope:New "ScrollingFrame" {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				CanvasSize = UDim2.fromScale(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 0,
				ClipsDescendants = false,

				[Children] = Child {
					scope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 8),
						Wraps = true,
					},

					scope:ForValues(pageSlice, function(_, scope: typeof(scope), asset)
						return scope:New "ImageButton" {
							BackgroundColor3 = props.theme.bg,
							Size = UDim2.fromOffset(80, 80),

							[OnEvent "MouseButton1Click"] = function()
								if peek(props.bulkDeleteMode) then
									assetRegistry.deleteAsset(props.assetIndicies, asset.uid)
									assetRegistry.update(props.assetIndicies)
									return
								end

								props.selectedAsset:set(asset)
								props.assetDetailsModalOpen:set(true)
							end,

							[OnEvent "MouseButton2Click"] = function()
								applyAsset(asset, peek(props.rawSelection))
							end,

							[Children] = Child {
								scope:Border {
									theme = props.theme,
									radius = UDim.new(0, 8),
									strokeColor = scope:Computed(function(use)
										return if use(props.assetIndicies).favorites[use(asset).uid]
											then use(props.theme.primary)
											else use(props.theme.border_muted)
									end),
									strokeOffset = UDim.new(0, -1), -- im just gonna be hella lazy rn
								},

								scope:AssetRender {
									theme = props.theme,

									asset = asset,

									[Children] = {
										scope:New "UICorner" {
											CornerRadius = UDim.new(0, 8),
										},
									},
								},
							},
						}
					end),
				},
			},

			scope:New "Frame" {
				Size = UDim2.new(1, 0, 0, 56),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New "UIFlexItem" {},

					scope:New "UIListLayout" {
						Padding = UDim.new(0, 8),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

					scope:New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
					},

					scope:Button {
						theme = props.theme,
						backgroundColor = props.theme.bg,
						text = "<",
						textSize = 18,
						size = UDim2.fromScale(1, 1),

						onClick = function()
							if peek(maxPage) == -1 then
								return
							end
							currentPage:set(math.clamp(peek(currentPage) - 1, 0, peek(maxPage)))
						end,

						[Children] = Child {
							scope:New "UIAspectRatioConstraint" {
								AspectRatio = 1,
							},

							scope:Border {
								theme = props.theme,
								radius = UDim.new(0, 8),
							},
						},
					},

					scope:New "Frame" {
						BackgroundColor3 = props.theme.bg,
						Size = UDim2.fromScale(1, 1),
						AutomaticSize = Enum.AutomaticSize.X,

						[Children] = Child {
							scope:New "UIAspectRatioConstraint" {
								AspectRatio = 2,
							},

							scope:New "UIPadding" {
								PaddingLeft = UDim.new(0, 12),
								PaddingRight = UDim.new(0, 12),
							},

							scope:Border {
								theme = props.theme,
								radius = UDim.new(0, 8),
							},

							scope:Text {
								theme = props.theme,
								text = scope:Computed(function(use)
									return `{use(currentPage) + 1}`
								end),
								textSize = 18,
								position = UDim2.fromScale(0, 0.5),
								anchorPoint = Vector2.new(0, 0.5),
								size = UDim2.fromScale(1, 1),
								automaticSize = Enum.AutomaticSize.None,
								textXAlignment = Enum.TextXAlignment.Center,
							},
						},
					},

					scope:Button {
						theme = props.theme,
						backgroundColor = props.theme.bg,
						text = ">",
						textSize = 18,
						size = UDim2.fromScale(1, 1),

						onClick = function()
							if peek(maxPage) == -1 then
								return
							end
							currentPage:set(math.clamp(peek(currentPage) + 1, 0, peek(maxPage)))
						end,

						[Children] = Child {
							scope:New "UIAspectRatioConstraint" {
								AspectRatio = 1,
							},

							scope:Border {
								theme = props.theme,
								radius = UDim.new(0, 8),
							},
						},
					},
				},
			},
		},
	}
end

return AssetList

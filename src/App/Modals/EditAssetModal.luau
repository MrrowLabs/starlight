local AssetForm = require(script.Parent.AssetForm)
local Input = require(script.Parent.Input)
local Modal = require(script.Parent.Parent.Modal)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.Parent.types)
local arrayDiff = require(script.Parent.Parent.Parent.utils.arrayDiff)
local assetRegistry = require(script.Parent.Parent.Parent.utils.assetRegistry)
local values = require(script.Parent.Parent.Parent.utils.values)
local Border = require(script.Parent.Parent.components.Border)
local Button = require(script.Parent.Parent.components.Button)
local Text = require(script.Parent.Parent.components.Text)

-- TODO: turn this into a setting later on
local REQUIRED_DELETE_BUTTON_CLICKED = 5

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

-- TODO: allow for changing repos

type EditAssetModalProps = {
	theme: Theme.ThemeContext,
	assetIndices: Fusion.Value<types.AssetIndices>,
	asset: types.Asset,
	selectedAsset: Fusion.Value<types.Asset?>,
	assetDetailsModalOpen: Fusion.Value<boolean>,
	editAssetModalOpen: Fusion.Value<boolean>,
}

local function EditAssetModal(scope: Fusion.Scope<typeof(Fusion)>, props: EditAssetModalProps)
	local scope = scope:deriveScope({
		AssetForm = AssetForm,
		Modal = Modal,
		Input = Input,
		Button = Button,
		Text = Text,
		Border = Border,
	})

	local name = scope:Value(props.asset.name)
	local credits = scope:Value(props.asset.credits)
	local tags = scope:Value(values(props.asset.tags))

	local isEditable = scope:Computed(function(use)
		local assetIndices = use(props.assetIndices)
		local assetRepo = if props.asset.assetRepo then assetIndices.assetRepos[props.asset.assetRepo] else nil

		return not assetRepo or not assetRepo.readonly
	end)

	local deleteButtonClickedCount = scope:Value(0)

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
				Visible = isEditable,

				[Children] = scope:AssetForm {
					theme = props.theme,
					name = name,
					credits = credits,
					tags = tags,
				},
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

					scope:Button {
						theme = props.theme,
						backgroundColor = props.theme.bg_light,
						size = UDim2.new(1, 0, 0, 32),
						text = "Cancel",
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							props.editAssetModalOpen:set(false)
							props.assetDetailsModalOpen:set(true)
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},

					scope:Button {
						theme = props.theme,
						backgroundColor = props.theme.bg_light,
						size = UDim2.new(1, 0, 0, 32),
						text = scope:Computed(function(use)
							return if REQUIRED_DELETE_BUTTON_CLICKED - use(deleteButtonClickedCount) == 0
								then `Delete Asset (Last Chance)`
								else `Delete Asset ({REQUIRED_DELETE_BUTTON_CLICKED - use(deleteButtonClickedCount)})`
						end),
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							if peek(deleteButtonClickedCount) < REQUIRED_DELETE_BUTTON_CLICKED then
								deleteButtonClickedCount:set(peek(deleteButtonClickedCount) + 1)
								return
							end

							props.selectedAsset:set(nil)
							props.editAssetModalOpen:set(false)

							assetRegistry.deleteAsset(props.assetIndices, props.asset.uid)
							assetRegistry.update(props.assetIndices)
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},
				},
			},

			scope:Button {
				theme = props.theme,
				size = UDim2.new(1, 0, 0, 32),
				text = "Update Asset",
				textColor = props.theme.bg,
				automaticSize = Enum.AutomaticSize.Y,
				visible = isEditable,

				onClick = function()
					if peek(name):match("^%s*$") or peek(credits):match("^%s*$") then
						return
					end

					props.editAssetModalOpen:set(false)
					props.selectedAsset:set(nil)

					local asset: types.BaseAsset<any, any> = peek(props.assetIndices).assets[props.asset.uid]
					assert(asset, `unknown asset {props.asset.uid}`)

					asset.name = peek(name)
					asset.credits = peek(credits)

					props.assetIndices:set(peek(props.assetIndices))

					local addedTags, removedTags = arrayDiff(values(props.asset.tags), peek(tags))
					assetRegistry.addTags(props.assetIndices, props.asset.uid, table.unpack(addedTags))
					assetRegistry.removeTags(props.assetIndices, props.asset.uid, table.unpack(removedTags))

					assetRegistry.update(props.assetIndices)
				end,

				[Children] = scope:Border {
					theme = props.theme,
					radius = UDim.new(0, 6),
				},
			},
		},
	}
end

return EditAssetModal

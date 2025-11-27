local AssetForm = require(script.Parent.AssetForm)
local Modal = require(script.Parent.Parent.Modal)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.Parent.types)
local assetRegistry = require(script.Parent.Parent.Parent.utils.assetRegistry)
local Border = require(script.Parent.Parent.components.Border)
local Button = require(script.Parent.Parent.components.Button)
local Text = require(script.Parent.Parent.components.Text)
local TextBox = require(script.Parent.Parent.components.TextBox)

local Children = Fusion.Children
local Child = Fusion.Child

type ExportRepoModalProps = {
	theme: Theme.ThemeContext,
	assetIndices: Fusion.Value<types.AssetIndices>,
	assetRepo: types.AssetRepo,
	exportAssetRepoModalOpen: Fusion.Value<boolean>,
}

local function ExportRepoModal(scope: Fusion.Scope<typeof(Fusion)>, props: ExportRepoModalProps)
	local scope = scope:deriveScope({
		AssetForm = AssetForm,
		Modal = Modal,
		TextBox = TextBox,
		Button = Button,
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

			scope:Text {
				theme = props.theme,
				text = "Select and copy the text below",
			},

			scope:TextBox {
				theme = props.theme,
				backgroundColor = props.theme.bg_light,
				size = UDim2.new(1, 0, 0, 256),
				automaticSize = Enum.AutomaticSize.None,
				text = assetRegistry.exportAssetRepo(props.assetIndices, props.assetRepo.uid),
				textYAlignment = Enum.TextYAlignment.Top,
				textWrapped = true,
				editable = false,

				[Children] = scope:Border {
					theme = props.theme,
					radius = UDim.new(0, 6),
				},
			},

			scope:Button {
				theme = props.theme,
				backgroundColor = props.theme.bg_light,
				size = UDim2.new(1, 0, 0, 32),
				text = "Close",
				automaticSize = Enum.AutomaticSize.Y,

				onClick = function()
					props.exportAssetRepoModalOpen:set(false)
				end,

				[Children] = scope:Border {
					theme = props.theme,
					radius = UDim.new(0, 6),
				},
			},
		},
	}
end

return ExportRepoModal

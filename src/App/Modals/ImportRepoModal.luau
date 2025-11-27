local HttpService = game:GetService("HttpService")
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

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

type ImportRepoModalProps = {
	theme: Theme.ThemeContext,
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	selectedAssetRepo: Fusion.Value<types.AssetRepo?>,
	importAssetRepoModalOpen: Fusion.Value<boolean>,
}

local function ImportRepoModal(scope: Fusion.Scope<typeof(Fusion)>, props: ImportRepoModalProps)
	local scope = scope:deriveScope({
		AssetForm = AssetForm,
		Modal = Modal,
		TextBox = TextBox,
		Button = Button,
		Text = Text,
		Border = Border,
	})

	local data = scope:Value("")

	return scope:Modal {
		theme = props.theme,

		[Children] = Child {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			scope:Text {
				theme = props.theme,
				text = "Import Asset Repo",
			},

			scope:TextBox {
				theme = props.theme,
				backgroundColor = props.theme.bg_light,
				size = UDim2.new(1, 0, 0, 256),
				automaticSize = Enum.AutomaticSize.None,
				text = data,
				placeholderText = "https://github.com/....json or json data",
				textYAlignment = Enum.TextYAlignment.Top,
				textWrapped = true,

				onTextChanged = function(newText)
					data:set(newText)
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
							props.importAssetRepoModalOpen:set(false)
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},

					scope:Button {
						theme = props.theme,
						size = UDim2.new(1, 0, 0, 32),
						text = "Import",
						textColor = props.theme.bg,
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							props.importAssetRepoModalOpen:set(false)
							props.selectedAssetRepo:set(nil)

							if peek(data):match("^http") then
								assetRegistry.importAssetRepoFromUri(props.assetIndicies, peek(data))
							else
								assetRegistry.importAssetRepo(props.assetIndicies, HttpService:JSONDecode(peek(data)))
							end

							assetRegistry.update(props.assetIndicies)
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

return ImportRepoModal

local AssetRepoForm = require(script.Parent.AssetRepoForm)
local Input = require(script.Parent.Input)
local Modal = require(script.Parent.Parent.Modal)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.Parent.types)
local assetRegistry = require(script.Parent.Parent.Parent.utils.assetRegistry)
local Border = require(script.Parent.Parent.components.Border)
local Button = require(script.Parent.Parent.components.Button)
local Text = require(script.Parent.Parent.components.Text)

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

type CreateRepoModalProps = {
	theme: Theme.ThemeContext,
	assetIndices: Fusion.Value<types.AssetIndices>,
	createRepoModalOpen: Fusion.Value<boolean>,
}

local function CreateRepoModal(scope: Fusion.Scope<typeof(Fusion)>, props: CreateRepoModalProps)
	local scope = scope:deriveScope({
		AssetRepoForm = AssetRepoForm,
		Modal = Modal,
		Input = Input,
		Button = Button,
		Text = Text,
		Border = Border,
	})

	local uid = scope:Value("")
	local name = scope:Value("")
	local description = scope:Value("")
	local thumbnailUri = scope:Value("")
	local credits = scope:Value("")
	local repoVersion = scope:Value("")
	local conflicts = scope:Value({})

	return scope:Modal {
		theme = props.theme,

		[Children] = Child {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			scope:AssetRepoForm {
				theme = props.theme,
				uid = uid,
				name = name,
				description = description,
				thumbnailUri = thumbnailUri,
				credits = credits,
				version = repoVersion,
				conflicts = conflicts,
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
							props.createRepoModalOpen:set(false)
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},

					scope:Button {
						theme = props.theme,
						size = UDim2.new(1, 0, 0, 32),
						text = "Create Repo",
						textColor = props.theme.bg,
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							if
								peek(uid):match("^%s*$")
								or peek(name):match("^%s*$")
								or peek(description):match("^%s*$")
								or peek(credits):match("^%s*$")
								or peek(repoVersion):match("^%s*$")
							then
								return
							end

							props.createRepoModalOpen:set(false)

							assetRegistry.addRepo(props.assetIndices, peek(uid), {
								uid = peek(uid),
								name = peek(name),
								description = peek(description),
								thumbnailUri = peek(thumbnailUri),
								credits = peek(credits),
								version = peek(repoVersion),
								assetUids = {},
								conflicts = peek(conflicts),
								external = false,
								readonly = false,
							})

							assetRegistry.update(props.assetIndices)
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

return CreateRepoModal

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

-- TODO: turn this into a setting later on
local REQUIRED_DELETE_BUTTON_CLICKED = 25

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

type EditRepoModalProps = {
	theme: Theme.ThemeContext,
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	selectedAssetRepo: types.AssetRepo,
	selectedAssetRepoValue: Fusion.Value<types.AssetRepo?>,
	editRepoModalOpen: Fusion.Value<boolean>,
}

local function EditRepoModal(scope: Fusion.Scope<typeof(Fusion)>, props: EditRepoModalProps)
	local scope = scope:deriveScope({
		AssetRepoForm = AssetRepoForm,
		Modal = Modal,
		Input = Input,
		Button = Button,
		Text = Text,
		Border = Border,
	})

	local uid = scope:Value(props.selectedAssetRepo.uid)
	local name = scope:Value(props.selectedAssetRepo.name)
	local description = scope:Value(props.selectedAssetRepo.description)
	local thumbnailUri = scope:Value(props.selectedAssetRepo.thumbnailUri or "")
	local credits = scope:Value(props.selectedAssetRepo.credits)
	local repoVersion = scope:Value(props.selectedAssetRepo.version)

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
				Visible = not props.selectedAssetRepo.readonly,

				[Children] = scope:AssetRepoForm {
					theme = props.theme,
					uid = uid,
					name = name,
					description = description,
					thumbnailUri = thumbnailUri,
					credits = credits,
					version = repoVersion,
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
							props.editRepoModalOpen:set(false)
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
								then `Delete Repo (Last Chance)`
								else `Delete Repo ({REQUIRED_DELETE_BUTTON_CLICKED - use(deleteButtonClickedCount)})`
						end),
						automaticSize = Enum.AutomaticSize.Y,

						onClick = function()
							if peek(deleteButtonClickedCount) < REQUIRED_DELETE_BUTTON_CLICKED then
								deleteButtonClickedCount:set(peek(deleteButtonClickedCount) + 1)
								return
							end

							props.editRepoModalOpen:set(false)
							props.selectedAssetRepoValue:set(nil)

							assetRegistry.deleteAssetRepo(props.assetIndicies, props.selectedAssetRepo.uid)

							assetRegistry.update(props.assetIndicies)
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
				text = `Update Repo`,
				textColor = props.theme.bg,
				automaticSize = Enum.AutomaticSize.Y,
				visible = not props.selectedAssetRepo.readonly,

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

					props.editRepoModalOpen:set(false)

					local assetInidicies = peek(props.assetIndicies)

					if peek(uid) ~= props.selectedAssetRepo.uid then
						assetInidicies.assetRepos[peek(uid)] = assetInidicies.assetRepos[props.selectedAssetRepo.uid]
						assetInidicies.assetRepos[props.selectedAssetRepo.uid] = nil
					end

					local assetRepo = assetInidicies.assetRepos[peek(uid)]

					assetRepo.uid = peek(uid)
					assetRepo.name = peek(name)
					assetRepo.description = peek(description)
					assetRepo.thumbnailUri = peek(thumbnailUri)
					assetRepo.credits = peek(credits)
					assetRepo.version = peek(repoVersion)

					for _, assetUid in assetRepo.assetUids do
						local asset = assetInidicies.assets[assetUid]
						assert(asset, `unknown asset {assetUid}`);
						(asset :: any).assetRepo = assetRepo.uid
					end

					props.assetIndicies:set(assetInidicies)
					props.selectedAssetRepoValue:set(assetRepo)
				end,

				[Children] = scope:Border {
					theme = props.theme,
					radius = UDim.new(0, 6),
				},
			},
		},
	}
end

return EditRepoModal

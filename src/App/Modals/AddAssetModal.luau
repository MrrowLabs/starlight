local AssetForm = require(script.Parent.AssetForm)
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

type AddAssetModalProps = {
	theme: Theme.ThemeContext,
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	selection: Fusion.Computed<{ Instance }>,
	selectedAssetRepo: Fusion.Value<types.AssetRepo?>,
	addAssetModalOpen: Fusion.Value<boolean>,
}

local function AddAssetModal(scope: Fusion.Scope<typeof(Fusion)>, props: AddAssetModalProps)
	local scope = scope:deriveScope({
		AssetForm = AssetForm,
		Modal = Modal,
		Input = Input,
		Button = Button,
		Text = Text,
		Border = Border,
	})

	local name = scope:Value("")
	local credits = scope:Value("")
	local tags = scope:Value({})

	local isBulkImport = scope:Computed(function(use)
		return #use(props.selection) > 1
	end)

	return scope:Modal {
		theme = props.theme,

		[Children] = Child {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			scope:Text {
				theme = props.theme,
				text = scope:Computed(function(use)
					local selection = use(props.selection)

					if #selection == 0 then
						return `Please select something valid to add!`
					elseif #selection == 1 then
						return `You are adding <b>{selection[1]:GetFullName()}</b>`
					else
						return `You are <b>bulk adding {#selection} items!</b> <i>Will be using each instance name instead of manual input</i>`
					end
				end),
				textColor = props.theme.text_muted,
				textWrapped = true,
				size = UDim2.fromScale(1, 0),
			},

			scope:AssetForm {
				theme = props.theme,
				name = name,
				credits = credits,
				tags = tags,
				nameFieldDisabled = isBulkImport,
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
							props.addAssetModalOpen:set(false)
						end,

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 6),
						},
					},

					scope:Button {
						theme = props.theme,
						size = UDim2.new(1, 0, 0, 32),
						text = scope:Computed(function(use)
							local selectedAssetRepo = use(props.selectedAssetRepo)
							return `Add Asset{if selectedAssetRepo then ` to {selectedAssetRepo.name} repo` else ""}`
						end),
						textColor = props.theme.bg,
						automaticSize = Enum.AutomaticSize.Y,
						disabled = scope:Computed(function(use)
							return #use(props.selection) == 0
						end),

						onClick = function()
							if
								(peek(name):match("^%s*$") and not peek(isBulkImport)) or peek(credits):match("^%s*$")
							then
								return
							end

							props.addAssetModalOpen:set(false)

							for _, instance in peek(props.selection) do
								local assetUid = assetRegistry.addAssetFromInstance(props.assetIndicies, {
									name = if peek(isBulkImport) then instance.Name else peek(name),
									credits = peek(credits),
								}, instance)

								assetRegistry.addTags(props.assetIndicies, assetUid, table.unpack(peek(tags)))

								local selectedAssetRepo = peek(props.selectedAssetRepo)
								if selectedAssetRepo then
									assetRegistry.addAssetToAssetRepo(
										props.assetIndicies,
										assetUid,
										selectedAssetRepo.uid
									)
								end
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

return AddAssetModal

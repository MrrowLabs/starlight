local Input = require(script.Parent.Input)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local TagsRender = require(script.Parent.Parent.TagsRender)

local peek = Fusion.peek
local Children = Fusion.Children

type EditAssetFormProps = {
	theme: Theme.ThemeContext,
	name: Fusion.Value<string>,
	credits: Fusion.Value<string>,
	tags: Fusion.Value<{ string }>,
	nameFieldDisabled: Fusion.UsedAs<boolean>?,
}

local function EditAssetForm(scope: Fusion.Scope<typeof(Fusion)>, props: EditAssetFormProps)
	local scope = scope:deriveScope({
		TagsRender = TagsRender,
		Input = Input,
	})

	local rawTags = scope:Value(table.concat(peek(props.tags), " "))

	scope:Observer(rawTags):onChange(function()
		local newRawTags = peek(rawTags)
		local tags = {}

		for _, rawTag in newRawTags:split(" ") do
			if rawTag:match("^%s*$") then
				continue
			end

			table.insert(tags, (rawTag:gsub("^%s+", ""):gsub("%s+$", "")))
		end

		props.tags:set(tags)
	end)

	return scope:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		[Children] = {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			scope:Input {
				theme = props.theme,
				title = "Name",
				description = "Create a name for your asset! <i>This does support rich text by the way</i>",
				input = props.name,
				placeholder = "My really cool asset",
				disabled = props.nameFieldDisabled,
			},

			scope:Input {
				theme = props.theme,
				title = "Credit(s)",
				description = "Authors/contributors of the asset",
				input = props.credits,
				placeholder = "Me, myself, and I",
			},

			scope:Input {
				theme = props.theme,
				title = "Tags",
				description = "Add any tags to describe/seperate your asset. <i>Use spaces to seperate each tag</i>",
				input = rawTags,
				placeholder = "my, really, cool, asset",
			},

			scope:TagsRender {
				theme = props.theme,
				tags = props.tags,
			},
		},
	}
end

return EditAssetForm

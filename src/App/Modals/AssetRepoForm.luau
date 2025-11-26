local Input = require(script.Parent.Input)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)

local Children = Fusion.Children

type AssetRepoFormProps = {
	theme: Theme.ThemeContext,
	uid: Fusion.Value<string>,
	name: Fusion.Value<string>,
	description: Fusion.Value<string>,
	thumbnailUri: Fusion.Value<string>,
	credits: Fusion.Value<string>,
	version: Fusion.Value<string>,
}

local function AssetRepoForm(scope: Fusion.Scope<typeof(Fusion)>, props: AssetRepoFormProps)
	local scope = scope:deriveScope({
		Input = Input,
	})

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
				title = "Repo UID",
				description = "Create a unique id for your asset repo! <i>Mainly to prevent internal clashes with other repos</i>",
				input = props.uid,
				placeholder = "username/name",
			},

			scope:Input {
				theme = props.theme,
				title = "Name",
				description = "Create a unique name for your asset repo! <i>This does support rich text by the way</i>",
				input = props.name,
				placeholder = "My really cool repo",
			},

			scope:Input {
				theme = props.theme,
				title = "Description",
				description = "Describe what is in your repo",
				input = props.description,
				placeholder = "My really cool repo",
			},

			scope:Input {
				theme = props.theme,
				title = "Thumbnail",
				description = "Add a little flair to your repo!",
				input = props.thumbnailUri,
				placeholder = "rbxassetid://...",
			},

			scope:Input {
				theme = props.theme,
				title = "Credit(s)",
				description = "Authors/contributors of the repo",
				input = props.credits,
				placeholder = "Me, myself, and I",
			},

			scope:Input {
				theme = props.theme,
				title = "Version",
				description = "Show off how far the repo have come. <i>Recommended to follow the semver format</i>",
				input = props.version,
				placeholder = "x.x.x",
			},
		},
	}
end

return AssetRepoForm

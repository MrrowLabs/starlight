local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local serde = require(script.Parent.Parent.utils.serde)
local Border = require(script.Parent.components.Border)
local Text = require(script.Parent.components.Text)

local Children = Fusion.Children
local Child = Fusion.Child

type TextureAssetRenderProps = {
	theme: Theme.ThemeContext,
	asset: types.TextureAsset,
	[typeof(Children)]: Fusion.Child,
}

local function TextureAssetRender(scope: Fusion.Scope<typeof(Fusion)>, props: TextureAssetRenderProps)
	local scope = scope:deriveScope()

	-- TODO: visualize flipbook stuff

	return scope:New "ImageLabel" {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		Image = props.asset.inner.uri,

		[Children] = Child {
			scope:New "UIGradient" {
				Color = if props.asset.inner.color.type == "color3"
					then ColorSequence.new(serde.deserialize(props.asset.inner.color))
					else serde.deserialize(props.asset.inner.color),
			},

			props[Children],
		},
	}
end

type ScriptAssetRenderProps = {
	theme: Theme.ThemeContext,
	asset: types.ScriptAsset,
	[typeof(Children)]: Fusion.Child,
}

local function ScriptAssetRender(scope: Fusion.Scope<typeof(Fusion)>, props: ScriptAssetRenderProps)
	local scope = scope:deriveScope({
		Text = Text,
		Border = Border,
	})

	return scope:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Children] = scope:New "ImageLabel" {
			Size = UDim2.new(1, -24, 1, -24),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,

			Image = "rbxassetid://76418314632557",
			ImageColor3 = if props.asset.inner.scriptType == "server"
				then props.theme.text
				elseif props.asset.inner.scriptType == "module" then props.theme.red
				else props.theme.blue,

			[Children] = scope:Text {
				theme = props.theme,
				size = UDim2.fromScale(1, 1),
				automaticSize = Enum.AutomaticSize.None,
				text = props.asset.name,
				textSize = 18,
				textWrapped = true,
				textXAlignment = Enum.TextXAlignment.Center,

				[Children] = scope:Border {
					theme = props.theme,
					strokeColor = props.theme.bg_dark,
					strokeSize = 2,
					strokeType = Enum.ApplyStrokeMode.Contextual,
				},
			},
		},
	}
end

type AssetRenderProps = {
	theme: Theme.ThemeContext,
	asset: types.Asset,
	[typeof(Children)]: Fusion.Child,
}

local function AssetRender(scope: Fusion.Scope<typeof(Fusion)>, props: AssetRenderProps)
	local scope = scope:deriveScope({
		TextureAssetRender = TextureAssetRender,
		ScriptAssetRender = ScriptAssetRender,
	})

	return scope:Computed(function()
		if props.asset.type == "texture" then
			return scope:TextureAssetRender {
				theme = props.theme,
				asset = props.asset,
				[Children] = props[Children],
			}
		elseif props.asset.type == "script" then
			return scope:ScriptAssetRender {
				theme = props.theme,
				asset = props.asset,
				[Children] = props[Children],
			}
		end

		error(`unknown asset type {props.asset.type}`)
	end)
end

return AssetRender

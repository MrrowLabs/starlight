local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local serde = require(script.Parent.Parent.utils.serde)

local Children = Fusion.Children
local Child = Fusion.Child

type TextureAssetRenderProps = {
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

type AssetRenderProps = {
	asset: types.Asset,
	[typeof(Children)]: Fusion.Child,
}

local function AssetRender(scope: Fusion.Scope<typeof(Fusion)>, props: AssetRenderProps)
	local scope = scope:deriveScope({
		TextureAssetRender = TextureAssetRender,
	})

	return scope:Computed(function()
		if props.asset.type == "texture" then
			return scope:TextureAssetRender {
				asset = props.asset,
				[Children] = props[Children],
			}
		end

		error(`unknown asset type {props.asset.type}`)
	end)
end

return AssetRender

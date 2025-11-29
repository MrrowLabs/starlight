local RunService = game:GetService("RunService")
local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local serde = require(script.Parent.Parent.utils.serde)
local Border = require(script.Parent.components.Border)
local Text = require(script.Parent.components.Text)

local peek = Fusion.peek
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
				Color = if not props.asset.inner.color
					then ColorSequence.new(Color3.new(1, 1, 1))
					elseif props.asset.inner.color.type == "color3" then ColorSequence.new(
						serde.deserialize(props.asset.inner.color)
					)
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

type MeshAssetRenderProps = {
	theme: Theme.ThemeContext,
	asset: types.MeshAsset,
	[typeof(Children)]: Fusion.Child,
}

local function MeshAssetRender(scope: Fusion.Scope<typeof(Fusion)>, props: MeshAssetRenderProps)
	local scope = scope:deriveScope({
		Border = Border,
	})

	local rotation = scope:Value(0)

	local camera = scope:New "Camera" {
		-- CFrame = CFrame.new(0, 0, 16),
		CFrame = scope:Computed(function(use)
			return CFrame.Angles(0, math.rad(use(rotation)), 0) * CFrame.new(0, 0, props.asset.inner.size or 16)
		end),
	}

	local mesh = scope:New "Part" {
		Size = Vector3.zero,
		Anchored = true,

		[Children] = scope:New "SpecialMesh" {
			MeshId = props.asset.inner.uri,
			TextureId = props.asset.inner.textureUri,
			MeshType = Enum.MeshType.FileMesh,
		},
	}

	table.insert(
		scope,
		RunService.RenderStepped:Connect(function(delta)
			rotation:set(peek(rotation) + 45 * delta)
		end)
	)

	return scope:New "ViewportFrame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		CurrentCamera = camera,

		[Children] = mesh,
	}
end

type AudioAssetRenderProps = {
	theme: Theme.ThemeContext,
	asset: types.AudioAsset,
	[typeof(Children)]: Fusion.Child,
}

local function AudioAssetRender(scope: Fusion.Scope<typeof(Fusion)>, props: AudioAssetRenderProps)
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

			Image = "rbxassetid://112497830565876",
			ImageColor3 = props.theme.text,

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
		MeshAssetRender = MeshAssetRender,
		AudioAssetRender = AudioAssetRender,
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
		elseif props.asset.type == "mesh" then
			return scope:MeshAssetRender {
				theme = props.theme,
				asset = props.asset,
				[Children] = props[Children],
			}
		elseif props.asset.type == "audio" then
			return scope:AudioAssetRender {
				theme = props.theme,
				asset = props.asset,
				[Children] = props[Children],
			}
		end

		error(`unknown asset type {props.asset.type}`)
	end)
end

return AssetRender

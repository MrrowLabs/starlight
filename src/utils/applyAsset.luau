local ChangeHistoryService = game:GetService("ChangeHistoryService")
local types = require(script.Parent.Parent.types)
local averageColorSequence = require(script.Parent.averageColorSequence)
local serde = require(script.Parent.serde)

local function applyAsset(asset: types.Asset, selection: { Instance })
	if asset.type == "texture" then
		for _, instance in selection do
			if instance:IsA("ParticleEmitter") then
				instance.Texture = asset.inner.uri
				instance.Color = if asset.inner.color.type == "color3"
					then ColorSequence.new(serde.deserialize(asset.inner.color))
					else serde.deserialize(asset.inner.color)

				if asset.inner.flipbook then
					instance.FlipbookLayout = Enum.ParticleFlipbookLayout.Custom
					instance.FlipbookSizeX = asset.inner.flipbook.sizeX
					instance.FlipbookSizeY = asset.inner.flipbook.sizeY
					instance.FlipbookMode = Enum.ParticleFlipbookMode:FromValue(asset.inner.flipbook.mode)
						or Enum.ParticleFlipbookMode.Loop
					instance.FlipbookFramerate = serde.deserialize(asset.inner.flipbook.framerate)
					instance.FlipbookStartRandom = asset.inner.flipbook.startRandom
				end
			elseif instance:IsA("Beam") then
				instance.Texture = asset.inner.uri
				instance.Color = if asset.inner.color.type == "color3"
					then ColorSequence.new(serde.deserialize(asset.inner.color))
					else serde.deserialize(asset.inner.color)
			elseif instance:IsA("Decal") or instance:IsA("Texture") then
				-- luau lsp is going crazy??
				local instance: Decal = instance
				instance.Texture = asset.inner.uri
				instance.Color3 = if asset.inner.color.type == "color_sequence"
					then averageColorSequence(serde.deserialize(asset.inner.color))
					else serde.deserialize(asset.inner.color)
			elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
				-- TODO: probably report this as a bug on the luau lsp repo or smh
				local instance = instance :: ImageLabel
				instance.Image = asset.inner.uri
				instance.ImageColor3 = if asset.inner.color.type == "color_sequence"
					then averageColorSequence(serde.deserialize(asset.inner.color))
					else serde.deserialize(asset.inner.color)
			end
		end
	elseif asset.type == "script" then
		local scriptInstance = Instance.new(
			if asset.inner.scriptType == "server"
				then "Script"
				elseif asset.inner.scriptType == "module" then "ModuleScript"
				else "LocalScript"
		) :: Script
		scriptInstance.Source = asset.inner.source

		for _, instance in selection do
			scriptInstance:Clone().Parent = instance
		end
	else
		error(`unhandled asset type {asset.type}`)
	end

	ChangeHistoryService:SetWaypoint("Applied Assets")
end

return applyAsset

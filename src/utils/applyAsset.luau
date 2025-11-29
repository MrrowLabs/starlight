local AssetService = game:GetService("AssetService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local types = require(script.Parent.Parent.types)
local averageColorSequence = require(script.Parent.averageColorSequence)
local serde = require(script.Parent.serde)

local currentCamera = workspace.CurrentCamera

local function applyAsset(asset: types.Asset, selection: { Instance })
	if asset.type == "texture" then
		local assetColor: Color3 | ColorSequence = if asset.inner.color
			then serde.deserialize(asset.inner.color)
			else Color3.new(1, 1, 1)

		for _, instance in selection do
			if instance:IsA("ParticleEmitter") then
				instance.Texture = asset.inner.uri
				instance.Color = if typeof(assetColor) == "Color3" then ColorSequence.new(assetColor) else assetColor

				if asset.inner.flipbook then
					instance.FlipbookLayout = Enum.ParticleFlipbookLayout.Custom
					instance.FlipbookSizeX = asset.inner.flipbook.sizeX
					instance.FlipbookSizeY = asset.inner.flipbook.sizeY
					instance.FlipbookMode = (Enum.ParticleFlipbookMode):FromValue(asset.inner.flipbook.mode) -- () SILENTS THE SELENE ERROR LOL
						or Enum.ParticleFlipbookMode.Loop
					instance.FlipbookFramerate = serde.deserialize(asset.inner.flipbook.framerate)
					instance.FlipbookStartRandom = asset.inner.flipbook.startRandom
				end
			elseif instance:IsA("Beam") then
				instance.Texture = asset.inner.uri
				instance.Color = if typeof(assetColor) == "Color3" then ColorSequence.new(assetColor) else assetColor
			elseif instance:IsA("Decal") or instance:IsA("Texture") then
				-- luau lsp is going crazy??
				local instance: Decal = instance
				instance.Texture = asset.inner.uri
				instance.Color3 = if typeof(assetColor) == "ColorSequence"
					then averageColorSequence(assetColor)
					else assetColor
			elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
				-- TODO: probably report this as a bug on the luau lsp repo or smh
				local instance = instance :: ImageLabel
				instance.Image = asset.inner.uri
				instance.ImageColor3 = if typeof(assetColor) == "ColorSequence"
					then averageColorSequence(assetColor)
					else assetColor
			end
		end
	elseif asset.type == "script" then
		local scriptInstance = Instance.new(
			if asset.inner.scriptType == "server"
				then "Script"
				elseif asset.inner.scriptType == "module" then "ModuleScript"
				else "LocalScript"
		) :: Script
		scriptInstance.Name = asset.name
		scriptInstance.Source = asset.inner.source

		if #selection == 0 then
			scriptInstance.Parent = workspace
			return
		end

		for _, instance in selection do
			scriptInstance:Clone().Parent = instance
		end
	elseif asset.type == "mesh" then
		local mesh = AssetService:CreateMeshPartAsync(Content.fromUri(asset.inner.uri))
		mesh.Name = asset.name

		if asset.inner.textureUri then
			mesh.TextureContent = Content.fromUri(asset.inner.textureUri)
		end

		if #selection == 0 then
			mesh.Position = (currentCamera.CFrame * CFrame.new(0, 0, -(asset.inner.size or 16))).Position
			mesh.Parent = workspace
			return
		end

		for _, instance in selection do
			if instance:IsA("MeshPart") then
				instance:ApplyMesh(mesh)
				continue
			elseif instance:IsA("SpecialMesh") then
				instance.MeshId = mesh.MeshId
				instance.TextureId = mesh.TextureID
				continue
			end

			mesh:Clone().Parent = instance
		end
	elseif asset.type == "audio" then
		local audio = Instance.new("Sound")
		audio.Name = asset.name
		audio.SoundId = asset.inner.uri

		if #selection == 0 then
			audio.Parent = workspace
			return
		end

		for _, instance in selection do
			if instance:IsA("Sound") then
				instance.SoundId = audio.SoundId
				continue
			end

			audio:Clone().Parent = instance
		end
	else
		error(`unhandled asset type {asset.type}`)
	end

	ChangeHistoryService:SetWaypoint("Applied Assets")
end

return applyAsset

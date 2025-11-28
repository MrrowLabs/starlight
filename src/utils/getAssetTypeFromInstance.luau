local types = require(script.Parent.Parent.types)

local function getAssetTypeFromInstance(instance: Instance): types.AssetTypes?
	return if instance:IsA("ParticleEmitter")
			or instance:IsA("Beam")
			or instance:IsA("Decal")
			or instance:IsA("Texture")
			or instance:IsA("ImageLabel")
			or instance:IsA("ImageButton")
		then "texture"
		elseif instance:IsA("Script") or instance:IsA("ModuleScript") or instance:IsA("LocalScript") then "script"
		elseif instance:IsA("MeshPart") or instance:IsA("SpecialMesh") then "mesh"
		elseif instance:IsA("Sound") then "audio"
		else nil
end

return getAssetTypeFromInstance

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
		else nil
end

return getAssetTypeFromInstance

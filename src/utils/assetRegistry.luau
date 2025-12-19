local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local getAssetTypeFromInstance = require(script.Parent.getAssetTypeFromInstance)
local json = require(script.Parent.json)
local serde = require(script.Parent.serde)
local unwrapPcallOr = require(script.Parent.unwrapPcallOr)
local values = require(script.Parent.values)

local peek = Fusion.peek

local assetRegistry = {}

local FLIPBOOK_LAYOUT_CONVERSIONS = {
	[Enum.ParticleFlipbookLayout.Grid2x2] = 2,
	[Enum.ParticleFlipbookLayout.Grid4x4] = 4,
	[Enum.ParticleFlipbookLayout.Grid8x8] = 8,
}

type AssetMetadata = { name: string, credits: string }

function assetRegistry.update(assetIndices: Fusion.Value<types.AssetIndices>)
	assetIndices:set(peek(assetIndices), true)
end

function assetRegistry.getAsset(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string): types.Asset?
	return peek(assetIndices).assets[assetUid]
end

function assetRegistry.getAssetRepo(
	assetIndices: Fusion.Value<types.AssetIndices>,
	assetRepoUid: string
): types.AssetRepo?
	return peek(assetIndices).assetRepos[assetRepoUid]
end

function assetRegistry.getTagged(assetIndices: Fusion.Value<types.AssetIndices>, tag: string): types.Set<string>
	local taggedAssetsUids = peek(assetIndices).assetTags[tag]
	assert(taggedAssetsUids, `unknown asset {tag}`)
	return taggedAssetsUids
end

-- returns a uid of the created asset
function assetRegistry.addAssetFromInstance(
	assetIndices: Fusion.Value<types.AssetIndices>,
	metadata: AssetMetadata,
	instance: Instance
): string
	local uid = HttpService:GenerateGUID(false)

	local assetType = getAssetTypeFromInstance(instance)
	assert(assetType, `unknown asset for {instance}`)

	-- i think the intellisense hates me :wilted_rose:
	-- just show me the types of texture or script 🙏🙏🙏

	if assetType == "texture" then
		local instance = instance :: types.TextureAssetInstanceTypes

		local textureUri = if instance:IsA("ParticleEmitter")
				or instance:IsA("Beam")
				or instance:IsA("Decal")
				or instance:IsA("Texture")
			then instance.Texture
			else instance.Image
		local textureColor = if instance:IsA("ParticleEmitter") or instance:IsA("Beam")
			then serde.serializeColorSequence(instance.Color)
			elseif instance:IsA("Decal") or instance:IsA("Texture") then serde.serializeColor3(instance.Color3)
			else serde.serializeColor3(instance.ImageColor3)
		local flipbookData = if instance:IsA("ParticleEmitter")
				and instance.FlipbookLayout ~= Enum.ParticleFlipbookLayout.None
			then {
				mode = instance.FlipbookMode.Value,
				framerate = serde.serializeNumberRange(instance.FlipbookFramerate),
				sizeX = FLIPBOOK_LAYOUT_CONVERSIONS[instance.FlipbookLayout] or instance.FlipbookSizeX,
				sizeY = FLIPBOOK_LAYOUT_CONVERSIONS[instance.FlipbookLayout] or instance.FlipbookSizeY,
				startRandom = instance.FlipbookStartRandom,
				textureSize = serde.serializeVector2(
					unwrapPcallOr(
						{ Size = Vector2.one * 1024 },
						AssetService.CreateEditableImageAsync,
						AssetService,
						Content.fromUri(textureUri)
					).Size
				),
			}
			else nil

		assetRegistry.addAsset(assetIndices, uid, "texture", metadata, {
			uri = textureUri,
			color = if textureColor.type == "color3" and serde.deserialize(textureColor) == Color3.new(1, 1, 1)
					or textureColor.type == "color_sequence"
						and serde.deserialize(textureColor) == ColorSequence.new(Color3.new(1, 1, 1))
				then nil
				else textureColor,
			flipbook = flipbookData,
		})
	elseif assetType == "script" then
		local instance = instance :: types.ScriptAssetInstanceTypes

		assetRegistry.addAsset(assetIndices, uid, "script", metadata, {
			scriptType = if instance:IsA("LocalScript")
				then "client"
				elseif instance:IsA("ModuleScript") then "module"
				else "server",
			source = instance.Source,
		})
	elseif assetType == "mesh" then
		local instance = instance :: types.MeshAssetInstanceTypes

		assetRegistry.addAsset(assetIndices, uid, "mesh", metadata, {
			uri = instance.MeshId,
			textureUri = if instance:IsA("MeshPart") then instance.TextureContent.Uri else instance.TextureId,
			size = if instance:IsA("MeshPart") then instance.Size.Magnitude else nil,
		})
	elseif assetType == "audio" then
		local instance = instance :: types.AudioAssetInstanceTypes

		assetRegistry.addAsset(assetIndices, uid, "audio", metadata, {
			uri = instance.SoundId,
		})
	end

	return uid
end

function assetRegistry.addAsset(
	assetIndices: Fusion.Value<types.AssetIndices>,
	uid: string,
	assetType: string,
	metadata: AssetMetadata,
	props: types.AssetProps
)
	assert(not peek(assetIndices).assets[uid], `asset with uid {uid} already exists`)
	peek(assetIndices).assets[uid] = {
		type = assetType,
		uid = uid,
		name = metadata.name,
		credits = metadata.credits,
		tags = {},
		inner = props,
	} :: types.BaseAsset
	peek(assetIndices).assetUids[uid] = uid
end

function assetRegistry.addRepo(assetIndices: Fusion.Value<types.AssetIndices>, uid: string, props: types.AssetRepo)
	assert(not peek(assetIndices).assetRepos[uid], `asset repo with uid {uid} already exists`)
	peek(assetIndices).assetRepos[uid] = props
end

function assetRegistry.addTags(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string, ...: string)
	local asset = peek(assetIndices).assets[assetUid]
	assert(asset, `unknown asset {assetUid}`)
	local assetTags = peek(assetIndices).assetTags

	for _, tag in { ... } do
		asset.tags[tag] = tag

		if not assetTags[tag] then
			assetTags[tag] = {}
		end

		assert(assetTags[tag], `missing tags table for {tag}`)
		assetTags[tag][assetUid] = assetUid
	end
end

function assetRegistry.favoriteAsset(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string)
	assert(peek(assetIndices).assets[assetUid], `asset {assetUid} does not exist`)
	peek(assetIndices).favorites[assetUid] = assetUid
end

function assetRegistry.unfavoriteAsset(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string)
	assert(peek(assetIndices).assets[assetUid], `asset {assetUid} does not exist`)
	peek(assetIndices).favorites[assetUid] = nil
end

function assetRegistry.removeTags(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string, ...: string)
	local asset = peek(assetIndices).assets[assetUid]
	local assetTags = peek(assetIndices).assetTags

	for _, tag in { ... } do
		if not asset.tags[tag] then
			continue
		end

		asset.tags[tag] = nil

		if not assetTags[tag] then
			continue
		end

		assert(assetTags[tag], `missing tags table for {tag}`)
		assetTags[tag][assetUid] = nil

		-- should work on checking if the array is empty
		if next(assetTags[tag]) == nil then
			assetTags[tag] = nil
		end
	end
end

function assetRegistry.addAssetToAssetRepo(
	assetIndices: Fusion.Value<types.AssetIndices>,
	assetUid: string,
	assetRepoUid: string
)
	local assetRepo = peek(assetIndices).assetRepos[assetRepoUid]
	local asset = peek(assetIndices).assets[assetUid]

	assert(assetRepo, `asset repo {assetRepoUid} does not exist`)
	assert(asset, `asset {assetUid} does not exist`)
	assert(not assetRepo.readonly, `asset repo {assetRepoUid} is readonly`)
	assert(not asset.assetRepo, `asset {assetUid} aleady exists in {asset.assetRepo}`)

	assetRepo.assetUids[assetUid] = assetUid;
	(asset :: any).assetRepo = assetRepoUid
end

function assetRegistry.removeAssetFromRepo(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string)
	local asset = peek(assetIndices).assets[assetUid]

	assert(asset, `asset {assetUid} does not exist`)
	assert(asset.assetRepo, `asset {assetUid} does not belong in an asset repo`)

	local previousAssetRepo = peek(assetIndices).assetRepos[asset.assetRepo]

	assert(previousAssetRepo, `previous asset repo {asset.assetRepo} does not exist`)
	assert(not previousAssetRepo.readonly, `previous asset repo {asset.assetRepo} is readonly`)

	previousAssetRepo.assetUids[assetUid] = nil
	(asset :: any).assetRepo = nil
end

function assetRegistry.deleteAsset(
	assetIndices: Fusion.Value<types.AssetIndices>,
	assetUid: string,
	keepFavorite: boolean?
)
	local asset = peek(assetIndices).assets[assetUid]
	assert(asset, `asset {assetUid} does not exist`)

	assetRegistry.removeTags(assetIndices, assetUid, table.unpack(values(asset.tags)))
	if not keepFavorite then
		peek(assetIndices).favorites[assetUid] = nil
	end
	peek(assetIndices).assetUids[assetUid] = nil
	peek(assetIndices).assets[assetUid] = nil
	if asset.assetRepo then
		local assetRepo = assetRegistry.getAssetRepo(assetIndices, asset.assetRepo)
		assert(assetRepo, `asset repo {asset.assetRepo} does not exist`)
		assetRepo.assetUids[assetUid] = nil
	end
end

function assetRegistry.deleteAssetRepo(
	assetIndices: Fusion.Value<types.AssetIndices>,
	assetRepoUid: string,
	saveFavorites: boolean?
)
	local assetRepo = peek(assetIndices).assetRepos[assetRepoUid]
	assert(assetRepo, `asset repo {assetRepoUid} does not exist`)

	for _, assetUid in assetRepo.assetUids do
		assetRegistry.deleteAsset(assetIndices, assetUid, saveFavorites)
	end

	peek(assetIndices).assetRepos[assetRepoUid] = nil
end

function assetRegistry.exportAsset(assetIndices: Fusion.Value<types.AssetIndices>, assetUid: string): types.AssetExport
	local asset = assetRegistry.getAsset(assetIndices, assetUid)
	assert(asset, `unknown asset {assetUid}`)
	return {
		type = asset.type,
		uid = asset.uid,
		name = asset.name,
		credits = asset.credits,
		tags = values(asset.tags),
		inner = asset.inner,
	}
end

function assetRegistry.exportAssetRepo(assetIndices: Fusion.Value<types.AssetIndices>, assetRepoUid: string): string
	local assetRepo = assetRegistry.getAssetRepo(assetIndices, assetRepoUid)
	assert(assetRepo, `asset repo {assetRepoUid} does not exist`)

	local assetRepoExport: types.AssetRepoExport = {
		uid = assetRepo.uid,
		name = assetRepo.name,
		nameThumbnailUri = assetRepo.nameThumbnailUri,
		description = assetRepo.description,
		thumbnailUri = assetRepo.thumbnailUri,
		credits = assetRepo.credits,
		version = assetRepo.version,
		assets = {},
		conflicts = assetRepo.conflicts,
	}

	for _, assetUid in assetRepo.assetUids do
		local asset = assetRegistry.getAsset(assetIndices, assetUid)
		assert(asset, `asset {assetUid} does not exist`)
		table.insert(assetRepoExport.assets, assetRegistry.exportAsset(assetIndices, assetUid))
	end

	return json.encode(assetRepoExport)
end

function assetRegistry.getAssetExportsFromExternalAssetRepoUris(
	externalAssetRepoUris: { string }
): { types.AssetExport }
	local assetExports = {}

	for _, externalAssetRepoUri in externalAssetRepoUris do
		local assetRepoExport = assetRegistry.loadAssetRepoDataFromUri(externalAssetRepoUri)

		for _, assetExport in assetRepoExport.assets do
			table.insert(assetExports, assetExport)
		end
	end

	return assetExports
end

type ImportAssetRepoExtra = {
	external: boolean?,
	externalUri: string?,
	readonly: boolean?,
}

function assetRegistry.importAssetRepo(
	assetIndices: Fusion.Value<types.AssetIndices>,
	assetRepoExport: types.AssetRepoExport,
	extra: ImportAssetRepoExtra
)
	local extra: ImportAssetRepoExtra = extra or {}

	if assetRegistry.getAssetRepo(assetIndices, assetRepoExport.uid) then
		assetRegistry.deleteAssetRepo(assetIndices, assetRepoExport.uid, true)
	end

	assetRegistry.addRepo(assetIndices, assetRepoExport.uid, {
		uid = assetRepoExport.uid,
		name = assetRepoExport.name,
		nameThumbnailUri = assetRepoExport.nameThumbnailUri,
		description = assetRepoExport.description,
		thumbnailUri = assetRepoExport.thumbnailUri,
		credits = assetRepoExport.credits,
		version = assetRepoExport.version,
		assetUids = {},
		external = false,
		readonly = false,
		conflicts = assetRepoExport.conflicts or {},
	})

	local importAssetExport = function(assetExport: types.AssetExport)
		assetRegistry.addAsset(assetIndices, assetExport.uid, assetExport.type, {
			credits = assetExport.credits,
			name = assetExport.name,
		}, assetExport.inner)
		assetRegistry.addTags(assetIndices, assetExport.uid, table.unpack(values(assetExport.tags)))
		assetRegistry.addAssetToAssetRepo(assetIndices, assetExport.uid, assetRepoExport.uid)
	end

	for _, assetExport in assetRepoExport.assets do
		importAssetExport(assetExport)
	end

	if assetRepoExport.externalAssetRepoUris then
		for _, externalAssetExport in
			assetRegistry.getAssetExportsFromExternalAssetRepoUris(assetRepoExport.externalAssetRepoUris)
		do
			importAssetExport(externalAssetExport)
		end
	end

	local assetRepo = assetRegistry.getAssetRepo(assetIndices, assetRepoExport.uid)
	assert(assetRepo, `unknown asset repo {assetRepoExport.uid}`)
	assetRepo.external = extra.external or false
	assetRepo.externalUri = extra.externalUri
	assetRepo.readonly = extra.readonly or false

	for favoriteAssetUid in peek(assetIndices).favorites do
		if not peek(assetIndices).assets[favoriteAssetUid] then
			peek(assetIndices).favorites[favoriteAssetUid] = nil
		end
	end
end

function assetRegistry.loadAssetRepoDataFromUri(uri: string): types.AssetRepoExport
	local ok, response = pcall(HttpService.GetAsync, HttpService, uri)
	assert(ok, `failed to import asset repo data from {uri}`)

	return json.decode(response)
end

function assetRegistry.importAssetRepoFromUri(assetIndices: Fusion.Value<types.AssetIndices>, uri: string)
	local assetRepoExport: types.AssetRepoExport = assetRegistry.loadAssetRepoDataFromUri(uri)

	for _, assetRepo in peek(assetIndices).assetRepos do
		if assetRepo.conflicts and table.find(assetRepo.conflicts, assetRepoExport.uid) then
			warn(
				`{assetRepo.name} ({assetRepo.uid}) conflicts with {assetRepoExport.name} ({assetRepoExport.uid}). Please uninstall {assetRepo.name} if you wish to install {assetRepoExport.name}`
			)
			return
		end
	end

	-- TODO: probably validate the data

	assetRegistry.importAssetRepo(assetIndices, assetRepoExport, {
		external = true,
		externalUri = uri,
		readonly = if assetRepoExport.readonly ~= nil then assetRepoExport.readonly else true,
	})
end

return assetRegistry

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local serde = require(script.Parent.serde)
local values = require(script.Parent.values)

local peek = Fusion.peek

local assetRegistry = {}

local FLIPBOOK_LAYOUT_CONVERSIONS = {
	[Enum.ParticleFlipbookLayout.Grid2x2] = 2,
	[Enum.ParticleFlipbookLayout.Grid4x4] = 4,
	[Enum.ParticleFlipbookLayout.Grid8x8] = 8,
}

type AssetMetadata = { type: types.AssetTypes, name: string, credits: string }

function assetRegistry.getAsset(assetIndicies: Fusion.Value<types.AssetIndicies>, assetUid: string): types.Asset?
	return peek(assetIndicies).assets[assetUid]
end

function assetRegistry.getAssetRepo(
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	assetRepoUid: string
): types.AssetRepo?
	return peek(assetIndicies).assetRepos[assetRepoUid]
end

function assetRegistry.getTagged(assetIndicies: Fusion.Value<types.AssetIndicies>, tag: string): types.Set<string>
	local taggedAssetsUids = peek(assetIndicies).assetTags[tag]
	assert(taggedAssetsUids, `unknown asset {tag}`)
	return taggedAssetsUids
end

-- returns a uid of the created asset
function assetRegistry.addAssetFromInstance(
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	metadata: AssetMetadata,
	instance: Instance
): string
	local uid = HttpService:GenerateGUID()

	if
		instance:IsA("ParticleEmitter")
		or instance:IsA("Beam")
		or instance:IsA("Decal")
		or instance:IsA("Texture")
		or instance:IsA("ImageLabel")
		or instance:IsA("ImageButton")
	then
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
					AssetService:CreateEditableImageAsync(Content.fromUri(textureUri)).Size
				),
			}
			else nil

		assetRegistry.addAsset(assetIndicies, uid, metadata, {
			uri = textureUri,
			color = textureColor,
			flipbook = flipbookData,
		})
	else
		error(`invalid instance type {instance.ClassName}`)
	end

	return uid
end

function assetRegistry.addAsset(
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	uid: string,
	metadata: AssetMetadata,
	props: types.AssetProps
)
	assert(not peek(assetIndicies).assets[uid], `asset with uid {uid} already exists`)
	peek(assetIndicies).assets[uid] = {
		type = metadata.type,
		uid = uid,
		name = metadata.name,
		credits = metadata.credits,
		tags = {},
		inner = props,
	}
	peek(assetIndicies).assetUids[uid] = uid
	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.addRepo(assetIndicies: Fusion.Value<types.AssetIndicies>, uid: string, props: types.AssetRepo)
	assert(not peek(assetIndicies).assetRepos[uid], `asset repo with uid {uid} already exists`)
	peek(assetIndicies).assetRepos[uid] = props
	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.addTags(assetIndicies: Fusion.Value<types.AssetIndicies>, assetUid: string, ...: string)
	local asset = peek(assetIndicies).assets[assetUid]
	assert(asset, `unknown asset {assetUid}`)
	local assetTags = peek(assetIndicies).assetTags

	for _, tag in { ... } do
		asset.tags[tag] = tag

		if not assetTags[tag] then
			assetTags[tag] = {}
		end

		assert(assetTags[tag], `missing tags table for {tag}`)
		assetTags[tag][assetUid] = assetUid
	end

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.favoriteAsset(assetIndicies: Fusion.Value<types.AssetIndicies>, assetUid: string)
	assert(peek(assetIndicies).assets[assetUid], `asset {assetUid} does not exist`)
	peek(assetIndicies).favorites[assetUid] = assetUid
	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.unfavoriteAsset(assetIndicies: Fusion.Value<types.AssetIndicies>, assetUid: string)
	assert(peek(assetIndicies).assets[assetUid], `asset {assetUid} does not exist`)
	peek(assetIndicies).favorites[assetUid] = nil
	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.removeTags(assetIndicies: Fusion.Value<types.AssetIndicies>, assetUid: string, ...: string)
	local asset = peek(assetIndicies).assets[assetUid]
	local assetTags = peek(assetIndicies).assetTags

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

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.addAssetToAssetRepo(
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	assetUid: string,
	assetRepoUid: string
)
	local assetRepo = peek(assetIndicies).assetRepos[assetRepoUid]
	local asset = peek(assetIndicies).assets[assetUid]

	assert(assetRepo, `asset repo {assetRepoUid} does not exist`)
	assert(asset, `asset {assetUid} does not exist`)
	assert(not assetRepo.readonly, `asset repo {assetRepoUid} is readonly`)
	assert(not asset.assetRepo, `asset {assetUid} aleady exists in {asset.assetRepo}`)

	assetRepo.assetUids[assetUid] = assetUid;
	(asset :: any).assetRepo = assetRepoUid

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.removeAssetFromRepo(
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	assetUid: string,
	assetRepoUid: string
)
	local asset = peek(assetIndicies).assets[assetUid]

	assert(asset, `asset {assetUid} does not exist`)
	assert(asset.assetRepo, `asset {assetUid} does not belong in an asset repo`)

	local previousAssetRepo = peek(assetIndicies).assetRepos[asset.assetRepo]

	assert(previousAssetRepo, `previous asset repo {asset.assetRepo} does not exist`)
	assert(not previousAssetRepo.readonly, `previous asset repo {asset.assetRepo} is readonly`)

	previousAssetRepo.assetUids[assetUid] = nil
	(asset :: any).assetRepo = nil

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.deleteAsset(assetIndicies: Fusion.Value<types.AssetIndicies>, assetUid: string)
	local asset = peek(assetIndicies).assets[assetUid]
	assert(asset, `asset {assetUid} does not exist`)

	assetRegistry.removeTags(assetIndicies, assetUid, table.unpack(values(asset.tags)))
	peek(assetIndicies).favorites[assetUid] = nil
	peek(assetIndicies).assetUids[assetUid] = nil
	peek(assetIndicies).assets[assetUid] = nil

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.deleteAssetRepo(assetIndicies: Fusion.Value<types.AssetIndicies>, assetRepoUid: string)
	local assetRepo = peek(assetIndicies).assetRepos[assetRepoUid]
	assert(assetRepo, `asset repo {assetRepoUid} does not exist`)

	for _, assetUid in assetRepo.assetUids do
		assetRegistry.deleteAsset(assetIndicies, assetUid)
	end

	peek(assetIndicies).assetRepos[assetRepoUid] = nil

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.exportAssetRepo(assetIndicies: Fusion.Value<types.AssetIndicies>, assetRepoUid: string): string
	local assetRepo = assetRegistry.getAssetRepo(assetIndicies, assetRepoUid)
	assert(assetRepo, `asset repo {assetRepoUid} does not exist`)

	local assetRepoExport: types.AssetRepoExport = {
		uid = assetRepo.uid,
		name = assetRepo.name,
		description = assetRepo.description,
		thumbnailUri = assetRepo.thumbnailUri,
		credits = assetRepo.credits,
		version = assetRepo.version,
		assets = {},
	}

	for _, assetUid in assetRepo.assetUids do
		local asset = assetRegistry.getAsset(assetIndicies, assetUid)
		assert(asset, `asset {assetUid} does not exist`)
		assetRepoExport.assets[assetUid] = asset
	end

	return HttpService:JSONEncode(assetRepoExport)
end

type ImportAssetRepoExtra = {
	external: boolean?,
	externalUri: string?,
	readonly: boolean?,
}

function assetRegistry.importAssetRepo(
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	assetRepoExport: types.AssetRepoExport,
	extra: ImportAssetRepoExtra
)
	local extra: ImportAssetRepoExtra = extra or {}

	if assetRegistry.getAssetRepo(assetIndicies, assetRepoExport.uid) then
		assetRegistry.deleteAssetRepo(assetIndicies, assetRepoExport.uid)
	end

	assetRegistry.addRepo(assetIndicies, assetRepoExport.uid, {
		uid = assetRepoExport.uid,
		name = assetRepoExport.name,
		description = assetRepoExport.description,
		thumbnailUri = assetRepoExport.thumbnailUri,
		credits = assetRepoExport.credits,
		version = assetRepoExport.version,
		assetUids = {},
		external = false,
		readonly = false,
	})

	for uid, asset: types.BaseAsset in assetRepoExport.assets do
		assetRegistry.addAsset(assetIndicies, uid, {
			type = asset.type,
			credits = asset.credits,
			name = asset.name,
		}, asset.inner)
		assetRegistry.addTags(assetIndicies, uid, table.unpack(values(asset.tags)))
		assetRegistry.addAssetToAssetRepo(assetIndicies, uid, assetRepoExport.uid)
	end

	local assetRepo = assetRegistry.getAssetRepo(assetIndicies, assetRepoExport.uid)
	assert(assetRepo, `unknown asset repo {assetRepoExport.uid}`)
	assetRepo.external = extra.external or false
	assetRepo.externalUri = extra.externalUri
	assetRepo.readonly = extra.readonly or false

	assetIndicies:set(peek(assetIndicies))
end

function assetRegistry.importAssetRepoFromUri(assetIndicies: Fusion.Value<types.AssetIndicies>, uri: string)
	local ok, response = pcall(HttpService.GetAsync, HttpService, uri)

	if not ok then
		warn(`Failed to import asset repo from {uri}`)
		return
	end

	local assetRepoExport: types.AssetRepoExport = HttpService:JSONDecode(response)

	-- TODO: probably validate the data

	assetRegistry.importAssetRepo(assetIndicies, assetRepoExport, {
		external = true,
		externalUri = uri,
		readonly = true,
	})
end

return assetRegistry

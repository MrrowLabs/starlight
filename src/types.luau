local Fusion = require(script.Parent.packages.Fusion)
local serde = require(script.Parent.utils.serde)

export type Set<T> = { [T]: T }

export type AppScope<T = {}> = Fusion.Scope<typeof(Fusion) & {
	plugin: Plugin,
} & T>

export type AssetTypes = "texture"

export type BaseAsset<T = any, I = any> = {
	type: T,
	uid: string,
	name: string,
	credits: string,
	tags: Set<string>,
	assetRepo: string?,
	inner: I,
}

export type TextureAssetProps = {
	uri: string,
	color: serde.SerializedColor3 | serde.SerializedColorSequence,
	flipbook: {
		mode: number,
		framerate: serde.SerializedNumberRange,
		sizeX: number,
		sizeY: number,
		startRandom: boolean,
		textureSize: serde.SerializedVector2, -- more for visual stuff
	}?,
}

export type TextureAsset = BaseAsset<"texture", TextureAssetProps>

export type AssetProps = TextureAssetProps

export type Asset = TextureAsset

export type AssetRepo = {
	uid: string,
	name: string, -- most likely in the form of username/name (like a repo)
	description: string,
	thumbnailUri: string?,
	credits: string,
	version: string,
	assetUids: Set<string>,
	external: boolean,
	externalUri: string?,
	readonly: boolean,
}

export type AssetRepoExport = {
	uid: string,
	name: string,
	description: string,
	thumbnailUri: string?,
	credits: string,
	version: string,
	assets: { [string]: Asset },
}

export type AssetIndicies = {
	-- in the form of uid: Asset object
	-- also the more internal index
	assets: { [string]: Asset },
	assetUids: Set<string>,
	assetTags: { [string]: Set<string> },
	assetRepos: { [string]: AssetRepo },
	favorites: Set<string>,
}

return {}

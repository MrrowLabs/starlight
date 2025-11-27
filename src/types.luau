local Fusion = require(script.Parent.packages.Fusion)
local serde = require(script.Parent.utils.serde)

export type Set<T> = { [T]: T }

export type AppScope<T = {}> = Fusion.Scope<typeof(Fusion) & {
	plugin: Plugin,
} & T>

export type AssetTypes = "texture" | "script"

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

export type TextureAssetInstanceTypes = ParticleEmitter | Beam | Decal | Texture | ImageLabel | ImageButton

export type ScriptAssetProps = {
	scriptType: "server" | "client" | "module",
	source: string,
}

export type ScriptAsset = BaseAsset<"script", ScriptAssetProps>

export type ScriptAssetInstanceTypes = Script | ModuleScript | LocalScript

export type AssetProps = TextureAssetProps | ScriptAssetProps

export type Asset = TextureAsset | ScriptAsset

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

export type AssetIndices = {
	-- in the form of uid: Asset object
	-- also the more internal index
	assets: { [string]: Asset },
	assetUids: Set<string>,
	assetTags: { [string]: Set<string> },
	assetRepos: { [string]: AssetRepo },
	favorites: Set<string>,
}

export type AssetExport = {
	type: string,
	uid: string,
	name: string,
	credits: string,
	tags: { string },
	inner: any,
}

export type AssetRepoExport = {
	uid: string,
	name: string,
	description: string,
	thumbnailUri: string?,
	credits: string,
	version: string,
	assets: { AssetExport },
}

return {}

local AddAssetModal = require(script.AddAssetModal)
local CreateRepoModal = require(script.CreateRepoModal)
local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local AssetDetailsModal = require(script.AssetDetailsModal)
local EditAssetModal = require(script.EditAssetModal)
local EditRepoModal = require(script.EditRepoModal)
local ExportRepoModal = require(script.ExportRepoModal)
local ImportRepoModal = require(script.ImportRepoModal)

local Children = Fusion.Children
local Child = Fusion.Child

type ModalsProps = {
	theme: Theme.ThemeContext,
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	rawSelection: Fusion.Value<{ Instance }>,
	selection: Fusion.Computed<{ Instance }>,
	selectedAsset: Fusion.Value<types.Asset?>,
	selectedAssetRepo: Fusion.Value<types.AssetRepo?>,
	createRepoModalOpen: Fusion.Value<boolean>,
	editRepoModalOpen: Fusion.Value<boolean>,
	importRepoModalOpen: Fusion.Value<boolean>,
	exportRepoModalOpen: Fusion.Value<boolean>,
	addAssetModalOpen: Fusion.Value<boolean>,
	editAssetModalOpen: Fusion.Value<boolean>,
	assetDetailsModalOpen: Fusion.Value<boolean>,
}

local function Modals(scope: types.AppScope, props: ModalsProps)
	local scope = scope:deriveScope({
		CreateRepoModal = CreateRepoModal,
		EditRepoModal = EditRepoModal,
		ExportRepoModal = ExportRepoModal,
		ImportRepoModal = ImportRepoModal,
		AssetDetailsModal = AssetDetailsModal,
		AddAssetModal = AddAssetModal,
		EditAssetModal = EditAssetModal,
	})

	return scope:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Children] = Child {
			scope:Computed(function(use, scope: typeof(scope))
				return if use(props.createRepoModalOpen)
					then scope:CreateRepoModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						createRepoModalOpen = props.createRepoModalOpen,
					}
					else nil
			end),

			scope:Computed(function(use, scope: typeof(scope))
				local selectedAssetRepo = use(props.selectedAssetRepo)
				return if use(props.editRepoModalOpen) and selectedAssetRepo
					then scope:EditRepoModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						selectedAssetRepo = selectedAssetRepo,
						selectedAssetRepoValue = props.selectedAssetRepo,
						editRepoModalOpen = props.editRepoModalOpen,
					}
					else nil
			end),

			scope:Computed(function(use, scope: typeof(scope))
				local selectedAssetRepo = use(props.selectedAssetRepo)
				return if use(props.exportRepoModalOpen) and selectedAssetRepo
					then scope:ExportRepoModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						assetRepo = selectedAssetRepo,
						exportAssetRepoModalOpen = props.exportRepoModalOpen,
					}
					else nil
			end),

			scope:Computed(function(use, scope: typeof(scope))
				return if use(props.importRepoModalOpen)
					then scope:ImportRepoModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						selectedAssetRepo = props.selectedAssetRepo,
						importAssetRepoModalOpen = props.importRepoModalOpen,
					}
					else nil
			end),

			scope:Computed(function(use, scope: typeof(scope))
				return if use(props.addAssetModalOpen)
					then scope:AddAssetModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						selection = props.selection,
						selectedAssetRepo = props.selectedAssetRepo,
						addAssetModalOpen = props.addAssetModalOpen,
					}
					else nil
			end),

			scope:Computed(function(use, scope: typeof(scope))
				local selectedAsset = use(props.selectedAsset)

				return if selectedAsset and use(props.editAssetModalOpen)
					then scope:EditAssetModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						asset = selectedAsset,
						selectedAsset = props.selectedAsset,
						assetDetailsModalOpen = props.assetDetailsModalOpen,
						editAssetModalOpen = props.editAssetModalOpen,
					}
					else nil
			end),

			scope:Computed(function(use)
				local selectedAsset = use(props.selectedAsset)

				return if selectedAsset and use(props.assetDetailsModalOpen)
					then scope:AssetDetailsModal {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						rawSelection = props.rawSelection,
						asset = selectedAsset,
						selectedAsset = props.selectedAsset,
						assetDetailsModalOpen = props.assetDetailsModalOpen,
						editAssetModalOpen = props.editAssetModalOpen,
					}
					else nil
			end),
		},
	}
end

return Modals

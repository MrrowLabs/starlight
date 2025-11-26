local Modals = require(script.Modals)
local Theme = require(script.Parent.Theme)
local Fusion = require(script.Parent.packages.Fusion)
local types = require(script.Parent.types)
local AssetRepoList = require(script.AssetRepoList)
local AssetList = require(script.AssetList)
local assetRegistry = require(script.Parent.utils.assetRegistry)
local unique = require(script.Parent.utils.unique)
local Border = require(script.components.Border)
local Button = require(script.components.Button)
local Text = require(script.components.Text)
local TextBox = require(script.components.TextBox)

local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local function tokenize(query: string): { string }
	local tokens = {}

	while true do
		query = query:gsub("^%s+", "")

		if query == "" then
			break
		end

		local startIndex, endIndex, token = query:find("^(<[^>]+>)")

		if startIndex and endIndex and token then
			table.insert(tokens, token)
			query = query:sub(endIndex + 1, -1)
			continue
		end

		local startIndex, endIndex, token = query:find("^(%S+)")

		if startIndex and endIndex and token then
			table.insert(tokens, token)
			query = query:sub(endIndex + 1, -1)
			continue
		end

		error("failed to consume token")
	end

	return tokens
end

type AppProps = {
	theme: Theme.ThemeContext,
	assetIndicies: Fusion.Value<types.AssetIndicies>,
	rawSelection: Fusion.Value<{ Instance }>,
	selection: Fusion.Computed<{ Instance }>,
}

local function App(scope: types.AppScope, props: AppProps)
	local scope = scope:deriveScope({
		Modals = Modals,
		AssetList = AssetList,
		AssetRepoList = AssetRepoList,
		Text = Text,
		TextBox = TextBox,
		Button = Button,
		Border = Border,
	})

	local selectedAssetRepo: Fusion.Value<types.AssetRepo?> = scope:Value(nil)
	local selectedAsset: Fusion.Value<types.Asset?> = scope:Value(nil)

	local filterQuery = scope:Value("")
	-- TODO: probably DRY this whole thing out ngl
	local filteredAssets: Fusion.Computed<{ types.Asset }> = scope:Computed(function(use)
		local filterQueryTokens =
			unique(tokenize((use(filterQuery):gsub("%%", "%%%%"):gsub("%[", "%%["):gsub("%]", "%%]"))))

		local assetIndicies = use(props.assetIndicies)

		local matchTags = {}
		local matchRepos = {}
		local matchTypes = {}
		local matchFavorite = false

		for _, token in filterQueryTokens do
			if token:match("^<tag:") then
				local tag = token:sub(6, -2)

				if not assetIndicies.assetTags[tag] then
					continue
				end

				table.insert(matchTags, tag)
			elseif token:match("^<in:") then
				local assetRepoUid = token:sub(5, -2)

				if not assetIndicies.assetRepos[assetRepoUid] then
					continue
				end

				table.insert(matchRepos, assetRepoUid)
			elseif token:match("^<type:") then
				table.insert(matchTypes, token:sub(7, -2))
			elseif token == "<favorite>" then
				matchFavorite = true
			end
		end

		local selectedAssetRepo = use(selectedAssetRepo)
		-- luau lsp???
		local assetUids: types.Set<string> = if selectedAssetRepo
			then selectedAssetRepo.assetUids
			else assetIndicies.assetUids

		local filteredAssets = {}

		-- TODO: more advanced filtering (i.e. flipbook type, is flipbook/static, creator type)

		for _, uid in assetUids do
			local asset = assetIndicies.assets[uid]

			if #filterQueryTokens == 0 then
				table.insert(filteredAssets, asset)
				continue
			end

			local similar = true

			-- name & tag matching
			for _, token in filterQueryTokens do
				-- ignore special tokens
				if token:sub(1, 1) == "<" then
					continue
				end

				if asset.name:lower():match(token:lower()) then
					continue
				end

				local containsTag = false

				for _, tag in asset.tags do
					if tag:match(token) then
						containsTag = true
						break
					end
				end

				if not containsTag then
					similar = false
					break
				end
			end

			-- speical matches
			for _, matchType in matchTypes do
				if not asset.type:lower():match(matchType:lower()) then
					similar = false
					break
				end
			end

			for _, matchTag in matchTags do
				if not asset.tags[matchTag] then
					similar = false
					break
				end
			end

			for _, matchRepoUid in matchRepos do
				if not asset.assetRepo or asset.assetRepo:lower() ~= matchRepoUid:lower() then
					similar = false
					break
				end
			end

			if matchFavorite and not assetIndicies.favorites[uid] then
				similar = false
			end

			if similar then
				table.insert(filteredAssets, asset)
			end
		end

		return filteredAssets
	end)

	local repoListVisible = scope:Value(false)
	local createRepoModalOpen = scope:Value(false)
	local editRepoModalOpen = scope:Value(false)
	local importRepoModalOpen = scope:Value(false)
	local exportRepoModalOpen = scope:Value(false)
	local addAssetModalOpen = scope:Value(false)
	local editAssetModalOpen = scope:Value(false)
	local assetDetailsModalOpen = scope:Value(false)

	return scope:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Children] = Child {
			scope:New "Frame" {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,

				[Children] = {
					scope:Modals {
						theme = props.theme,
						assetIndicies = props.assetIndicies,
						rawSelection = props.rawSelection,
						selection = props.selection,
						selectedAsset = selectedAsset,
						selectedAssetRepo = selectedAssetRepo,
						createRepoModalOpen = createRepoModalOpen,
						editRepoModalOpen = editRepoModalOpen,
						importRepoModalOpen = importRepoModalOpen,
						exportRepoModalOpen = exportRepoModalOpen,
						addAssetModalOpen = addAssetModalOpen,
						editAssetModalOpen = editAssetModalOpen,
						assetDetailsModalOpen = assetDetailsModalOpen,
					},
				},
			},

			scope:New "Frame" {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = props.theme.bg_dark,

				[Children] = Child {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalFlex = Enum.UIFlexAlignment.Fill,
					},

					scope:New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
					},

					scope:New "Frame" {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 32),

						[Children] = Child {
							scope:New "UIFlexItem" {},

							scope:New "UIListLayout" {
								Padding = UDim.new(0, 8),
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
								HorizontalFlex = Enum.UIFlexAlignment.Fill,
							},

							scope:TextBox {
								theme = props.theme,
								size = UDim2.fromScale(1, 1),
								text = filterQuery,
								placeholderText = "Start typing to filter assets",

								onTextChanged = function(newText)
									filterQuery:set(newText)
								end,

								[Children] = Child {
									scope:New "UIPadding" {
										PaddingTop = UDim.new(0, 8),
										PaddingLeft = UDim.new(0, 8),
										PaddingRight = UDim.new(0, 8),
										PaddingBottom = UDim.new(0, 8),
									},

									scope:Border {
										theme = props.theme,
										radius = UDim.new(0, 8),
									},
								},
							},

							scope:New "Frame" {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(0, 1),
								AutomaticSize = Enum.AutomaticSize.X,
								Visible = scope:Computed(function(use)
									return use(selectedAssetRepo) ~= nil
								end),

								[Children] = Child {
									scope:New "UIFlexItem" {},

									scope:New "UIListLayout" {
										Padding = UDim.new(0, 8),
										FillDirection = Enum.FillDirection.Horizontal,
										SortOrder = Enum.SortOrder.LayoutOrder,
										HorizontalFlex = Enum.UIFlexAlignment.Fill,
									},

									scope:Button {
										theme = props.theme,
										backgroundColor = props.theme.bg,
										text = "E",
										size = UDim2.fromScale(1, 1),
										automaticSize = Enum.AutomaticSize.None,

										onClick = function()
											editRepoModalOpen:set(true)
										end,

										[Children] = Child {
											scope:New "UIAspectRatioConstraint" {
												AspectRatio = 1,
											},

											scope:Border {
												theme = props.theme,
												radius = UDim.new(0, 8),
											},
										},
									},

									scope:Button {
										theme = props.theme,
										backgroundColor = props.theme.bg,
										text = "U",
										size = UDim2.fromScale(1, 1),
										automaticSize = Enum.AutomaticSize.None,
										visible = scope:Computed(function(use)
											local selectedAssetRepo = use(selectedAssetRepo)
											return selectedAssetRepo ~= nil and selectedAssetRepo.external
										end),

										onClick = function()
											local assetRepo = peek(selectedAssetRepo)
											assert(assetRepo, `currently not selected on an asset repo`)
											assert(assetRepo.externalUri, `missing external uri for {assetRepo.uid}`)
											selectedAssetRepo:set(nil)
											warn("please wait while we update the repo...")
											assetRegistry.importAssetRepoFromUri(
												props.assetIndicies,
												assetRepo.externalUri
											)
										end,

										[Children] = Child {
											scope:New "UIAspectRatioConstraint" {
												AspectRatio = 1,
											},

											scope:Border {
												theme = props.theme,
												radius = UDim.new(0, 8),
											},
										},
									},
								},
							},

							scope:Button {
								theme = props.theme,
								backgroundColor = props.theme.bg,
								text = "R",
								size = UDim2.fromScale(1, 1),
								automaticSize = Enum.AutomaticSize.None,

								onClick = function()
									repoListVisible:set(not peek(repoListVisible))
								end,

								[Children] = Child {
									scope:New "UIFlexItem" {},

									scope:New "UIAspectRatioConstraint" {
										AspectRatio = 1,
									},

									scope:Border {
										theme = props.theme,
										radius = UDim.new(0, 8),
									},
								},
							},

							scope:Button {
								theme = props.theme,
								backgroundColor = props.theme.bg,
								text = "+",
								size = UDim2.fromScale(1, 1),
								automaticSize = Enum.AutomaticSize.None,

								onClick = function()
									addAssetModalOpen:set(true)
								end,

								[Children] = Child {
									scope:New "UIFlexItem" {},

									scope:New "UIAspectRatioConstraint" {
										AspectRatio = 1,
									},

									scope:Border {
										theme = props.theme,
										radius = UDim.new(0, 8),
									},
								},
							},
						},
					},

					scope:New "Frame" {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),

						[Children] = {
							scope:New "Frame" {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),

								[Children] = Child {
									scope:New "UIListLayout" {
										Padding = UDim.new(0, 8),
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalFlex = Enum.UIFlexAlignment.Fill,
									},

									scope:New "Frame" {
										BackgroundTransparency = 1,
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										Visible = scope:Computed(function(use)
											return use(selectedAssetRepo) ~= nil
										end),

										[Children] = Child {
											scope:New "UIFlexItem" {},

											scope:New "UIListLayout" {
												Padding = UDim.new(0, 8),
												SortOrder = Enum.SortOrder.LayoutOrder,
											},

											scope:New "Frame" {
												BackgroundTransparency = 1,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,

												[Children] = scope:Computed(function(use)
													local selectedAssetRepo = use(selectedAssetRepo)
													return if selectedAssetRepo
														then {
															scope:New "UIListLayout" {
																Padding = UDim.new(0, 8),
																FillDirection = Enum.FillDirection.Horizontal,
																SortOrder = Enum.SortOrder.LayoutOrder,
																HorizontalFlex = Enum.UIFlexAlignment.Fill,
															},

															scope:New "Frame" {
																BackgroundTransparency = 1,
																Size = UDim2.fromScale(1, 0),
																AutomaticSize = Enum.AutomaticSize.Y,

																[Children] = {
																	scope:New "UIListLayout" {
																		Padding = UDim.new(0, 4),
																		SortOrder = Enum.SortOrder.LayoutOrder,
																	},

																	scope:Text {
																		theme = props.theme,
																		text = selectedAssetRepo.name,
																		textSize = 24,
																		textWrapped = true,
																		fontWeight = Enum.FontWeight.Bold,
																	},

																	scope:Text {
																		theme = props.theme,
																		text = selectedAssetRepo.description,
																		textColor = props.theme.text_muted,
																		textWrapped = true,
																	},

																	scope:Text {
																		theme = props.theme,
																		text = `<b>uid</b>: {selectedAssetRepo.uid}`,
																		textColor = props.theme.text_muted,
																		textWrapped = true,
																	},

																	scope:Text {
																		theme = props.theme,
																		text = `<b>by</b>: {selectedAssetRepo.credits}`,
																		textColor = props.theme.text_muted,
																		textWrapped = true,
																	},

																	scope:Text {
																		theme = props.theme,
																		text = `<b>version</b>: {selectedAssetRepo.version}`,
																		textColor = props.theme.text_muted,
																		textWrapped = true,
																	},
																},
															},

															scope:New "ImageLabel" {
																BackgroundTransparency = 1,
																Size = UDim2.fromOffset(96, 96),

																Image = selectedAssetRepo.thumbnailUri,

																[Children] = Child {
																	scope:New "UIFlexItem" {},
																},
															},
														}
														else nil
												end),
											},

											scope:New "Frame" {
												BackgroundColor3 = props.theme.border_muted,
												Size = UDim2.new(1, 0, 0, 1),
											},
										},
									},

									scope:AssetList {
										theme = props.theme,
										assets = filteredAssets,
										assetIndicies = props.assetIndicies,
										rawSelection = props.rawSelection,
										selectedAsset = selectedAsset,
										assetDetailsModalOpen = assetDetailsModalOpen,
									},
								},
							},

							scope:New "Frame" {
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 160, 1, 0),
								Visible = repoListVisible,

								[Children] = {
									scope:AssetRepoList {
										theme = props.theme,
										assetIndices = props.assetIndicies,
										selectedAssetRepo = selectedAssetRepo,
										createRepoModalOpen = createRepoModalOpen,
										importRepoModalOpen = importRepoModalOpen,
										exportRepoModalOpen = exportRepoModalOpen,
									},
								},
							},
						},
					},
				},
			},
		},
	}
end

return App

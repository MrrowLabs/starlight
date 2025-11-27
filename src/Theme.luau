local Fusion = require(script.Parent.packages.Fusion)

export type PaletteColor =
	"bg_dark"
	| "bg"
	| "bg_light"
	| "text"
	| "text_muted"
	| "highlight"
	| "border"
	| "border_muted"
	| "primary"
	| "secondary"
	| "red"
	| "yellow"
	| "green"
	| "blue"

export type ThemePalette = {
	bg_dark: Color3,
	bg: Color3,
	bg_light: Color3,
	text: Color3,
	text_muted: Color3,
	highlight: Color3,
	border: Color3,
	border_muted: Color3,
	primary: Color3,
	secondary: Color3,
	red: Color3,
	yellow: Color3,
	green: Color3,
	blue: Color3,
}

export type ThemeContext = {
	bg_dark: Fusion.UsedAs<Color3>,
	bg: Fusion.UsedAs<Color3>,
	bg_light: Fusion.UsedAs<Color3>,
	text: Fusion.UsedAs<Color3>,
	text_muted: Fusion.UsedAs<Color3>,
	highlight: Fusion.UsedAs<Color3>,
	border: Fusion.UsedAs<Color3>,
	border_muted: Fusion.UsedAs<Color3>,
	primary: Fusion.UsedAs<Color3>,
	secondary: Fusion.UsedAs<Color3>,
	red: Fusion.UsedAs<Color3>,
	yellow: Fusion.UsedAs<Color3>,
	green: Fusion.UsedAs<Color3>,
	blue: Fusion.UsedAs<Color3>,
}

export type ThemeColor = Fusion.UsedAs<Color3>

export type ThemePalettes = {
	dark: ThemePalette,
	light: ThemePalette,
}

local themePalettes: ThemePalettes = {
	dark = {
		bg_dark = Color3.fromHex("#040208"),
		bg = Color3.fromHex("#0c0912"),
		bg_light = Color3.fromHex("#17141e"),
		text = Color3.fromHex("#f6ecff"),
		text_muted = Color3.fromHex("#b5acc7"),
		highlight = Color3.fromHex("#665e77"),
		border = Color3.fromHex("#4b435a"),
		border_muted = Color3.fromHex("#31293f"),
		primary = Color3.fromHex("#bba3e8"),
		secondary = Color3.fromHex("#a9bb71"), -- TODO: replace color
		red = Color3.fromHex("#bc938c"),
		yellow = Color3.fromHex("#a5a07c"),
		green = Color3.fromHex("#84a894"),
		blue = Color3.fromHex("#8d9fbe"),
	},

	-- TODO: actually get light mode colors
	light = {
		bg_dark = Color3.fromHex("#e6e2f0"),
		bg = Color3.fromHex("#f4effe"),
		bg_light = Color3.fromHex("#fffcff"),
		text = Color3.fromHex("#0e0719"),
		text_muted = Color3.fromHex("#4b435a"),
		highlight = Color3.fromHex("#fffaff"),
		border = Color3.fromHex("#847b95"),
		border_muted = Color3.fromHex("#a299b4"),
		primary = Color3.fromHex("#503975"),
		secondary = Color3.fromHex("#414f00"), -- TODO: replace color
		red = Color3.fromHex("#7d5952"),
		yellow = Color3.fromHex("#6a6443"),
		green = Color3.fromHex("#4a6c59"),
		blue = Color3.fromHex("#536480"),
	},
}

local function Theme(scope: Fusion.Scope<typeof(Fusion)>): ThemeContext
	local studio = settings():GetService("Studio")
	local studioTheme: Fusion.Value<string> = scope:Value(studio.Theme.Name:lower())

	table.insert(
		scope,
		studio.ThemeChanged:Connect(function()
			studioTheme:set(studio.Theme.Name:lower())
		end)
	)

	local themePalette = scope:Computed(function(use)
		local themePalette = themePalettes[use(studioTheme)]
		assert(themePalette, `unknown theme {studioTheme}`)
		return themePalette
	end)

	-- TODO: perhaps find a more DRY method?
	return {
		bg_dark = scope:Computed(function(use)
			return use(themePalette).bg_dark
		end),
		bg = scope:Computed(function(use)
			return use(themePalette).bg
		end),
		bg_light = scope:Computed(function(use)
			return use(themePalette).bg_light
		end),
		text = scope:Computed(function(use)
			return use(themePalette).text
		end),
		text_muted = scope:Computed(function(use)
			return use(themePalette).text_muted
		end),
		highlight = scope:Computed(function(use)
			return use(themePalette).highlight
		end),
		border = scope:Computed(function(use)
			return use(themePalette).border
		end),
		border_muted = scope:Computed(function(use)
			return use(themePalette).border_muted
		end),
		primary = scope:Computed(function(use)
			return use(themePalette).primary
		end),
		secondary = scope:Computed(function(use)
			return use(themePalette).secondary
		end),
		red = scope:Computed(function(use)
			return use(themePalette).red
		end),
		yellow = scope:Computed(function(use)
			return use(themePalette).yellow
		end),
		green = scope:Computed(function(use)
			return use(themePalette).green
		end),
		blue = scope:Computed(function(use)
			return use(themePalette).blue
		end),
	}
end

return Theme

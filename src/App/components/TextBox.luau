local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)

local OnChange = Fusion.OnChange
local Children = Fusion.Children

export type TextBoxProps = {
	theme: Theme.ThemeContext,
	backgroundColor: Theme.ThemeColor?,
	size: Fusion.UsedAs<UDim2>?,
	automaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
	position: Fusion.UsedAs<UDim2>?,
	anchorPoint: Fusion.UsedAs<Vector2>?,
	editable: Fusion.UsedAs<boolean>?,
	text: Fusion.UsedAs<string>?,
	placeholderText: Fusion.UsedAs<string>?,
	textWrapped: Fusion.UsedAs<boolean>?,
	textSize: Fusion.UsedAs<number>?,
	textColor: Theme.ThemeColor?,
	placeholderTextColor: Theme.ThemeColor?,
	fontWeight: Fusion.UsedAs<Enum.FontWeight>?,
	textXAlignment: Fusion.UsedAs<Enum.TextXAlignment>?,
	textYAlignment: Fusion.UsedAs<Enum.TextYAlignment>?,
	onTextChanged: ((newText: string) -> ())?,
	[typeof(Children)]: Fusion.Child,
}

local function TextBox(scope: Fusion.Scope<typeof(Fusion)>, props: TextBoxProps)
	local scope = scope:deriveScope()

	return scope:New "TextBox" {
		BackgroundColor3 = props.backgroundColor or props.theme.bg,
		Size = props.size,
		AutomaticSize = props.automaticSize,
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		ClipsDescendants = true,

		Text = props.text or "",
		PlaceholderText = props.placeholderText or "",
		TextWrapped = props.textWrapped or false,
		RichText = true,
		TextSize = props.textSize or 16,
		TextColor3 = props.textColor or props.theme.text,
		PlaceholderColor3 = props.placeholderTextColor or props.theme.text_muted,
		FontFace = scope:Computed(function(use)
			return Font.fromName("Montserrat", use(props.fontWeight) or Enum.FontWeight.Medium)
		end),
		TextXAlignment = props.textXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.textYAlignment or Enum.TextYAlignment.Center,
		TextEditable = props.editable,

		[OnChange "Text"] = function(newText)
			if props.onTextChanged then
				props.onTextChanged(newText)
			end
		end,

		[Children] = {
			props[Children],
		},
	}
end

return TextBox

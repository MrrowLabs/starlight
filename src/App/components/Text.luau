local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)

export type TextProps = {
	theme: Theme.ThemeContext,
	size: Fusion.UsedAs<UDim2>?,
	automaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
	position: Fusion.UsedAs<UDim2>?,
	anchorPoint: Fusion.UsedAs<Vector2>?,
	text: Fusion.UsedAs<string>?,
	textWrapped: Fusion.UsedAs<boolean>?,
	textSize: Fusion.UsedAs<number>?,
	textColor: Theme.ThemeColor?,
	fontWeight: Fusion.UsedAs<Enum.FontWeight>?,
	textXAlignment: Fusion.UsedAs<Enum.TextXAlignment>?,
	textYAlignment: Fusion.UsedAs<Enum.TextYAlignment>?,
	visible: Fusion.UsedAs<boolean>?,
}

local function Text(scope: Fusion.Scope<typeof(Fusion)>, props: TextProps)
	local scope = scope:innerScope()

	return scope:New "TextLabel" {
		BackgroundTransparency = 1,
		Size = props.size,
		AutomaticSize = props.automaticSize or Enum.AutomaticSize.XY,
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		Visible = props.visible,

		Text = props.text or "",
		TextWrapped = props.textWrapped or false,
		RichText = true,
		TextSize = props.textSize or 16,
		TextColor3 = props.textColor or props.theme.text,
		FontFace = scope:Computed(function(use)
			return Font.fromName("Montserrat", use(props.fontWeight) or Enum.FontWeight.Medium)
		end),
		TextXAlignment = props.textXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.textYAlignment or Enum.TextYAlignment.Center,
	}
end

return Text

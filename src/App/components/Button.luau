local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local Text = require(script.Parent.Text)

local peek = Fusion.peek
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children
local Child = Fusion.Child

export type ButtonProps = {
	theme: Theme.ThemeContext,
	backgroundColor: Theme.ThemeColor?,
	size: Fusion.UsedAs<UDim2>?,
	automaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
	position: Fusion.UsedAs<UDim2>?,
	anchorPoint: Fusion.UsedAs<Vector2>?,
	visible: Fusion.UsedAs<boolean>?,
	disabled: Fusion.UsedAs<boolean>?,
	text: Fusion.UsedAs<string>?,
	textWrapped: Fusion.UsedAs<boolean>?,
	textSize: Fusion.UsedAs<number>?,
	textColor: Theme.ThemeColor?,
	fontWeight: Fusion.UsedAs<Enum.FontWeight>?,
	textXAlignment: Fusion.UsedAs<Enum.TextXAlignment>?,
	textYAlignment: Fusion.UsedAs<Enum.TextYAlignment>?,
	onClick: (() -> ())?,
	onRightClick: (() -> ())?,
	[typeof(Children)]: Fusion.Child,
}

-- TODO: add disabled visual
-- TODO: add hover visual

local function Button(scope: Fusion.Scope<typeof(Fusion)>, props: ButtonProps)
	local scope = scope:deriveScope({
		Text = Text,
	})

	return scope:New "ImageButton" {
		BackgroundColor3 = props.backgroundColor or props.theme.primary,
		Size = props.size,
		AutomaticSize = props.automaticSize or Enum.AutomaticSize.XY,
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		ClipsDescendants = true,
		Visible = props.visible,

		[OnEvent "MouseButton1Click"] = function()
			if not peek(props.disabled) and props.onClick then
				props.onClick()
			end
		end,

		[OnEvent "MouseButton2Click"] = function()
			if not peek(props.disabled) and props.onRightClick then
				props.onRightClick()
			end
		end,

		[Children] = Child {
			scope:Text {
				theme = props.theme,
				size = UDim2.fromScale(1, 0),
				position = UDim2.fromScale(0, 0.5),
				anchorPoint = Vector2.new(0, 0.5),
				text = props.text,
				textWrapped = props.textWrapped,
				textSize = props.textSize,
				textColor = props.textColor,
				fontWeight = props.fontWeight,
				textXAlignment = props.textXAlignment or Enum.TextXAlignment.Center,
				textYAlignment = props.textYAlignment,
			},

			props[Children],
		},
	}
end

return Button

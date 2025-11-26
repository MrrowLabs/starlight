local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local Border = require(script.Parent.components.Border)

local Children = Fusion.Children
local Child = Fusion.Child

type ModalProps = {
	theme: Theme.ThemeContext,
	[typeof(Children)]: Fusion.Child,
}

local function Modal(scope: Fusion.Scope<typeof(Fusion)>, props: ModalProps)
	local scope = scope:deriveScope({
		Border = Border,
	})

	return scope:New "ImageButton" {
		BackgroundColor3 = props.theme.bg_dark,
		BackgroundTransparency = 0.5,
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			scope:New "UIPadding" {
				PaddingTop = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
			},

			scope:New "Frame" {
				BackgroundColor3 = props.theme.bg,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),

				[Children] = Child {
					scope:New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
					},

					scope:New "UISizeConstraint" {
						MaxSize = Vector2.new(640, math.huge),
					},

					scope:Border {
						theme = props.theme,
						radius = UDim.new(0, 8),
					},

					props[Children],
				},
			},
		},
	}
end

return Modal

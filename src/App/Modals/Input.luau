local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)
local Border = require(script.Parent.Parent.components.Border)
local Text = require(script.Parent.Parent.components.Text)
local TextBox = require(script.Parent.Parent.components.TextBox)

local Children = Fusion.Children
local Child = Fusion.Child

type InputProps = {
	theme: Theme.ThemeContext,
	title: Fusion.UsedAs<string>,
	description: Fusion.UsedAs<string>,
	input: Fusion.Value<string>,
	placeholder: Fusion.UsedAs<string>,
	disabled: Fusion.UsedAs<boolean>?,
}

local function Input(scope: Fusion.Scope<typeof(Fusion)>, props: InputProps)
	local scope = scope:deriveScope({
		TextBox = TextBox,
		Text = Text,
		Border = Border,
	})

	return scope:New "Frame" {
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
				size = UDim2.fromScale(1, 0),
				text = props.title,
				textWrapped = true,
			},

			scope:Text {
				theme = props.theme,
				size = UDim2.fromScale(1, 0),
				text = props.description,
				textColor = props.theme.text_muted,
				textWrapped = true,
			},

			scope:TextBox {
				theme = props.theme,
				backgroundColor = props.theme.bg_light,
				size = UDim2.fromScale(1, 0),
				automaticSize = Enum.AutomaticSize.Y,
				text = props.input,
				placeholderText = props.placeholder,
				editable = scope:Computed(function(use)
					return not use(props.disabled)
				end),

				onTextChanged = function(newText)
					props.input:set(newText)
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

					scope:New "Frame" {
						BackgroundTransparency = 0.5,
						BackgroundColor3 = props.theme.bg_dark,
						Size = UDim2.new(1, 16, 1, 16),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Visible = scope:Computed(function(use)
							return use(props.disabled)
						end),

						[Children] = scope:Border {
							theme = props.theme,
							radius = UDim.new(0, 8),
							strokeSize = 0,
						},
					},
				},
			},
		},
	}
end

return Input

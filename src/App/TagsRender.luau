local Theme = require(script.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.packages.Fusion)
local types = require(script.Parent.Parent.types)
local Border = require(script.Parent.components.Border)
local Text = require(script.Parent.components.Text)

local Children = Fusion.Children
local Child = Fusion.Child

type TagsRenderProps = {
	theme: Theme.ThemeContext,
	tags: Fusion.UsedAs<{ string } | types.Set<string>>,
	backgroundColor: Theme.ThemeColor?,
}

local function TagsRender(scope: Fusion.Scope<typeof(Fusion)>, props: TagsRenderProps)
	local scope = scope:deriveScope({
		Text = Text,
		Border = Border,
	})

	return scope:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		[Children] = Child {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = true,
			},

			scope:ForValues(props.tags, function(_, scope: typeof(scope), tag: string)
				return scope:New "Frame" {
					BackgroundColor3 = props.backgroundColor or props.theme.bg_light,
					AutomaticSize = Enum.AutomaticSize.XY,

					[Children] = Child {
						scope:New "UIPadding" {
							PaddingTop = UDim.new(0, 4),
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
							PaddingBottom = UDim.new(0, 4),
						},

						scope:Border {
							theme = props.theme,
							radius = UDim.new(1, 0),
						},

						scope:Text {
							theme = props.theme,
							text = tag,
						},
					},
				}
			end),
		},
	}
end

return TagsRender

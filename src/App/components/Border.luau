local Theme = require(script.Parent.Parent.Parent.Theme)
local Fusion = require(script.Parent.Parent.Parent.packages.Fusion)

export type BorderProps = {
	theme: Theme.ThemeContext,
	radius: Fusion.UsedAs<UDim>?,
	strokeColor: Theme.ThemeColor?,
	strokeSize: Fusion.UsedAs<number>?,
	strokeType: Fusion.UsedAs<Enum.ApplyStrokeMode>?,
	strokeOffset: Fusion.UsedAs<UDim>?,
}

local function Border(scope: Fusion.Scope<typeof(Fusion)>, props: BorderProps)
	local scope = scope:deriveScope()

	-- this is probably like really bad practice but likew who cares
	return {
		scope:New "UIStroke" {
			ApplyStrokeMode = props.strokeType or Enum.ApplyStrokeMode.Border,
			BorderOffset = props.strokeOffset,
			-- BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Color = props.strokeColor or props.theme.border_muted,
			Thickness = props.strokeSize,
		},

		scope:New "UICorner" {
			CornerRadius = props.radius or UDim.new(0, 0),
		},
	}
end

return Border

--!nocheck
-- gotta do some sketchy stuff

type Serialized<T, I, D> = {
	type: T,
	inner: I,
	_: D,
}

export type SerializedColor3 = Serialized<"color3", { number }, Color3>
export type SerializedColorSequence = Serialized<
	"color_sequence",
	{ { time: number, value: SerializedColor3 } },
	ColorSequence
>
export type SerializedNumberRange = Serialized<"number_range", { number }, NumberRange>
export type SerializedVector2 = Serialized<"vector2", { number }, Vector2>

local serde = {}

function serde.serializeColor3(color: Color3): SerializedColor3
	return {
		type = "color3",
		inner = {
			color.R,
			color.G,
			color.B,
		},
	}
end

function serde.serializeColorSequence(colorSequence: ColorSequence): SerializedColorSequence
	local serializedKeypoints = {}

	for _, keypoint in colorSequence.Keypoints do
		table.insert(serializedKeypoints, { time = keypoint.Time, value = serde.serializeColor3(keypoint.Value) })
	end

	return {
		type = "color_sequence",
		inner = serializedKeypoints,
	}
end

function serde.serializeNumberRange(numberRange: NumberRange): SerializedNumberRange
	return {
		type = "number_range",
		inner = {
			numberRange.Min,
			numberRange.Max,
		},
	}
end

function serde.serializeVector2(vector2: Vector2): SerializedVector2
	return {
		type = "vector2",
		inner = {
			vector2.X,
			vector2.Y,
		},
	}
end

function serde.deserialize<T, I, D>(serialized: Serialized<T, I, D>): D
	if serialized.type == "color3" then
		return Color3.new(serialized.inner[1], serialized.inner[2], serialized.inner[3])
	elseif serialized.type == "color_sequence" then
		local keypoints: { ColorSequenceKeypoint } = {}

		for _, serializedKeypoint in serialized.inner do
			table.insert(
				keypoints,
				ColorSequenceKeypoint.new(serializedKeypoint.time, serde.deserialize(serializedKeypoint.value))
			)
		end

		return ColorSequence.new(keypoints)
	elseif serialized.type == "number_range" then
		return NumberRange.new(serialized.inner[1], serialized.inner[2])
	elseif serialized.type == "vector2" then
		return Vector2.new(serialized.inner[1], serialized.inner[2])
	end

	error(`unknown type {serialized.type}`)
end

return serde

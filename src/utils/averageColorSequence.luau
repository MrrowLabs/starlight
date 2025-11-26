local function averageColorSequence(colorSequence: ColorSequence): Color3
	local totalR, totalG, totalB = 0, 0, 0

	for _, keypoint in colorSequence.Keypoints do
		totalR += keypoint.Value.R
		totalG += keypoint.Value.G
		totalB += keypoint.Value.B
	end

	return Color3.new(
		totalR / #colorSequence.Keypoints,
		totalG / #colorSequence.Keypoints,
		totalB / #colorSequence.Keypoints
	)
end

return averageColorSequence

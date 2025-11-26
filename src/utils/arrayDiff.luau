local function arrayDiff<T>(original: { T }, modified: { T }): ({ T }, { T })
	local added, removed = {}, {}

	for _, item in original do
		if not table.find(modified, item) then
			table.insert(removed, item)
		end
	end

	for _, item in modified do
		if not table.find(original, item) then
			table.insert(added, item)
		end
	end

	return added, removed
end

return arrayDiff

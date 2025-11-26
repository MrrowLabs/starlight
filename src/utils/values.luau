local function values<K, V>(input: { [K]: V }): { V }
	local values = {}

	for _, value in input do
		table.insert(values, value)
	end

	return values
end

return values

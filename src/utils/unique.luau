local function unique<T>(input: { T }): { T }
	local unique = {}

	for _, value in input do
		if not table.find(unique, value) then
			table.insert(unique, value)
		end
	end

	return unique
end

return unique

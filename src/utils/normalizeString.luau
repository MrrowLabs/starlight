-- just makes it safe to use with :match statements
local function normalizeString(input: string): string
	return input:gsub("%%", "%%%%"):gsub("%[", "%%["):gsub("%]", "%%]"):gsub("%-", "%%-")
end

return normalizeString

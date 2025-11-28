local function unwrapPcallOr<R, P...>(default: R, fn: (P...) -> R, ...: P...): R
	local ok, value = pcall(fn, ...)
	return if ok then value else default
end

return unwrapPcallOr

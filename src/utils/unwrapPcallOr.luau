local function unwrapPcallOr<R, P...>(default: R, fn: (P...) -> R, ...: P...): R
	local ok, value = pcall(fn, ...)
	print(ok, value)
	return if ok then value else default
end

return unwrapPcallOr

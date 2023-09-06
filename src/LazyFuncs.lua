local LazyFuncs = {}

function LazyFuncs:CheckVoid(...)
	if select("#", ...) > 1 then
		error("expected 1 argument for CheckVoid", 2)
	end

	return select("#", ...) == 0
end

function LazyFuncs:CheckArg(func, pos, arg, possibleArgType)
	local currentArgType = type(arg)

	if type(possibleArgType) == "table" then
		for _, acceptableArgType in next, possibleArgType do
			if acceptableArgType == currentArgType then
				return
			end
		end

		error(`invalid argument #{pos} to '{func}' (expected {table.concat(possibleArgType, " or ")}, got {currentArgType})`, 2)
	elseif type(possibleArgType) == "string" then
		if possibleArgType ~= currentArgType then
			error(`invalid argument #{pos} to '{func}' (expected {possibleArgType}, got {currentArgType})`, 2)
		end
	else
		error("expected a string for the type argument", 2)
	end
end

return LazyFuncs

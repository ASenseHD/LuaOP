local Constructor, LOPObject = {}, require(script.OpCodes)

function Constructor.new()
	return setmetatable({}, {__index = LOPObject})
end

return Constructor

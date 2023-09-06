local Constructor, LOPObject = {}, require(script.LOPObject)

function Constructor.new()
	return setmetatable({}, {__index = LOPObject})
end

return Constructor

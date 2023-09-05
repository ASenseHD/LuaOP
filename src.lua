local GEnv;

do
	GEnv = getfenv(1)
end

local Constructor, LOPObject, LazyFuncs = {}, {}, {}

function Constructor.new()
	return setmetatable({}, {__index = LOPObject})
end

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

LOPObject.Stack = {}
LOPObject.FastCallFunc = {}
LOPObject.Clock = os.clock()
LOPObject.OPCodes = {
	ECOPY = function(Data, From, To)
		LazyFuncs:CheckArg("ECOPY", 1, From, "string")
		LazyFuncs:CheckArg("ECOPY", 2, To, "string")
		
		Data.Env[To] = From
	end,
	
	SCOPY = function(_, IdxFrom, IdxTo)
		LazyFuncs:CheckArg("SCOPY", 1, IdxFrom, "number")
		LazyFuncs:CheckArg("SCOPY", 2, IdxTo, "number")
		
		table.insert(LOPObject.Stack, IdxTo, LOPObject.Stack[IdxFrom])
		
		--LOPObject.Stack[IdxTo] = LOPObject.Stack[IdxFrom]
	end,
	
	LOADK = function(_, Const)
		LazyFuncs:CheckArg("LOADK", 1, Const, {"string", "number"})
		
		table.insert(LOPObject.Stack, 1, Const)
	end,
	
	LOADBOOL = function(_, Bool)
		LazyFuncs:CheckArg("LOADBOOL", 1, Bool, "boolean")

		table.insert(LOPObject.Stack, 1, Bool)
	end,
	
	LOADNIL = function()
		table.insert(LOPObject.Stack, 1, nil)
	end,
	
	GETGLOBAL = function(Data, GlobalName)
		LazyFuncs:CheckArg("GETGLOBAL", 1, GlobalName, "string")
		
		table.insert(LOPObject.Stack, 1, Data.Env[GlobalName] or GEnv[GlobalName])
	end,
	
	SETGLOBAL = function(Data, GlobalName, NewValue)
		LazyFuncs:CheckArg("SETGLOBAL", 1, GlobalName, "string")
		assert(not LazyFuncs:CheckVoid(NewValue), "missing argument #2 to SETGLOBAL (expected any)")
		
		Data.Env[GlobalName] = NewValue
	end,
	
	SETTABLE = function(_, IdxArgNum)
		LazyFuncs:CheckArg("SETTABLE", 1, IdxArgNum, "number")
		LazyFuncs:CheckArg("SETTABLE", 2, LOPObject.Stack[IdxArgNum + 1], "table")
		
		local Args = {}
		
		for Idx = 1, IdxArgNum do
			table.insert(LOPObject.Stack[IdxArgNum + 1], 1, LOPObject.Stack[Idx])
		end
	end,
	
	NEWTABLE = function()
		table.insert(LOPObject.Stack, 1, {})
	end,
	
	NEWPROTO = function(Data, Proto)
		LazyFuncs:CheckArg("NEWPROTO", 1, Proto, "table")

		for ProtoSOP, ProtoOP in pairs(Proto) do
			LazyFuncs:CheckArg("NEWPROTO (OPCHECK)", ProtoSOP, ProtoOP, "table")
			LazyFuncs:CheckArg("NEWPROTO (OPCHECK)", ProtoSOP, ProtoOP.Name, "string")
			LazyFuncs:CheckArg("NEWPROTO (OPCHECK)", ProtoSOP, ProtoOP.Args, "table")
		end
		
		table.insert(LOPObject.Stack, 1, Proto)
	end,
	
	ADD = function(_, Amt)
		LazyFuncs:CheckArg("ADD", 1, Amt, "number")
		LazyFuncs:CheckArg("ADD", 2, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] += Amt
	end,
	
	SUB = function(_, Amt)
		LazyFuncs:CheckArg("SUB", 1, Amt, "number")
		LazyFuncs:CheckArg("SUB", 2, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] -= Amt
	end,
	
	MUL = function(_, Amt)
		LazyFuncs:CheckArg("MUL", 1, Amt, "number")
		LazyFuncs:CheckArg("MUL", 2, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] *= Amt
	end,
	
	DIV = function(_, Amt)
		LazyFuncs:CheckArg("DIV", 1, Amt, "number")
		LazyFuncs:CheckArg("DIV", 2, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] /= Amt
	end,
	
	MOD = function(_, Amt)
		LazyFuncs:CheckArg("MOD", 1, Amt, "number")
		LazyFuncs:CheckArg("MOD", 2, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] %= Amt
	end,
	
	POW = function(_, Amt)
		LazyFuncs:CheckArg("POW", 1, Amt, "number")
		LazyFuncs:CheckArg("POW", 2, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] ^= Amt
	end,
	
	UNM = function()
		LazyFuncs:CheckArg("UNM", 1, LOPObject.Stack[1], "number")
		
		LOPObject.Stack[1] = -LOPObject.Stack[1]
	end,
	
	NOT = function()
		LOPObject.Stack[1] = not LOPObject.Stack[1]
	end,
	
	LEN = function()
		return #LOPObject.Stack[1]
	end,
	
	CONCAT = function()
		LazyFuncs:CheckArg("CONCAT", 1, LOPObject.Stack[1], {"string", "number"})
		LazyFuncs:CheckArg("CONCAT", 2, LOPObject.Stack[2], {"string", "number"})
		
		assert(not (type(LOPObject.Stack[1]) == "number" and type(LOPObject.Stack[2]) == "number"), `cannot CONCAT: index 1 and 2 in stack are numbers`)
		
		table.insert(LOPObject.Stack, 1, LOPObject.Stack[2] .. LOPObject.Stack[1])
	end,
	
	TOSTR = function()
		LOPObject.Stack[1] = tostring(LOPObject.Stack[1])
	end,
	
	TONUM = function()
		LazyFuncs:CheckArg("TONUM", 1, LOPObject.Stack[1], "string")
		
		LOPObject.Stack[1] = tonumber(LOPObject.Stack[1])
	end,
	
	JMP = function(Data, InstrPointerAdd)
		local RemainingPointers = Data.MaxPointers - Data.CurrPointer
		
		LazyFuncs:CheckArg("JMP", 1, InstrPointerAdd, "number")
		assert(RemainingPointers >= InstrPointerAdd, `invalid argument #1 to 'JMP' (RemainingPointers is negative or equal to 0, make sure you are giving a correct value)`)

		Data.CurrPointer += InstrPointerAdd
	end,
	
	EQ = function()
		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] == LOPObject.Stack[2])
	end,
	
	NEQ = function()
		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] ~= LOPObject.Stack[2])
	end,
	
	LE = function()
		LazyFuncs:CheckArg("LESS", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("LESS", 2, LOPObject.Stack[2], "number")
		
		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] < LOPObject.Stack[2])
	end,
	
	GE = function()
		LazyFuncs:CheckArg("GREATER", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("GREATER", 2, LOPObject.Stack[2], "number")

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] > LOPObject.Stack[2])
	end,
	
	LEQ = function()
		LazyFuncs:CheckArg("LESSEQ", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("LESSEQ", 2, LOPObject.Stack[2], "number")

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] <= LOPObject.Stack[2])
	end,
	
	GEQ = function()
		LazyFuncs:CheckArg("GREATEREQ", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("GREATEREQ", 2, LOPObject.Stack[2], "number")

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] >= LOPObject.Stack[2])
	end,
	
	GETFIELD = function()
		--LazyFuncs:CheckArg("GETFIELD", 1, LOPObject.Stack[1], {"string", "number"})
		LazyFuncs:CheckArg("GETFIELD", 1, LOPObject.Stack[2], {"table", "userdata"})
		
		table.insert(LOPObject.Stack, 1, LOPObject.Stack[2][LOPObject.Stack[1]])
	end,
	
	SETFIELD = function()
		--LazyFuncs:CheckArg("SETFIELD", 2, LOPObject.Stack[2], {"string", "number"})
		LazyFuncs:CheckArg("SETFIELD", 1, LOPObject.Stack[3], {"table", "userdata"})

		LOPObject.Stack[3][LOPObject.Stack[2]] = LOPObject.Stack[1]
	end,
	
	THROW = function()
		error(LOPObject.Stack[1] or "manually thrown LOP error", 2)
	end,
	
	ASSERT = function()
		if not LOPObject.Stack[2] then
			error(LOPObject.Stack[1] or "LOP assertion failed!", 2)
		end
	end,
	
	GETARGS = function(Data)
		table.insert(LOPObject.Stack, 1, Data.Args)
	end,
	
	CALL = function(_, IdxArgNum)
		LazyFuncs:CheckArg("CALL", 1, IdxArgNum, "number")
		LazyFuncs:CheckArg("CALL", 2, LOPObject.Stack[IdxArgNum + 1], {"table", "function"})
		
		local Func = LOPObject.Stack[IdxArgNum + 1]
		local Args = {}

		for Idx = 1, IdxArgNum do
			table.insert(Args, LOPObject.Stack[Idx])
		end
		
		local Return;
		if type(Func) == "table" then --> Prototype
			for IdxSOP, FuncOP in pairs(Func) do
				LazyFuncs:CheckArg("CALL (OPCHECK)", IdxSOP, FuncOP, "table")
				LazyFuncs:CheckArg("CALL (OPCHECK)", IdxSOP, FuncOP.Name, "string")
				LazyFuncs:CheckArg("CALL (OPCHECK)", IdxSOP, FuncOP.Args, "table")
			end
			
			local Data = LOPObject:Run(Func, false, Args)
			
			Return = Data.Return
		elseif type(Func) == "function" then --> Vanilla lua function
			Return = {Func(unpack(Args))}
		end
		
		table.insert(LOPObject.Stack, 1, Return)
	end,
	
	DBGSETCLOCK = function()
		LOPObject.Clock = os.clock()
	end,
	
	DBGPUSHCLOCK = function()
		local End = os.clock() - LOPObject.Clock
		
		table.insert(LOPObject.Stack, 1, End)
	end,
	
	SETFASTFUNC = function()
		LazyFuncs:CheckArg("SETFASTFUNC", 1, LOPObject.Stack[1], {"table", "function"})
		
		LOPObject.FastCallFunc = LOPObject.Stack[1]
	end,
	
	FASTCALL = function(_, IdxArgNum)
		LazyFuncs:CheckArg("FASTCALL", 1, IdxArgNum, "number")
		LazyFuncs:CheckArg("FASTCALL", 2, LOPObject.FastCallFunc, {"table", "function"})
		
		table.insert(LOPObject.Stack, IdxArgNum + 1, LOPObject.FastCallFunc)
		
		LOPObject.OPCodes.CALL(nil, IdxArgNum)
	end,
	
	PCALL = function(_, Scope)
		LazyFuncs:CheckArg("PCALL", 1, Scope, "table")

		for IdxSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("PCALL (OPCHECK)", IdxSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("PCALL (OPCHECK)", IdxSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("PCALL (OPCHECK)", IdxSOP, ScopeOP.Args, "table")
		end
		
		local Sucess, Output = pcall(function()
			LOPObject:Run(Scope)
		end)
		
		table.insert(LOPObject.Stack, 1, Sucess)
		table.insert(LOPObject.Stack, 1, Output)
	end,
	
	GETFENV = function(Data)
		LazyFuncs:CheckArg("GETFENV", 1, LOPObject.Stack[1], "function")
		
		table.insert(LOPObject.Stack, 1, getfenv(LOPObject.Stack[1]))
	end,
	
	SETFENV = function(Data, FuncOrScope)
		LazyFuncs:CheckArg("SETFENV", 2, LOPObject.Stack[1], "table")
		LazyFuncs:CheckArg("SETFENV", 1, LOPObject.Stack[2], "function")
		
		local FuncOrScope = setfenv(LOPObject.Stack[2], LOPObject.Stack[1])

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1])
	end,
	
	CNVPROTO = function(Data)
		LazyFuncs:CheckArg("CNVPROTO", 1, LOPObject.Stack[1], "table")
		
		for IdxSOP, ScopeOP in pairs(LOPObject.Stack[1]) do
			LazyFuncs:CheckArg("CNVPROTO (OPCHECK)", IdxSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("CNVPROTO (OPCHECK)", IdxSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("CNVPROTO (OPCHECK)", IdxSOP, ScopeOP.Args, "table")
		end
		
		table.insert(LOPObject.Stack, 1, function(...)
			return LOPObject:Run(LOPObject.Stack[1], false, ...)
		end)
	end,
	
	RETURN = function(Data, IdxArgNum)
		Data.BreakScope = true
		
		local Returns = {}
		
		for Idx = 1, IdxArgNum do
			table.insert(Returns, LOPObject.Stack[Idx])
		end
		
		table.insert(LOPObject.Stack, 1, Returns)
		Data.Return = Returns
	end,
	
	BREAK = function(Data)
		if not Data.IsInLoop then
			error(`cannot BREAK: not in a loop`, 2)
		end
		
		Data.BreakScope = true
	end,
	
	IF = function(Data, Scope)
		if LOPObject.Stack[1] then
			LazyFuncs:CheckArg("IF", 1, Scope, "table")
			
			for IdxSOP, ScopeOP in pairs(Scope) do
				LazyFuncs:CheckArg("IF (OPCHECK)", IdxSOP, ScopeOP, "table")
				LazyFuncs:CheckArg("IF (OPCHECK)", IdxSOP, ScopeOP.Name, "string")
				LazyFuncs:CheckArg("IF (OPCHECK)", IdxSOP, ScopeOP.Args, "table")
			end
			
			LOPObject:Run(Scope)
		end
	end,
	
	FORI = function(_, Scope)
		LazyFuncs:CheckArg("FORI", 1, Scope, "table")
		LazyFuncs:CheckArg("FORI", 2, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("FORI", 3, LOPObject.Stack[2], "number")

		for IdxSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("FORI (OPCHECK)", IdxSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("FORI (OPCHECK)", IdxSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("FORI (OPCHECK)", IdxSOP, ScopeOP.Args, "table")
		end
		
		for I = LOPObject.Stack[2], LOPObject.Stack[1] do
			local LData = LOPObject:Run(Scope, true, I)

			if LData.BreakScope then
				break
			end
		end
	end,
	
	FOR = function(_, Scope)
		LazyFuncs:CheckArg("FOR", 1, Scope, "table")
		LazyFuncs:CheckArg("FOR", 2, LOPObject.Stack[1], "table")

		for IdxSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("FOR (OPCHECK)", IdxSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("FOR (OPCHECK)", IdxSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("FOR (OPCHECK)", IdxSOP, ScopeOP.Args, "table")
		end
		
		for Idx, Val in pairs(LOPObject.Stack[1]) do
			local LData = LOPObject:Run(Scope, true, Idx, Val)

			if LData.BreakScope then
				break
			end
		end
	end,
	
	DO = function(Data, Scope)
		LazyFuncs:CheckArg("DO", 1, Scope, "table")

		for IdxSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("DO (OPCHECK)", IdxSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("DO (OPCHECK)", IdxSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("DO (OPCHECK)", IdxSOP, ScopeOP.Args, "table")
		end
	end,
}

function LOPObject:Run(OpCodes, IsInLoop, Args): any
	LazyFuncs:CheckArg("Run", 1, OpCodes, "table")
	LazyFuncs:CheckArg("Run", 2, IsInLoop, {"boolean", "nil"})

	for IdxSOP, OpCodesOP in pairs(OpCodes) do
		LazyFuncs:CheckArg("Run (OPCHECK)", IdxSOP, OpCodesOP, "table")
		LazyFuncs:CheckArg("Run (OPCHECK)", IdxSOP, OpCodesOP.Name, "string")
		LazyFuncs:CheckArg("Run (OPCHECK)", IdxSOP, OpCodesOP.Args, "table")
	end
	
	local SizeOfOP = #OpCodes
	
	local Data = {
		Env = {},
		Args = {Args},
		MaxPointers = SizeOfOP,
		CurrPointer = 0,
		BreakScope = false,
		IsInLoop = IsInLoop or false,
	}
	
	while true do
		Data.CurrPointer += 1
		
		local OPData = OpCodes[Data.CurrPointer]
		
		if OPData then
			local Success, Error = pcall(function()
				LOPObject.OPCodes[OPData.Name](Data, unpack(OPData.Args))
			end)
			
			if not Success then
				error(`LOP Runtime Error at OP \`{OPData.Name}\`: {string.gsub(Error, ".+:%d+: ", "", 1)} [PC: {Data.CurrPointer}]`, 3)
			end

			if Data.BreakScope then
				break
			end
		else
			break
		end
	end
	
	return Data, Data.Return
end

return Constructor

local GEnv
do
   GEnv = getfenv(1)
end

local LazyFuncs = require(script.Parent.LazyFuncs)
local LOPObject = {}

LOPObject.Stack = {}
LOPObject.FastCallFunc = {}
LOPObject.Clock = os.clock()

LOPObject.OPCodes = {
	ECOPY = function(Data, From, To)
		LazyFuncs:CheckArg("ECOPY", 1, From, "string")
		LazyFuncs:CheckArg("ECOPY", 2, To, "string")

		Data.Env[To] = From
	end,

	SCOPY = function(_, IndexFrom, IndexTo)
		LazyFuncs:CheckArg("SCOPY", 1, IndexFrom, "number")
		LazyFuncs:CheckArg("SCOPY", 2, IndexTo, "number")

		table.insert(LOPObject.Stack, IndexTo, LOPObject.Stack[IndexFrom])
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

	SETGLOBAL = function(Data, GlobalName)
		LazyFuncs:CheckArg("SETGLOBAL", 1, GlobalName, "string")

		Data.Env[GlobalName] = LOPObject.Stack[1]
	end,

	SETTABLE = function(_, IndexArgNum)
		LazyFuncs:CheckArg("SETTABLE", 1, IndexArgNum, "number")
		LazyFuncs:CheckArg("SETTABLE", 2, LOPObject.Stack[IndexArgNum + 1], "table")

		local Args = {}

		for Index = 1, IndexArgNum do
			table.insert(LOPObject.Stack[IndexArgNum + 1], 1, LOPObject.Stack[Index])
		end
	end,

	NEWTABLE = function()
		table.insert(LOPObject.Stack, 1, {})
	end,

	NEWPROTO = function(Data, Proto)
		LazyFuncs:CheckArg("NEWPROTO", 1, Proto, "table")

		for ProtoSOP, ProtoOP in pairs(Proto) do
			LazyFuncs:CheckArg("NEWPROTO (SCOPECHECK)", ProtoSOP, ProtoOP, "table")
			LazyFuncs:CheckArg("NEWPROTO (SCOPECHECK)", ProtoSOP, ProtoOP.Name, "string")
			LazyFuncs:CheckArg("NEWPROTO (SCOPECHECK)", ProtoSOP, ProtoOP.Args, "table")
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
		LazyFuncs:CheckArg("LE", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("LE", 2, LOPObject.Stack[2], "number")

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] < LOPObject.Stack[2])
	end,

	GE = function()
		LazyFuncs:CheckArg("GE", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("GE", 2, LOPObject.Stack[2], "number")

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] > LOPObject.Stack[2])
	end,

	LEQ = function()
		LazyFuncs:CheckArg("LEQ", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("LEQ", 2, LOPObject.Stack[2], "number")

		table.insert(LOPObject.Stack, 1, LOPObject.Stack[1] <= LOPObject.Stack[2])
	end,

	GEQ = function()
		LazyFuncs:CheckArg("GEQ", 1, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("GEQ", 2, LOPObject.Stack[2], "number")

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

	CALL = function(_, IndexArgNum)
		LazyFuncs:CheckArg("CALL", 1, IndexArgNum, "number")
		LazyFuncs:CheckArg("CALL", 2, LOPObject.Stack[IndexArgNum + 1], {"table", "function"})

		local Func = LOPObject.Stack[IndexArgNum + 1]
		local Args = {}

		for Index = 1, IndexArgNum do
			table.insert(Args, LOPObject.Stack[Index])
		end

		local Return;
		if type(Func) == "table" then --> Prototype
			for IndexSOP, FuncOP in pairs(Func) do
				LazyFuncs:CheckArg("CALL (SCOPECHECK)", IndexSOP, FuncOP, "table")
				LazyFuncs:CheckArg("CALL (SCOPECHECK)", IndexSOP, FuncOP.Name, "string")
				LazyFuncs:CheckArg("CALL (SCOPECHECK)", IndexSOP, FuncOP.Args, "table")
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

	FASTCALL = function(_, IndexArgNum)
		LazyFuncs:CheckArg("FASTCALL", 1, IndexArgNum, "number")
		LazyFuncs:CheckArg("FASTCALL", 2, LOPObject.FastCallFunc, {"table", "function"})

		table.insert(LOPObject.Stack, IndexArgNum + 1, LOPObject.FastCallFunc)

		LOPObject.OPCodes.CALL(nil, IndexArgNum)
	end,

	PCALL = function(_, Scope)
		LazyFuncs:CheckArg("PCALL", 1, Scope, "table")

		for IndexSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("PCALL (SCOPECHECK)", IndexSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("PCALL (SCOPECHECK)", IndexSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("PCALL (SCOPECHECK)", IndexSOP, ScopeOP.Args, "table")
		end

		local Sucess, Output = pcall(function()
			LOPObject:Run(Scope)
		end)

		table.insert(LOPObject.Stack, 1, Sucess)
		table.insert(LOPObject.Stack, 1, Output)
	end,

	CNVPROTO = function(Data)
		LazyFuncs:CheckArg("CNVPROTO", 1, LOPObject.Stack[1], "table")

		for IndexSOP, ScopeOP in pairs(LOPObject.Stack[1]) do
			LazyFuncs:CheckArg("CNVPROTO (SCOPECHECK)", IndexSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("CNVPROTO (SCOPECHECK)", IndexSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("CNVPROTO (SCOPECHECK)", IndexSOP, ScopeOP.Args, "table")
		end

		table.insert(LOPObject.Stack, 1, function(...)
			return LOPObject:Run(LOPObject.Stack[1], false, ...)
		end)
	end,

	RETURN = function(Data, IndexArgNum)
		Data.BreakScope = true

		local Returns = {}

		for Index = 1, IndexArgNum do
			table.insert(Returns, LOPObject.Stack[Index])
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

			for IndexSOP, ScopeOP in pairs(Scope) do
				LazyFuncs:CheckArg("IF (SCOPECHECK)", IndexSOP, ScopeOP, "table")
				LazyFuncs:CheckArg("IF (SCOPECHECK)", IndexSOP, ScopeOP.Name, "string")
				LazyFuncs:CheckArg("IF (SCOPECHECK)", IndexSOP, ScopeOP.Args, "table")
			end

			LOPObject:Run(Scope)
		end
	end,

	FORI = function(_, Scope)
		LazyFuncs:CheckArg("FORI", 1, Scope, "table")
		LazyFuncs:CheckArg("FORI", 2, LOPObject.Stack[1], "number")
		LazyFuncs:CheckArg("FORI", 3, LOPObject.Stack[2], "number")

		for IndexSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("FORI (SCOPECHECK)", IndexSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("FORI (SCOPECHECK)", IndexSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("FORI (SCOPECHECK)", IndexSOP, ScopeOP.Args, "table")
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

		for IndexSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("FOR (SCOPECHECK)", IndexSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("FOR (SCOPECHECK)", IndexSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("FOR (SCOPECHECK)", IndexSOP, ScopeOP.Args, "table")
		end

		for Index, Val in pairs(LOPObject.Stack[1]) do
			local LData = LOPObject:Run(Scope, true, Index, Val)

			if LData.BreakScope then
				break
			end
		end
	end,

	DO = function(Data, Scope)
		LazyFuncs:CheckArg("DO", 1, Scope, "table")

		for IndexSOP, ScopeOP in pairs(Scope) do
			LazyFuncs:CheckArg("DO (SCOPECHECK)", IndexSOP, ScopeOP, "table")
			LazyFuncs:CheckArg("DO (SCOPECHECK)", IndexSOP, ScopeOP.Name, "string")
			LazyFuncs:CheckArg("DO (SCOPECHECK)", IndexSOP, ScopeOP.Args, "table")
		end

		LOPObject:Run(Scope)
	end,
}

function LOPObject:Run(OpCodes, IsInLoop, Args): any
	LazyFuncs:CheckArg("Run", 1, OpCodes, "table")
	LazyFuncs:CheckArg("Run", 2, IsInLoop, {"boolean", "nil"})

	for IndexSOP, OpCodesOP in pairs(OpCodes) do
		LazyFuncs:CheckArg("Run (SCOPECHECK)", IndexSOP, OpCodesOP, "table")
		LazyFuncs:CheckArg("Run (SCOPECHECK)", IndexSOP, OpCodesOP.Name, "string")
		LazyFuncs:CheckArg("Run (SCOPECHECK)", IndexSOP, OpCodesOP.Args, "table")
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
				error(`LOP Runtime Error at OP \"{OPData.Name}\": {string.gsub(Error, ".+:%d+: ", "", 1)} [PC: {Data.CurrPointer}]`, 3)
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
return LOPObject

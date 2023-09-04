# LOPObject.OPCodes

The `LOPObject.OPCodes` table contains various OpCode functions used for manipulating data in the LOP ``(Lua custom OPcode interpreter)`` system. These functions are used to perform operations on the LOPObject's internal stack

### ECOPY

```lua
function(From, To)
```

Copies the value of From to To in the environment table Data.Env. Both From and To should be strings representing variable names.

Example:

```lua
LOPObject.OPCodes.ECOPY("variable1", "variable2")
```

### SCOPY

```lua
function(IdxFrom, IdxTo)
```

Copies the value at index IdxFrom to index IdxTo in the LOPObject's internal stack.

Example:

```lua
LOPObject.OPCodes.SCOPY(2, 5)
```

### LOADK

```lua
function(Const)
```

Loads the constant value Const onto the top of the stack.

Example:

```lua
LOPObject.OPCodes.LOADK(42)
```

### LOADBOOL

```lua
function(Bool)
```

Loads a boolean value Bool onto the top of the stack.

Example:

```lua
LOPObject.OPCodes.LOADBOOL(true)
```

### LOADNIL

```lua
function()
```

Loads a nil value onto the top of the stack.

Example:

```lua
LOPObject.OPCodes.LOADNIL()
```

### GETGLOBAL

```lua
function(GlobalName)
```

Retrieves the value of the global variable GlobalName and pushes it onto the stack.

Example:

```lua
LOPObject.OPCodes.GETGLOBAL("print")
```

```lua
LOPObject.OPCodes.GETGLOBAL("myVariableSetWithSETGLOBAL")
```

### SETGLOBAL

```lua
function(GlobalName, NewValue)
```

Sets the global variable GlobalName to the value NewValue.

Example:

```lua
LOPObject.OPCodes.SETGLOBAL("myGlobal", 42)
```

### SETTABLE

```lua
function(IdxArgNum)
```

Sets a table at index IdxArgNum on the stack with values from the stack.

Example:

```lua
LOPObject.OPCodes.SETTABLE(3)
```

### NEWTABLE

```lua
function()
```

Creates a new empty table and pushes it onto the stack.

Example:

```lua
LOPObject.OPCodes.NEWTABLE()
```

### NEWPROTO

```lua
function(Proto)
```

Creates a new prototype function with the provided Proto table and pushes it onto the stack.

Example:

```lua
local myProto = {...} -- define your prototype
LOPObject.OPCodes.NEWPROTO(myProto)
```

### ADD

```lua
function(Amt)
```

Adds Amt to the top value on the stack.

Example:

```lua
LOPObject.OPCodes.ADD(10)
```

### SUB

```lua
function(Amt)
```

Subtracts Amt from the top value on the stack.

Example:

```lua
LOPObject.OPCodes.SUB(5)
```

### MUL

```lua
function(Amt)
```

Multiplies the top value on the stack by Amt.

Example:

```lua
LOPObject.OPCodes.MUL(2)
```

### DIV

```lua
function(Amt)
```

Divides the top value on the stack by Amt.

Example:

```lua
LOPObject.OPCodes.DIV(4)
```

### MOD

```lua
function(Amt)
```

Computes the modulo of the top value on the stack by Amt.

Example:

```lua
LOPObject.OPCodes.MOD(3)
```

### POW

```lua
function(Amt)
```

Computes the top value on the stack to the power of Amt.

Example:

```lua
LOPObject.OPCodes.POW(2)
```

### UNM

```lua
function(Amt)
```

Negates the top value on the stack.

Example:

```lua
LOPObject.OPCodes.UNM()
```

### NOT

```lua
function()
```

Inverts the boolean value on the top of the stack.

Example:

```lua
LOPObject.OPCodes.NOT()
```

### LEN

```lua
function()
```

Returns the length of the top value on the stack, assuming it's a table or string.

Example:

```lua
LOPObject.OPCodes.LEN()
```

### CONCAT

```lua
function()
```

Concatenates the top two values on the stack (assuming they are strings or numbers) and pushes the result onto the stack.

Example:

```lua
LOPObject.OPCodes.CONCAT()
```

### TOSTR

```lua
function()
```

Converts the top value on the stack to a string.

Example:

```lua
LOPObject.OPCodes.TOSTR()
```

### TONUM

```lua
function()
```

Converts the top value on the stack to a number if it's a string.

Example:

```lua
LOPObject.OPCodes.TONUM()
```

### JMP

```lua
function(InstrPointerAdd)
```

Jumps the instruction pointer by InstrPointerAdd positions.

Example:

```lua
LOPObject.OPCodes.JMP(3)
```

### EQ

```lua
function()
```

Pushes true onto the stack if the top two values are equal, otherwise pushes false.

Example:

```lua
LOPObject.OPCodes.EQ()
```

### NEQ

```lua
function()
```

Pushes true onto the stack if the top two values are not equal, otherwise pushes false.

Example:

```lua
LOPObject.OPCodes.NEQ()
```

### LE

```lua
function()
```

Pushes true onto the stack if the second value is less than the first value, otherwise pushes false.

Example:

```lua
LOPObject.OPCodes.LE()
```

### GE

```lua
function()
```

Pushes true onto the stack if the second value is greater than the first value, otherwise pushes false.

Example:

```lua
LOPObject.OPCodes.GE()
```

### LEQ

```lua
function()
```

Pushes true onto the stack if the second value is less than or equal to the first value, otherwise pushes false.

Example:

```lua
LOPObject.OPCodes.LEQ()
```

### GEQ

```lua
function()
```

Pushes true onto the stack if the second value is greater than or equal to the first value, otherwise pushes false.

Example:

```lua
LOPObject.OPCodes.GEQ()
```

### GETFIELD

```lua
function()
```

Pops the top value as a key and the second-to-top value as a table, then pushes the value from the table associated with the key onto the stack.

Example:

```lua
LOPObject.OPCodes.GETFIELD()
```

### SETFIELD

```lua
function()
```

Pops the top value as a key, the second-to-top value as a value, and the third-to-top value as a table. Sets the value in the table associated with the key.

Example:

```lua
LOPObject.OPCodes.SETFIELD()
```

### THROW

```lua
function()
```

Throws an error with the top value on the stack as the error message. If the top value is nil, it throws a generic error.

Example:

```lua
LOPObject.OPCodes.THROW()
```

### ASSERT

```lua
function()
```

Throws an error if the second-to-top value on the stack is nil, with the top value as the error message.

Example:

```lua
LOPObject.OPCodes.ASSERT()
```

### GETARGS

```lua
function(Data)
```

Pushes the Args table from the Data parameter onto the stack.

Example:

```lua
LOPObject.OPCodes.GETARGS(Data)
```

### CALL

```lua
function(IdxArgNum)
```

Calls a function on the stack with the top IdxArgNum values as arguments. The function itself is below the arguments on the stack.

Example:

```lua
LOPObject.OPCodes.CALL(2)
```

### DBGSETCLOCK

```lua
function()
```

Sets the LOPObject's clock to the current time.

Example:

```lua
LOPObject.OPCodes.DBGSETCLOCK()
```

### DBGPUSHCLOCK

```lua
function()
```

Pushes the time elapsed since the last DBGSETCLOCK onto the stack.

Example:

```lua
LOPObject.OPCodes.DBGPUSHCLOCK()
```

### SETFASTFUNC

```lua
function()
```

Sets the LOPObject's fast call function to the top value on the stack. This function is used for fast function calls.

Example:

```lua
LOPObject.OPCodes.SETFASTFUNC()
```

### FASTCALL

```lua
function(IdxArgNum)
```

Calls the fast function on the stack with the top IdxArgNum values as arguments.

Example:

```lua
LOPObject.OPCodes.FASTCALL(3)
```

### PCALL

```lua
function(Scope)
```

Calls the LOPObject:Run function with the provided Scope table and pushes the success status and any return values onto the stack.

Example:

```lua
LOPObject.OPCodes.PCALL(myScope)
```

### GETFENV

```lua
function(Data)
```

Gets the environment of a function on the stack and pushes it onto the stack.

Example:

```lua
LOPObject.OPCodes.GETFENV(Data)
```

### SETFENV

```lua
function(FuncOrScope)
```

Sets the environment of a function on the stack to the provided FuncOrScope table and pushes the new environment onto the stack.

Example:

```lua
LOPObject.OPCodes.SETFENV(myScope)
```

### CNVPROTO

```lua
function(Data)
```

Converts a prototype function on the stack into a lua function and pushes it back onto the stack.

Example:

```lua
LOPObject.OPCodes.CNVPROTO(Data)
```

### RETURN

```lua
function(IdxArgNum)
```

Signals the end of a function and returns the top IdxArgNum values on the stack as the return values.

Example:

```lua
LOPObject.OPCodes.RETURN(2)
```

### BREAK

```lua
function(Data)
```

Signals a break in the current loop. Can only be used inside loops.

Example:

```lua
LOPObject.OPCodes.BREAK(Data)
```

### IF

```lua
function(Scope)
```

Conditionally executes the Scope if the top value on the stack is true.

Example:

```lua
LOPObject.OPCodes.IF(myScope)
```

### FORI

```lua
function(Scope)
```

Iterates over a numeric range specified by the top two values on the stack and executes the Scope for each iteration.

Example:

```lua
LOPObject.OPCodes.FORI(myScope)
```

### FOR

```lua
function(Scope)
```

Iterates over the elements of a table specified by the top value on the stack and executes the Scope for each element.

Example:

```lua
LOPObject.OPCodes.FOR(myScope)
```

### DO

```lua
function(Scope)
```

Executes the Scope as a block of code.

Example:

```lua
LOPObject.OPCodes.DO(myScope)
```

### LOPObject:Run

The LOPObject:Run function is used to execute a sequence of OpCodes within a provided Scope table. It takes care of managing the instruction pointer and stack for the execution.

#### Arguments

- ``Scope``: A table containing the sequence of OpCodes to execute.
- ``IsInLoop`` (should not be used): A boolean indicating if the execution is inside a loop (for the ``BREAK`` opcode).
- ``Args`` (optional): A table of arguments to be passed to the OpCodes.

#### Returns

- ``Data``: A table containing information about the execution, including the environment, arguments, and control flow data.
- ``Return``: The return values from the execution, if any.

**Example:**

```lua
local myScope = {
    {
        Name = "GETGLOBAL",
        Args = {"print"}
    },

    {
        Name = "SETFASTFUNC",
        Args = {}
    },

    {
        Name = "LOADK",
        Args = {1}
    },

    {
        Name = "LOADK",
        Args = {"2, buckle my shoe, 34, buckle some more"}
    },

    {
        Name = "CONCAT",
        Args = {},
    },

    {
        Name = "FASTCALL",
        Args = {1}
    }
}

local executionData, returnValues = LOPObject:Run(myScope, false, {arg1, arg2}) --> `12, buckle my shoe, 34, buckle some more`
```

Note that this documentation only covers a subset of the OpCodes and functions in the provided Lua code. You can follow a similar pattern to document the remaining OpCodes and functions.

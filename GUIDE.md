# GUIDE.md

This guide shows the basics of the LuaOP module. This guide requires you to have created a ``LOPObject`` with the LuaOP Constructor's ``.new`` method.

## Declaring Protos

Protos are equivalent to vanilla Lua functions but defined within a scope. You can declare a proto using the ``NEWPROTO`` opcode. Here's how to do it:

```lua
local ProtoTable = {
    {Name = "LOADK", Args = {2}},
    {Name = "ADD", Args = {2}},
    {Name = "RETURN", Args = {1}} -- Will return 1 argument, the value on top of the stack, which is 4 (a number constant)
}

LOPObject:Run({
    {Name = "GETGLOBAL", Args = {"print"}},
    {Name = "SETFASTFUNC", Args = {}}, -- Sets lua global `print` as the FASTFUNC

    {Name = "NEWPROTO", Args = {ProtoTable}},
    {Name = "CALL", Args = {0}}, -- Call proto with no arguments (0 arguments, so no elements from the stack)
	
    {Name = "LOADK", Args = {1}},
    {Name = "GETFIELD", Args = {}},
	
    {Name = "FASTCALL", Args = {1}} -- Will call `print` which will output 4 as that's the value on top of the stack
})
```

Replace ProtoTable with a table containing your proto's instructions, following the same structure as other scopes.

## Running Scopes

You can execute scopes which are in a scope by passing them to the ``DO`` opcode. Here's how to run a scope:

```lua
LOPObject:Run({
    {Name = "GETGLOBAL", Args = {"print"}},
    {Name = "SETFASTFUNC", Args = {}}, -- Sets lua global `print` as the FASTFUNC

    {Name = "DO", Args = {{
    	{Name = "LOADK", Args = {"I am a string"}},
    	{Name = "FASTCALL", Args = {1}} -- Calls `print` with the constant: "I am a string" 
    }}}
})
```

## Using If Conditions

To use if conditions within a scope, you can use the ``IF`` opcode. It will execute the enclosed scope if the condition on top of the stack is true.
Please note that there isn't a way yet to make ``else`` statements yet.

```lua
LOPObject:Run({
    {Name = "NEWPROTO", Args = {{
    	{Name = "LOADK", Args = {2}},
    	{Name = "ADD", Args = {2}},
    	{Name = "RETURN", Args = {1}} -- Will return 1 argument, the value on top of the stack, which is 4 (a number constant)
    }}},
    {Name = "SETFASTFUNC", Args = {}}, -- Sets our new proto as the FASTFUNC

    {Name = "LOADK", Args = {1}},
    {Name = "LOADK", Args = {2}},

    {Name = "NEQ", Args = {}}, -- Will push true, since the two first values at the top of the stack aren't equal: 2 ~= 1

    {Name = "IF", Args = {{ -- Will evaluate the top value of the stack the same as Lua would, meaning that if the value is positive (not nil or false), LuaOP will run the if statement
    	{Name = "FASTCALL", Args = {0}} -- Calls our proto with no arguments 
    }}}
})
```

Replace ScopeTable with the table containing the instructions for the scope you want to execute conditionally.

## Math Operations

You can perform various math operations using the provided opcodes. Here are examples for some common operations:

- **Addition**:

```lua
LOPObject:Run({
    {Name = "ADD", Args = {5}} -- Adds 5 to the top of the stack
})
```

- **Subtraction**:

```lua
LOPObject:Run({
    {Name = "SUB", Args = {3}} -- Subtracts 3 from the top of the stack
})
```

- **Multiplication**:

```lua
LOPObject:Run({
    {Name = "MUL", Args = {2}} -- Multiplies the top of the stack by 2
})
```

- **Division**:

```lua
LOPObject:Run({
    {Name = "DIV", Args = {4}} -- Divides the top of the stack by 4
})
```

- **Modulus**:

```lua
LOPObject:Run({
    {Name = "MOD", Args = {7}} -- Calculates the modulus with 7
})
```

## Using Fastcall

You can set a fastcall function using the ``SETFASTFUNC`` opcode and then use ``FASTCALL`` to invoke it.

```lua
LOPObject:Run({
    {Name = "GETGLOBAL", Args = {"print"}},
    {Name = "SETFASTFUNC", Args = {}}, -- Sets print as the fastcall function
    
    {Name = "LOADK", Args = {"Hello, world!"}},
    {Name = "FASTCALL", Args = {1}} -- Calls the fastcall function with 1 arguments, which will output "Hello, world!" in the console
})
```

Replace FastFunc with the function or table containing your fastcall logic.

## Calling Protos / Lua Functions

You can call protos / Lua Functions by providing the necessary arguments using the ``CALL`` opcode.

```lua
LOPObject:Run({
    {Name = "CALL", Args = {2}} -- Call the proto / function with 2 arguments from the stack
})
```

## Getting Lua Globals

To retrieve Lua globals, use the ``GETGLOBAL`` opcode.

```lua
LOPObject:Run({
    {Name = "GETGLOBAL", Args = {"myGlobal"}} -- Get the value of the Lua global variable "myGlobal"
})
```

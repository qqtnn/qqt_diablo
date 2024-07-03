
--- A console utility for printing messages to the console with various levels of detail.

--- @class console
--- Prints a shortened console log message.
--- ... The variadic arguments, can be integers, floats, or strings, concatenated into a single log message.
--- @field print fun(...):nil

--- @class console
--- Prints a full console log message including timing controls.
--- start_printing_time The start time when the logging should begin.
--- print_interval The interval at which the log should repeat.
--- msg The message to log.
--- ... The variadic arguments, can be integers, floats, or strings, concatenated with the msg.
--- @field print_full fun(start_printing_time:number, print_interval:number, msg:string, ...):nil

---@class console
console = {}

--- Prints a message to the console.
---@param ... any Variadic arguments to print.
console.print = function(...) end

--- Prints a full message to the console with additional parameters.
---@param start_printing_time number When to start printing.
---@param print_interval number How often to print.
---@param msg string The message to print.
---@param ... any Variadic arguments to append to the message.
console.print_full = function(start_printing_time, print_interval, msg, ...) end
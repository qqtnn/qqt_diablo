---@diagnostic disable: missing-return

_G.qqt = {}

--- Returns the pointer to the local player.
--- @return integer Pointer to the local player.
function qqt.get_local_player() end

--- Returns a table of buff entry pointers for the given game object.
--- @param obj game.object The game object.
--- @return table<number, integer> A table of buff entry pointers.
function qqt.get_buff_entries(obj) end

--- Returns the pointer to the game object with the same ID as the given object.
--- @param obj game.object The game object.
--- @return integer Pointer to the game object with the same ID, or 0 if not found.
function qqt.get_actor_ptr(obj) end

--- Returns a table of buff entry pointers for the given game object if the user has debug access.
--- @param obj game.object The game object.
--- @return table<number, integer> A table of buff entry pointers, or an empty table if the user does not have debug access.
function qqt.get_actor_buff_entries(obj) end

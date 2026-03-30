---@class core
world = {}

--- Get the current world object.
--- @return game.world|nil @Current world object or nil if not available
function world.get_current_world() end

--- Check if a world position is on walkable nav mesh terrain.
--- @param pos vec3 The world position to check
--- @return boolean @true if the position is walkable, false otherwise
function world:is_movable_position(pos) end

--- IMPORTANT NOTE: DISTANCE LIMIT 100-120 RANGE FOR CELLS TO RENDER
--- Calculate a walkable path between two world positions using A* pathfinding on the game's nav mesh.
--- Automatically resolves heights and avoids walls, structures, and impassable terrain.
--- Maximum range is 150 world units. Grid resolution is 0.5 units per cell.
--- @param start vec3 The starting world position (typically player position)
--- @param finish vec3 The destination world position
--- @return vec3[] @Ordered list of waypoints from start to finish, or empty table if no path found
function world:calculate_path(start, finish) end

--- Resolve the Z (height) component of a position by searching upward on the nav mesh.
--- Modifies the input vec3 in-place.
--- @param pos vec3 The position to resolve. Z is modified in-place
function world:set_height_of_valid_position(pos) end

--- Get the current world's unique identifier.
--- @return number @The world ID
function world:get_world_id() end

--- Get the current world/level name.
--- @return string @The world name
function world:get_name() end

--- Get the current zone/subzone name.
--- @return string @The zone name
function world:get_current_zone_name() end

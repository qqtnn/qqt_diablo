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

--- Get the scene containing a world position.
--- @param pos vec3 The world position to query
--- @return game.scene|nil @Scene containing the position, or nil if not found
function world:get_scene_for_position(pos) end

--- Get the current world's unique identifier.
--- @return number @The world ID
function world:get_world_id() end

--- Get the current world/level name.
--- @return string @The world name
function world:get_name() end

--- Get the current zone/subzone name.
--- @return string @The zone name
function world:get_current_zone_name() end

game = game or {}

---@class game.scene
game.scene = {}

--- Get the scene name.
--- @return string
function game.scene:get_name() end

--- Get the scene ID.
--- @return number
function game.scene:get_scene_id() end

--- Get the scene object ID.
--- @return number
function game.scene:get_object_id() end

--- Get the world ID for this scene.
--- @return number
function game.scene:get_world_id() end

--- Get the world containing this scene.
--- @return game.world|nil
function game.scene:get_world() end

--- Get the level area containing a world position.
--- @param pos vec3 The world position to query
--- @return game.level_area|nil @Level area containing the position, or nil if not found
function game.scene:get_level_area_for_position(pos) end

---@class game.level_area
game.level_area = {}

--- Get the level area name.
--- @return string
function game.level_area:get_name() end

--- Get the level area ID.
--- @return number
function game.level_area:get_id() end

--- Get the level area flags.
--- @return number
function game.level_area:get_flags() end

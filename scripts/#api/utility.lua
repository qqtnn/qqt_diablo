---@diagnostic disable: missing-return

--- @class utility.raycast_data
--- @field public is_hit boolean
--- @field public hit_point vec3

-- Creating a global table to simulate the namespace and class in Lua
_G.raycast_table = {}

-- note: no constructor
--- Constructor for raycast_data
-- - @return utility.raycast_data
-- function raycast_table.new()
--     local self = setmetatable({}, { __index = raycast_table })
--     self.is_hit = false -- default value
--     self.hit_point = { x = 0, y = 0, z = 0 } -- assuming vec3 is a simple table with x, y, z
--     return self
-- end

--- Simulates the is_hit method
--- @param self utility.raycast_data
--- @return boolean
function raycast_table.is_hit(self)
    return self.is_hit
end

--- Simulates the hit_point method
--- @param self utility.raycast_data
--- @return vec3
function raycast_table.hit_point(self)
    return self.hit_point
end

--- @class utility
utility = {}

--- Checks if a spell is ready to be cast based on its ID.
--- @param spell_id number The ID of the spell.
--- @return boolean Returns true if the spell is ready, false otherwise.
utility.is_spell_ready = function(spell_id) end

--- Checks if the player can afford to cast a spell based on its ID.
--- @param spell_id number The ID of the spell.
--- @return boolean Returns true if the spell can be afforded, false otherwise.
utility.is_spell_affordable = function(spell_id) end

--- Checks if a spell can be cast based on its ID.
--- @param spell_id number The ID of the spell.
--- @return boolean Returns true if the spell can be cast, false otherwise.
utility.can_cast_spell = function(spell_id) end

--- Retrieves a list of units within a circular area.
--- @param center vec3 The center of the circle.
--- @param radius number The radius of the circle.
--- @return table<game.object> Returns a table of units (gameobject) within the circle.
utility.get_units_inside_circle_list = function(center, radius) end

--- Retrieves a list of units within a rectangular area.
--- @param origin vec3 The starting point of the rectangle.
--- @param destination vec3 The ending point of the rectangle.
--- @param width number The width of the rectangle.
--- @return table<game.object> Returns a table of units (gameobject)  within the rectangle.
utility.get_units_inside_rectangle_list = function(origin, destination, width) end

--- Counts the number of units within a circular area.
--- @param center vec3 The center of the circle.
--- @param radius number The radius of the circle.
--- @return number Returns the count of units within the circle.
utility.get_amount_of_units_inside_circle = function(center, radius) end

--- Counts the number of units within a rectangular area.
--- @param origin vec3 The starting point of the rectangle.
--- @param destination vec3 The ending point of the rectangle.
--- @param width number The width of the rectangle.
--- @return number Returns the count of units within the rectangle.
utility.get_amount_of_units_rectangle_circle = function(origin, destination, width) end

--- Checks if a point on the map is walkable.
--- @param point vec3 The point to check.
--- @return boolean Returns true if the point is walkable, false otherwise.
utility.is_point_walkeable = function(point) end

--- Checks if a point on the map is walkable, with exceptions.
--- @param point vec3 The point to check.
--- @return boolean Returns true if the point is walkable, false otherwise.
utility.is_point_walkeable_exception = function(point) end

--- Performs a heavy check to see if a point on the map is walkable.
--- @param point vec3 The point to check.
--- @return boolean Returns true if the point is walkable, false otherwise.
utility.is_point_walkeable_heavy = function(point) end

--- Checks if a ray cast between two points is walkable.
--- @param origin vec3 The starting point of the ray.
--- @param destination vec3 The ending point of the ray.
--- @param width number The width of the ray.
--- @param steps_distance number The distance between steps in the ray.
--- @return boolean Returns true if the ray is walkable, false otherwise.
utility.is_ray_cast_walkeable = function(origin, destination, width, steps_distance) end

--- Retrieves raycast data between two points.
--- @param origin vec3 The starting point of the ray.
--- @param destination vec3 The ending point of the ray.
--- @param width number The width of the ray.
--- @param steps_distance number The distance between steps in the ray.
--- @return table<utility.raycast_data> Returns a table with raycast data.
utility.get_raycast_table = function(origin, destination, width, steps_distance) end

--- Adjusts a point's height to a valid position on the current world's terrain.
--- @param point vec3 The point to adjust.
--- @return vec3 The adjusted point with valid height.
utility.set_height_of_valid_position = function(point) end

--- Sets a map pin at a specific point.
--- @param point vec3 The location to set the pin.
--- @return boolean Returns true if the pin was set successfully, false otherwise.
utility.set_map_pin = function(point) end

utility.toggle_mount = function() end

-- Pit Levels
-- 51 = 0x1C3554
-- 75 = 0x1C3586
-- 100 = 0x1C35C1
-- 61 = 0x1C3568
-- 121 = 0x1D6D21
-- 81 = 0x1C3595 
-- 98 = 0x1C35BC
-- 31 = 0x1C352B
-- 119 = 0x1D6D1D
-- 129 = 0x1D6D36
-- 141 = 0x1D6D4E
-- 101 = 0x1D6CEF
utility.open_pit_portal = function(level) end

utility.summon_boss = function() end
utility.summon_boss_next_recipe = function() end
utility.summon_boss_previous_recipe = function() end
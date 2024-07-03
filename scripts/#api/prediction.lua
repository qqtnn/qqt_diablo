---@diagnostic disable: missing-return

--- @class spell_geometry
--- @field rectangular number Represents a rectangular geometry
--- @field circular number Represents a circular geometry
spell_geometry = {
    rectangular = 1,
    circular = 2
}

--- @class targeting_type
--- @field skillshot number Represents a skillshot targeting type
--- @field targeted number Represents a targeted ability
targeting_type = {
    skillshot = 1,
    targeted = 2
}

---@class prediction.spell_data
---@field public radius number Radius of the spell effect
---@field public range number Range of the spell
---@field public cast_delay number Delay before the spell casts
---@field public projectile_speed number Speed of the spell's projectile
---@field public has_wall_collision boolean Whether the spell collides with walls
---@field public spell_id number Unique identifier for the spell
---@field public geometry_type number Type of spell geometry (Use spell_geometry)
---@field public targeting_type number Type of targeting used by the spell (Use targeting_type)
local spell_data = {
    radius = 0,
    range = 0,
    cast_delay = 0,
    projectile_speed = 0,
    has_wall_collision = false,
    spell_id = 0,
    geometry_type = spell_geometry.rectangular,  -- Direct reference to the enum
    targeting_type = targeting_type.skillshot    -- Direct reference to the enum
}

--- Creates a new spell_data object
--- @param radius number
--- @param range number
--- @param cast_delay number
--- @param projectile_speed number
--- @param has_wall_collision boolean
--- @param spell_id number
--- @param geometry_type number
--- @param targeting_type number
--- @return prediction.spell_data
function spell_data:new(radius, range, cast_delay, projectile_speed, has_wall_collision, spell_id, geometry_type, targeting_type)
    local new_spell_data = {}
    setmetatable(new_spell_data, self)
    self.__index = self
    new_spell_data.radius = radius or 0
    new_spell_data.range = range or 0
    new_spell_data.cast_delay = cast_delay or 0
    new_spell_data.projectile_speed = projectile_speed or 0
    new_spell_data.has_wall_collision = has_wall_collision or false
    new_spell_data.spell_id = spell_id or 0
    new_spell_data.geometry_type = geometry_type or spell_geometry.rectangular
    new_spell_data.targeting_type = targeting_type or targeting_type.skillshot
    return new_spell_data
end

_G.spell_data = spell_data

---@class prediction
prediction = {}

--- @class prediction_parameters
--- @field cast_origin vec3 The origin from which the prediction is cast
--- @field intersection number The intersection factor used in prediction calculations

--- @class prediction_result_candidates
--- @field center_position vec3 The central position in the prediction result
--- @field intersection_position vec3 The position where the intersection occurs
--- @field max_intersection_position vec3 The maximum position where the intersection can occur

--- @class prediction_result
--- @field hitchance number The chance of hitting the target
--- @field cast_position vec3 The optimal position to cast the spell
--- @field time_to_hit number Time until the spell hits the target
--- @field candidates prediction_result_candidates The candidates for prediction results

--- Predicts the result of a targeting scenario.
--- @param target game.object The target game object
--- @param params prediction_parameters Parameters used for prediction
--- @param spell_data prediction.spell_data Spell data used for the prediction
--- @param debug_call boolean Whether the call is for debugging
--- @return prediction_result The result of the prediction
prediction.get_prediction_result = function(target, params, spell_data, debug_call) end

--- Calculates the future position of a unit after a specified time.
--- @param unit game.object The game object representing the unit
--- @param time number Time in seconds to predict ahead
--- @return vec3 The future position of the unit
prediction.get_future_unit_position = function(unit, time) end

--- Gets the intersection position based on given parameters.
--- @param origin vec3 The origin point for the calculation
--- @param center_position vec3 The central position involved in the calculation
--- @param intersection number The intersection distance or factor
--- @return vec3 The calculated intersection position
prediction.get_intersection_position = function(origin, center_position, intersection) end

--- Retrieves the optimal cast position for a spell based on prediction.
--- @param target game.object The target game object
--- @param params prediction_parameters Prediction parameters
--- @param spell_data prediction.spell_data Spell data
--- @param prediction_result_ptr prediction_result A pointer to a prediction_result object to store the result
--- @return vec3 The optimal cast position
prediction.get_cast_position = function(target, params, spell_data, prediction_result_ptr) end

--- Calculates the time it takes for a projectile to hit a point from a source.
--- @param source vec3 Source position
--- @param point vec3 Target position
--- @param speed number Projectile speed
--- @param delay number Initial delay before the projectile moves
--- @param extra_network_time number Additional time due to network delay
--- @param hitbox number Size of the hitbox of the projectile
--- @param debug_mode boolean Whether to run in debug mode
--- @return number Time in seconds it takes for the projectile to hit the target
prediction.get_hit_time = function(source, point, speed, delay, extra_network_time, hitbox, debug_mode) end

--- Calculates the time it takes for a projectile to hit a moving object.
--- @param source vec3 Source position
--- @param object game.object The moving game object
--- @param speed number Projectile speed
--- @param delay number Initial delay before the projectile moves
--- @param extra_network_time number Additional time due to network delay
--- @param hitbox number Size of the hitbox of the projectile
--- @param complexity number Complexity level of the prediction
--- @param debug_mode boolean Whether to run in debug mode
--- @return number Time in seconds it takes for the projectile to hit the moving target
prediction.get_hit_time_moving = function(source, object, speed, delay, extra_network_time, hitbox, complexity, debug_mode) end

--- Returns collision data for a circular area.
--- @param radius number The radius of the circle
--- @param center vec3 The center of the circle
--- @return table A table containing collision data
prediction.get_collisions_circular = function(radius, center) end

--- Returns collision data for a rectangular area.
--- @param from vec3 The starting point of the rectangle
--- @param to vec3 The ending point of the rectangle
--- @param width number The width of the rectangle
--- @return table A table containing collision data
prediction.get_collisions_rectangular = function(from, to, width) end

--- Checks if a path will collide with a wall.
--- @param from vec3 The starting point of the path
--- @param to vec3 The ending point of the path
--- @param width number The width of the path
--- @return boolean True if there is a wall collision, false otherwise
prediction.is_wall_collision = function(from, to, width) end

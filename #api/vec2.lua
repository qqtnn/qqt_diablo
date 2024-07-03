---@diagnostic disable: missing-return, duplicate-set-field

---@class vec2
---@field public x number The x coordinate
---@field public y number The y coordinate
vec2 = {}

--- Creates a new vec2
---@param x number
---@param y number
---@return vec2
function vec2.new(x, y) end

--- Creates a new vec2
---@param x number
---@param y number
---@return vec2
function vec2:new(x, y) end

--- Check if the vector is zero
---@param self vec2
---@return boolean
function vec2:is_zero() end

--- Project the vec2 into vec3
---@param self vec2
---@return vec3
function vec2:project_3d() end

--- Calculate distance to another vec2
---@param self vec2
---@param other vec2
---@return number
function vec2:distance(other) end

--- Calculate squared distance to another vec2
---@param self vec2
---@param other vec2
---@return number
function vec2:distance_squared(other) end

--- Check if intersects with another vec2
---@param self vec2
---@param other vec2
---@return boolean
function vec2:intersects(other) end

--- Get the length of the vector
---@param self vec2
---@return number
function vec2:length() end

--- Calculate dot product with another vec2
---@param self vec2
---@param other vec2
---@return number
function vec2:dot_product(other) end

--- Get the unit vector
---@param self vec2
---@return vec2
function vec2:get_unit_vector() end

--- Get the angle in radians
---@param self vec2
---@return number
function vec2:get_angle_radulf() end

--- Get extended vector by a specific length
---@param self vec2
---@param point vec2
---@param length number
---@return vec2
function vec2:get_extended(point, length) end

--- Convert screen to coordinate
---@param self vec2
---@return vec2
function vec2:screen_to_coordinate() end

--- Convert coordinate to screen
---@param self vec2
---@return vec2
function vec2:coordinate_to_screen() end

--- Rotate around a pivot by an angle
---@param self vec2
---@param angle number
---@param pivot vec2
---@return vec2
function vec2:rotate_around(angle, pivot) end

--- Check equality with another vec2
---@param self vec2
---@param other vec2
---@return boolean
function vec2:equals(other) end

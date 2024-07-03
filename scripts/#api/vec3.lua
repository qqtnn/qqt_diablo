---@diagnostic disable: missing-return, duplicate-set-field

---@class vec3
---@field x fun(self:vec3):number Get the x coordinate
---@field y fun(self:vec3):number Get the y coordinate
---@field z fun(self:vec3):number Get the z coordinate
---@field get_rotation fun(self:vec3):number Get the rotation
---@field normalize fun(self:vec3):vec3 Normalize the vector
---@field normalize_rotation fun(self:vec3):vec3 Normalize the rotation
---@field dot_product fun(self:vec3, other:vec3):number Calculate dot product with another vec3
---@field is_zero fun(self:vec3):boolean Check if the vector is zero
---@field get_angle fun(self:vec3, point:vec3, origin:vec3):number Get the angle in radians
---@field get_extended fun(self:vec3, vec3, distance:number):vec3 Get extended vector by a specific distance
---@field rotate_around fun(self:vec3, angle:number, pivot:vec3):vec3 Rotate around a pivot by an angle
---@field equals_ignore_z fun(self:vec3, other:vec3, tolerance:number):boolean Check equality ignoring z-coordinate
---@field intersects fun(self:vec3, other:vec3):boolean Check if intersects with another vec3
---@field is_facing fun(self:vec3, other:vec3, angle_tolerance:number):boolean Check if facing another vec3 within angle tolerance
---@field to_string fun(self:vec3):string Convert to string
---@field randomize_xz fun(self:vec3, amount:number):vec3 Randomize x and z components
---@field length_2d fun(self:vec3):number Get the length in 2D
---@field length_3d fun(self:vec3):number Get the length in 3D
---@field length_3d_squared fun(self:vec3):number Get squared length in 3D
---@field dist_to fun(self:vec3, other:vec3):number Calculate distance to another vec3
---@field squared_dist_to fun(self:vec3, other:vec3):number Calculate squared distance to another vec3
---@field length_3d_ignore_z fun(self:vec3):number Get 3D length ignoring z
---@field dist_to_ignore_z fun(self:vec3, other:vec3):number Calculate distance ignoring z
---@field squared_dist_to_ignore_z fun(self:vec3, other:vec3):number Calculate squared distance ignoring z
---@field get_perp_left fun(self:vec3):vec3 Get perpendicular vector to the left
---@field get_perp_right fun(self:vec3):vec3 Get perpendicular vector to the right
---@field lerp fun(self:vec3, target:vec3, t:number):vec3 Linearly interpolate between vectors
---@field get_relative_angle fun(self:vec3, other:vec3):number Get relative angle to another vec3
---@field is_nan fun(self:vec3):boolean Check if the vector contains NaN
---@field get_angle_side fun(self:vec3, other:vec3, up:vec3):string Determine the side of the angle relative to another vector
vec3 = {}

--- Creates a new vec3
---@param x number
---@param y number
---@param z number
---@return vec3
function vec3.new(x, y, z) end

--- Creates a new vec3
---@param x number
---@param y number
---@param z number
---@return vec3
function vec3:new(x, y, z) end

--- Get the x coordinate
---@param self vec3
---@return number
function vec3:x() end

--- Get the y coordinate
---@param self vec3
---@return number
function vec3:y() end

--- Get the z coordinate
---@param self vec3
---@return number
function vec3:z() end

--- Get the rotation
---@param self vec3
---@return number
function vec3:get_rotation() end

--- Normalize the vector
---@param self vec3
---@return vec3
function vec3:normalize() end

--- Normalize the rotation
---@param self vec3
---@return vec3
function vec3:normalize_rotation() end

--- Calculate dot product with another vec3
---@param self vec3
---@param other vec3
---@return number
function vec3:dot_product(other) end

--- Check if the vector is zero
---@param self vec3
---@return boolean
function vec3:is_zero() end

--- Get the angle in radians
---@param self vec3
---@return number
function vec3:get_angle() end

--- Get extended vector by a specific distance
---@param self vec3
---@param point vec3
---@param distance number
---@return vec3
function vec3:get_extended(point, distance) end

--- Rotate around a pivot by an angle
---@param self vec3
---@param angle number
---@param pivot vec3
---@return vec3
function vec3:rotate_around(angle, pivot) end

--- Check equality ignoring z-coordinate
---@param self vec3
---@param other vec3
---@param tolerance number
---@return boolean
function vec3:equals_ignore_z(other, tolerance) end

--- Check if intersects with another vec3
---@param self vec3
---@param other vec3
---@return boolean
function vec3:intersects(other) end

--- Check if facing another vec3 within angle tolerance
---@param self vec3
---@param other vec3
---@param angle_tolerance number
---@return boolean
function vec3:is_facing(other, angle_tolerance) end

--- Convert to string
---@param self vec3
---@return string
function vec3:to_string() end

--- Randomize x and z components
---@param self vec3
---@param amount number
---@return vec3
function vec3:randomize_xz(amount) end

--- Get the length in 2D
---@param self vec3
---@return number
function vec3:length_2d() end

--- Get the length in 3D
---@param self vec3
---@return number
function vec3:length_3d() end

--- Get squared length in 3D
---@param self vec3
---@return number
function vec3:length_3d_squared() end

--- Calculate distance to another vec3
---@param self vec3
---@param other vec3
---@return number
function vec3:dist_to(other) end

--- Calculate squared distance to another vec3
---@param self vec3
---@param other vec3
---@return number
function vec3:squared_dist_to(other) end

--- Get 3D length ignoring z
---@param self vec3
---@return number
function vec3:length_3d_ignore_z() end

--- Calculate distance ignoring z
---@param self vec3
---@param other vec3
---@return number
function vec3:dist_to_ignore_z(other) end

--- Calculate squared distance ignoring z
---@param self vec3
---@param other vec3
---@return number
function vec3:squared_dist_to_ignore_z(other) end

--- Get perpendicular vector to the left
---@param self vec3
---@return vec3
function vec3:get_perp_left() end

--- Get perpendicular vector to the right
---@param self vec3
---@return vec3
function vec3:get_perp_right() end

--- Linearly interpolate between vectors
---@param self vec3
---@param target vec3
---@param t number
---@return vec3
function vec3:lerp(target, t) end

--- Get relative angle to another vec3
---@param self vec3
---@param other vec3
---@return number
function vec3:get_relative_angle(other) end

--- Check if the vector contains NaN
---@param self vec3
---@return boolean
function vec3:is_nan() end

--- Determine the side of the angle relative to another vector
---@param self vec3
---@param other vec3
---@param up vec3
---@return string
function vec3:get_angle_side(other, up) end

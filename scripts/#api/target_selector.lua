---@diagnostic disable: missing-return

--- @class area_result
--- @field public main_target game.object|nil
--- @field public n_hits number
--- @field public score number
--- @field public victim_list game.object[]

--- @class area_result_light
--- @field public main_target game.object
--- @field public n_hits number
--- @field public score number

--- @class target_selector
target_selector = {}

--- Checks if the given object is a valid enemy.
--- @param obj game.object
--- @return boolean
function target_selector.is_valid_enemy(obj) end

--- Gets the target for PvP mode within a specified distance from the source.
--- @param source vec3
--- @param dist number
--- @return game.object
function target_selector.get_pvp_target(source, dist) end

--- Gets the target closest to the source within a specified distance.
--- @param source vec3
--- @param dist number
--- @return game.object
function target_selector.get_target_closer(source, dist) end

--- Gets the target with the lowest health within a specified distance from the source.
--- @param source vec3
--- @param dist number
--- @return game.object
function target_selector.get_target_low_hp(source, dist) end

--- Gets the target with the most health within a specified distance from the source.
--- @param source vec3
--- @param dist number
--- @return game.object
function target_selector.get_target_most_hp(source, dist) end

--- Gets the target area in a circular region within a specified distance from the source.
--- @param source vec3
--- @param dist number
--- @param radius number
--- @param min_hits number
--- @return area_result
function target_selector.get_target_area_circle(source, dist, radius, min_hits) end

--- Gets the target with the most hits in a rectangular area (light version).
--- @param source vec3
--- @param rect_length number
--- @param rect_width number
--- @param prio_champion boolean
--- @return area_result_light
function target_selector.get_most_hits_target_rectangle_area_light(source, rect_length, rect_width, prio_champion) end

--- Gets the target with the most hits in a circular area (light version).
--- @param source vec3
--- @param dist number
--- @param radius number
--- @param prio_champions boolean
--- @return area_result_light
function target_selector.get_most_hits_target_circular_area_light(source, dist, radius, prio_champions) end

--- Gets the target with the most hits in a rectangular area (heavy version).
--- @param source vec3
--- @param rect_length number
--- @param rect_width number
--- @return area_result
function target_selector.get_most_hits_target_rectangle_area_heavy(source, rect_length, rect_width) end

--- Gets the target with the most hits in a circular area (heavy version).
--- @param source vec3
--- @param dist number
--- @param radius number
--- @return area_result
function target_selector.get_most_hits_target_circular_area_heavy(source, dist, radius) end

--- Gets a list of targets near the specified source within a maximum range.
--- @param source vec3
--- @param max_range number
--- @return game.object[]
function target_selector.get_near_target_list(source, max_range) end

--- Gets the closest champion within a specified range.
--- @param source vec3
--- @param max_range number
--- @return game.object
function target_selector.get_quick_champion(source, max_range) end

--- Checks if there is a wall collision between the source and target.
--- @param source vec3
--- @param target game.object
--- @param width number
--- @return boolean
function target_selector.is_wall_collision(source, target, width) end

--- Checks if there is a unit collision between the source and target.
--- @param source vec3
--- @param target game.object
--- @param width number
--- @return boolean
function target_selector.is_unit_collision(source, target, width) end

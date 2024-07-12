---@diagnostic disable: missing-return

--- @class objective
objective = {
    unknown = 0,
    revive = 1,
    fight = 2,
    quest = 3,
    travel = 4,
    loot = 5,
    sell = 6,
    repair = 7,
    reset = 8
}

--- @class auto_play
auto_play = {}

--- Checks if auto play is fully active.
--- @return boolean Whether auto play is fully active.
auto_play.is_active = function() end

--- Sets the profile active state.
--- @param state boolean The state to set the profile active.
auto_play.set_is_profile_active = function(state) end

--- Sets the selected dungeon text.
--- @param text string The text to set as the selected dungeon.
auto_play.set_selected_dungeon_text = function(text) end

--- Sets the dungeon entrance name.
--- @param text string The name of the dungeon entrance.
auto_play.set_dungeon_entrance_name = function(text) end

--- Sets the dungeon map name.
--- @param text string The name of the dungeon map.
auto_play.set_dungeon_map_name = function(text) end

--- Sets the world map name.
--- @param text string The name of the world map.
auto_play.set_world_map_name = function(text) end

--- Sets the dungeon entry point.
--- @param point vec3 The entry point of the dungeon.
auto_play.set_dungeon_entry_point = function(point) end

--- Sets the world waypoints.
--- @param waypoints_table table<number, vec3> Table of waypoints.
auto_play.set_world_waypoints = function(waypoints_table) end

--- Sets the dungeon waypoints.
--- @param waypoints_table table<number, vec3> Table of waypoints.
auto_play.set_dungeon_waypoints = function(waypoints_table) end

--- Gets the current objective.
--- @return objective The current objective.
auto_play.get_objective = function() end

-- developer functions
auto_play.sell_routine = function() end
auto_play.salvage_routine = function() end
auto_play.repair_routine = function() end
auto_play.loot_items_around = function() end

auto_play.set_tmp_override = function(time) end

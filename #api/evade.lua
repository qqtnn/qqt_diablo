---@diagnostic disable: missing-return

--- @class evade
evade = {}

--- Registers a circular spell for evasion.
--- @param internal_names string[] List of internal spell names.
--- @param menu_name string Name to display in the menu.
--- @param radius number Radius of the spell effect.
--- @param default_color ImColor Default color of the spell.
--- @param danger_lvl danger_level Danger level of the spell.
--- @param explosion_delay number? Delay before explosion. Default is 100.0.
--- @param is_moving boolean? Indicates if the spell is moving. Default is false.
--- @param set_to_player_pos boolean? Sets spell position to player. Default is false.
--- @param set_to_player_pos_delay number? Delay for setting spell position to player. Default is 0.50.
--- @return boolean
function evade.register_circular_spell(internal_names, menu_name, radius, default_color, danger_lvl, explosion_delay, is_moving, set_to_player_pos, set_to_player_pos_delay) end

--- Registers a rectangular spell for evasion.
--- @param identifier string Identifier for the spell.
--- @param names_v string[] List of spell names.
--- @param w number Width of the spell.
--- @param l number Length of the spell.
--- @param col ImColor Color of the spell.
--- @param is_dynamic boolean Indicates if the spell is dynamic.
--- @param danger_lvl danger_level Danger level of the spell.
--- @param is_project boolean Indicates if the spell is a projectile.
--- @param project_speed number Speed of the projectile.
--- @param max_time_alive number? Maximum time the spell stays alive. Default is 3.0.
--- @param set_pos_to_player_on_creation boolean? Sets position to player on creation. Default is false.
--- @param set_to_player_pos_delay number? Delay for setting position to player. Default is 0.50.
--- @return boolean
function evade.register_rectangular_spell(identifier, names_v, w, l, col, is_dynamic, danger_lvl, is_project, project_speed, max_time_alive, set_pos_to_player_on_creation, set_to_player_pos_delay) end

--- Registers a cone spell for evasion.
--- @param identifier string Identifier for the spell.
--- @param names_v string[] List of spell names.
--- @param rad number Radius of the spell.
--- @param angle number Angle of the spell.
--- @param col ImColor Color of the spell.
--- @param danger_lvl danger_level Danger level of the spell.
--- @param explosion_delay number? Delay before explosion. Default is 100.0.
--- @param is_moving boolean? Indicates if the spell is moving. Default is false.
--- @return boolean
function evade.register_cone_spell(identifier, names_v, rad, angle, col, danger_lvl, explosion_delay, is_moving) end

--- Checks if a position is dangerous.
--- @param pos vec3 Position to check.
--- @return boolean
function evade.is_dangerous_position(pos) end

--- Checks if moving from source position to destination passes through a dangerous zone.
--- @param pos vec3 Destination position.
--- @param source_pos vec3 Source position.
--- @return boolean
function evade.is_position_passing_dangerous_zone(pos, source_pos) end

--- Registers a dash spell for evasion.
--- @param initialize_condition boolean Condition to initialize the dash.
--- @param dash_name string Name of the dash.
--- @param spell_id number ID of the spell.
--- @param range number Range of the dash.
--- @param cast_delay number Delay before casting the dash.
--- @param enable_dash_usage_default_value boolean Default value to enable dash usage.
--- @param enable_dash_for_circular_spells_default_value boolean Default value to enable dash for circular spells.
--- @param enable_dash_for_rect_spells boolean Enable dash for rectangular spells.
function evade.register_dash(initialize_condition, dash_name, spell_id, range, cast_delay, enable_dash_usage_default_value, enable_dash_for_circular_spells_default_value, enable_dash_for_rect_spells) end

--- Sets the pause duration for evasion.
--- @param seconds number Number of seconds to pause.
--- @return nil
function evade.set_pause(seconds) end

--- @enum danger_level
_G.danger_level = {
    low = 1,
    medium = 2,
    high = 3
}

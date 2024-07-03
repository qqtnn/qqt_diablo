-- Setting various properties
auto_play.set_is_profile_active(true);

auto_play.set_selected_dungeon_text("Savinas Hideout");
auto_play.set_dungeon_entrance_name("Portal_Cellar_Flat");
auto_play.set_dungeon_map_name("OWC_Frac_TaigaEast_01");
auto_play.set_world_map_name("Sanctuary_Eastern_Continent");

-- Setting the world waypoints to an empty table (indicating to use the entry point)
auto_play.set_world_waypoints({});

-- Set dungeon entry point using vec3:new
auto_play.set_dungeon_entry_point(vec3:new(-1414.596680, 223.033203, 74.058594));

-- Define and set dungeon waypoints using vec3:new for each waypoint
local dungeon_waypoints = {
    vec3:new(6.505859, 10.597656, 0.259766),
    vec3:new(6.258789, 15.496094, 0.298828),
    vec3:new(1.792969, 17.779297, 0.000000),
    vec3:new(-2.727539, 18.010742, 0.000000),
    vec3:new(-6.616211, 17.582031, 0.000000),
    vec3:new(-12.422852, 18.863281, 0.298828),
    vec3:new(-15.679688, 19.609375, 0.269531)
};

auto_play.set_dungeon_waypoints(dungeon_waypoints);

console.print("Lua Plugin - Savinas Hideout - Version 1.1");

console.print("Note: You should hold 'Call of the Ancients' quest");
console.print("https://www.ign.com/wikis/diablo-4/Call_of_the_Ancients");

-- hold this quest for optimal results
-- https://www.ign.com/wikis/diablo-4/Call_of_the_Ancients
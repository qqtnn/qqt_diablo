local my_utility = require("my_utility/my_utility");

local menu_elements_blood_wave = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_blood_wave_base")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_blood_wave_base")),
}

local function menu()
    
    if menu_elements_blood_wave.tree_tab:push("Blood Wave") then
        menu_elements_blood_wave.main_boolean:render("Enable Spell", "")

        if menu_elements_blood_wave.main_boolean:get() then
            menu_elements_blood_wave.min_max_targets:render("Min Enemies Hit", "Amount of targets to cast the spell")
        end
 
        menu_elements_blood_wave.tree_tab:pop()
    end
end

local spell_id_blood_wave= 658216
local next_time_allowed_cast = 0.0;
local blood_wave_data = spell_data:new(
    2.0,                        -- radius
    7.0,                       -- range
    1.0,                       -- cast_delay
    1.0,                       -- projectile_speed
    true,                       -- has_collision
    spell_id_blood_wave,        -- spell_id
    spell_geometry.rectangular,    -- geometry_type
    targeting_type.skillshot     --targeting_type
)
local function logics(target)

    local menu_boolean = menu_elements_blood_wave.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_blood_wave);

    if not is_logic_allowed then
    return false;
    end;

    local player_pos = get_player_position();

    local destination_wave = 10
    local area_data = target_selector.get_most_hits_target_rectangle_area_heavy(player_pos, destination_wave, 2.2)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, 2.5, 2.5, area_data.victim_list);

    local best_cast_hits = best_cast_data.hits;
    if best_cast_hits < menu_elements_blood_wave.min_max_targets:get()  then
        return false
    end

    local best_cast_position = best_cast_data.point;
    local target_position = target:get_position();

    cast_spell.position(spell_id_blood_wave, best_cast_position, 0.5)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.4;
        
    console.print("Necro Plugin, Casted Blood Wave");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
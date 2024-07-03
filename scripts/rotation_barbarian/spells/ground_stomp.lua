local my_utility = require("my_utility/my_utility")

local menu_elements_ground_stomp_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "ground_stom_bool_base")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_base_ground_stomp"))
}

local function menu()
    
    if menu_elements_ground_stomp_base.tree_tab:push("Ground Stomp")then
        menu_elements_ground_stomp_base.main_boolean:render("Enable Spell", "")

        if menu_elements_ground_stomp_base.main_boolean:get() then
            menu_elements_ground_stomp_base.min_max_targets:render("Min Enemies Around", "Amount of targets to cast the spell")
        end
 
        menu_elements_ground_stomp_base.tree_tab:pop()
    end
end

local spell_id_ground_stomp = 186358;

local ground_stomp_spell_data = spell_data:new(
    0.2,                            -- radius
    0.1,                            -- range
    0.4,                            -- cast_delay
    0.1,                            -- projectile_speed
    true,                           -- has_collision
    spell_id_ground_stomp,          -- spell_id
    spell_geometry.circular,        -- geometry_type
    targeting_type.skillshot        --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_ground_stomp_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_ground_stomp);

    if not is_logic_allowed then
        return false;
    end;

    local player_pos = get_player_position()
    local area_data = target_selector.get_most_hits_target_circular_area_light(player_pos, 1.0, 1.0, false)
    local units = area_data.n_hits

    if units < menu_elements_ground_stomp_base.min_max_targets:get() then
        return false;
    end;

    if cast_spell.target(target, ground_stomp_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;

        console.print("Casted Ground Stomp");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
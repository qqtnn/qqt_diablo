local my_utility = require("my_utility/my_utility");

local menu_elements_rabies = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_rabies")),
}

local function menu()
    
    if menu_elements_rabies.tree_tab:push("Rabies")then
        menu_elements_rabies.main_boolean:render("Enable Spell", "")
 
        menu_elements_rabies.tree_tab:pop()
    end
end

local spell_id_rabies = 416337
local next_time_allowed_cast = 0.0;
local rabies_data = spell_data:new(
    0.3,                                -- radius
    1.0,                                -- range
    0.2,                                -- cast_delay
    0.2,                                -- projectile_speed
    true,                               -- has_collision
    spell_id_rabies,                    -- spell_id
    spell_geometry.rectangular,         -- geometry_type
    targeting_type.targeted             --targeting_type
)
local function logics(target)
    
    local menu_boolean = menu_elements_rabies.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_rabies);

    if not is_logic_allowed then
    return false;
    end;

    local player_position = get_player_position();
    local target_position = target:get_position();

    cast_spell.target(target, rabies_data, false) 
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.3;
        
    console.print("Druid Plugin, Casted Rabies");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
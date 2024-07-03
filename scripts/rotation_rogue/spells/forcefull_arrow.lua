local my_utility = require("my_utility/my_utility")

local menu_elements_forcefull_arrow_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "forcefull_arrow_base_bool_main")),
}

local function menu()
    
    if menu_elements_forcefull_arrow_base.tree_tab:push("Forcefull Arrow")then
        menu_elements_forcefull_arrow_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_forcefull_arrow_base.tree_tab:pop()
    end
end

local spell_id_forcefull_arrow = 416272;

local spell_data_forcefull_arrow = spell_data:new(
    1.0,                        -- radius
    8.0,                        -- range
    0.8,                        -- cast_delay
    2.5,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_forcefull_arrow,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_forcefull_arrow_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_forcefull_arrow);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_data_forcefull_arrow, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 1.0;

        console.print("Rouge, Casted Forcefull Arrow");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
local my_utility = require("my_utility/my_utility")

local boulder_menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "boulder_main_boolean")),
}

local function menu()
    
    if boulder_menu_elements.tree_tab:push("Boulder")then
        boulder_menu_elements.main_boolean:render("Enable Spell", "")
 
        boulder_menu_elements.tree_tab:pop()
    end
end

local spell_id_boulder = 238345;

local boulder_spell_data = spell_data:new(
    0.7,                        -- radius
    8.0,                        -- range
    1.0,                        -- cast_delay
    4.0,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_boulder,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = boulder_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_boulder);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, boulder_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.4;

        console.print("Druid Plugin, Casted Boulder");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
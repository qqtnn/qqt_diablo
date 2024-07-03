local my_utility = require("my_utility/my_utility")

local menu_elements_leap =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "base_leap_base_main_bool")),
}

local function menu()
    
    if menu_elements_leap.tree_tab:push("Leap")then
        menu_elements_leap.main_boolean:render("Enable Spell", "")
 
        menu_elements_leap.tree_tab:pop()
    end
end

local spell_id_leap= 196545;

local spell_data_leap = spell_data:new(
    1.5,                        -- radius
    5.0,                        -- range
    1.0,                        -- cast_delay
    0.7,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_leap,              -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.skillshot   --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_leap.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_leap);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.target(target, spell_data_leap, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;

        console.print("Casted Kick");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
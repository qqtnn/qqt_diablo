local my_utility = require("my_utility/my_utility")

local menu_elements_double_kick =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "kick_base_main_bool")),
}

local function menu()
    
    if menu_elements_double_kick.tree_tab:push("Kick")then
        menu_elements_double_kick.main_boolean:render("Enable Spell", "")
 
        menu_elements_double_kick.tree_tab:pop()
    end
end

local spell_id_kick= 199516;

local kick_spell_data = spell_data:new(
    0.4,                        -- radius
    0.1,                        -- range
    0.4,                        -- cast_delay
    0.3,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_kick,              -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_double_kick.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_kick);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.target(target, kick_spell_data, false) then

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
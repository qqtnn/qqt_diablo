local my_utility = require("my_utility/my_utility")

local menu_elements_rupture =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "rupture_base_main_bool")),
}

local function menu()
    
    if menu_elements_rupture.tree_tab:push("Rupture")then
        menu_elements_rupture.main_boolean:render("Enable Spell", "")
 
        menu_elements_rupture.tree_tab:pop()
    end
end

local spell_id_rupture= 215027;

local rupture_spell_data = spell_data:new(
    0.3,                        -- radius
    0.2,                        -- range
    1.0,                        -- cast_delay
    0.1,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_rupture,              -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_rupture.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_rupture);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.target(target, rupture_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 1.0;

        console.print("Casted Rupture");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
local my_utility = require("my_utility/my_utility");

local menu_elements_sever_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_sever_base")),
}

local function menu()
    
    if menu_elements_sever_base.tree_tab:push("Sever") then
        menu_elements_sever_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_sever_base.tree_tab:pop()
    end
end

local sever_spell_id = 481785;
local next_time_allowed_cast = 0.0;
local sever_spell_data = spell_data:new(
    0.40,                       -- radius
    8.00,                       -- range
    0.20,                       -- cast_delay
    12.0,                       -- projectile_speed
    true,                       -- has_wall_collision
    sever_spell_id,            -- spell_id
    spell_geometry.circular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
);
local function logics(target)

    local menu_boolean = menu_elements_sever_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                sever_spell_id);

    if not is_logic_allowed then
    return false;
    end;

    local target_position = target:get_position();

    cast_spell.target(target, sever_spell_data, false)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.7;
        
    console.print("Necro Plugin, Casted Sever");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
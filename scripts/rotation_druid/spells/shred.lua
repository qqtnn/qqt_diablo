local my_utility = require("my_utility/my_utility")

local menu_elements_shred =
{
    tree_tab                = tree_node:new(1),
    main_boolean            = checkbox:new(true, get_hash(my_utility.plugin_label .. "_tornado_main_boolean")),
}

local function menu()
    if menu_elements_shred.tree_tab:push("Shred")then
        menu_elements_shred.main_boolean:render("Enable Spell", "")
  
        menu_elements_shred.tree_tab:pop()
     end
end

local spell_id_shred = 1256958;
local next_time_allowed_cast = 0.0;
local shred_data = spell_data:new(
    0.2,                                -- radius
    3.0,                                -- range
    0.4,                                -- cast_delay
    0.4,                                -- projectile_speed
    false,                              -- has_collision
    spell_id_shred,                 -- spell_id
    spell_geometry.rectangular,            -- geometry_type
    targeting_type.targeted             --targeting_type
)

local function logics(target)

    local menu_boolean = menu_elements_shred.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shred);

    if not is_logic_allowed then
        return false;
    end;

    local target_position = target:get_position();

    cast_spell.target(target, shred_data, false)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.7;
        
    console.print("Druid Plugin, Casted Shred");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}

       
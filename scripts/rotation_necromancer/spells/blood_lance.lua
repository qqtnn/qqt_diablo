local my_utility = require("my_utility/my_utility")

local blood_lance_menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "blood_lance_main_boolean_base")),
}

local function menu()
    
    if blood_lance_menu_elements.tree_tab:push("Blood Lance")then
        blood_lance_menu_elements.main_boolean:render("Enable Spell", "")
 
        blood_lance_menu_elements.tree_tab:pop()
    end
end

local spell_id_blood_lance = 501629;

local spell_data_blood_lance = spell_data:new(
    0.7,                        -- radius
    8.0,                        -- range
    1.6,                        -- cast_delay
    2.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_blood_lance,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = blood_lance_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_blood_lance);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_data_blood_lance, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.7;

        console.print("Druid Plugin, Casted Fire Bolt");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
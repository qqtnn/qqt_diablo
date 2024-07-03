local my_utility = require("my_utility/my_utility")

local menu_elements_blade_shift_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "blade_shift_base_main_bool")),
}

local function menu()
    
    if menu_elements_blade_shift_base.tree_tab:push("Blade Shift")then
        menu_elements_blade_shift_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_blade_shift_base.tree_tab:pop()
    end
end

local blade_shift_spell_id = 399111;

local spell_data_shift_spell = spell_data:new(
    0.2,                        -- radius
    0.2,                        -- range
    0.2,                        -- cast_delay
    3.0,                        -- projectile_speed
    true,                      -- has_collision
    blade_shift_spell_id,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_blade_shift_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                blade_shift_spell_id);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_data_shift_spell, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.6;

        console.print("Rouge, Casted Blade Shift");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
local my_utility = require("my_utility/my_utility")

local menu_elements_twisting_blade =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "twisting_blade_main_bool_base")),
}

local function menu()
    
    if menu_elements_twisting_blade.tree_tab:push("Twisting Blade")then
        menu_elements_twisting_blade.main_boolean:render("Enable Spell", "")
 
        menu_elements_twisting_blade.tree_tab:pop()
    end
end

local spell_id_twisting_blade = 398258;

local spell_data_twist_blade = spell_data:new(
    0.2,                        -- radius
    0.2,                        -- range
    0.3,                        -- cast_delay
    0.2,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_twisting_blade,      -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_twisting_blade.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_twisting_blade);

    if not is_logic_allowed then
        return false;
    end;

    -- local player_local = get_local_player();
    
    local spell_range = 2.250
    local player_position = get_player_position();
    local target_position = target:get_position();
    local distance_sqr = target_position:squared_dist_to_ignore_z(player_position)
    if distance_sqr > (spell_range * spell_range ) then
        return false
    end

    if cast_spell.target(target, spell_data_twist_blade, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.1;

        console.print("Rouge, Casted Twisting Blades");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
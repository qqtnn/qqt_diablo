local my_utility = require("my_utility/my_utility")

local menu_elements_invigorating_strike_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "invig_main_bool_base")),
}

local function menu()
    
    if menu_elements_invigorating_strike_base.tree_tab:push("Invigorating Strike")then
        menu_elements_invigorating_strike_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_invigorating_strike_base.tree_tab:pop()
    end
end

local invigorating_strike_spell_id = 416057;

local spell_data_invigorating_strike = spell_data:new(
    0.2,                        -- radius
    0.2,                        -- range
    0.2,                        -- cast_delay
    3.0,                        -- projectile_speed
    true,                           -- has_collision
    invigorating_strike_spell_id,           -- spell_id
    spell_geometry.rectangular,          -- geometry_type
    targeting_type.skillshot            --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_invigorating_strike_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                invigorating_strike_spell_id);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_data_invigorating_strike, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.6;

        console.print("Rouge, Casted Invigorating Strike");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
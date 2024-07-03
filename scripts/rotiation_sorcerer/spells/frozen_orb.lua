local my_utility = require("my_utility/my_utility")

local frozen_orb_menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "spark_main_boolean")),
}

local function menu()
    
    if frozen_orb_menu_elements.tree_tab:push("Frozen Orb")then
        frozen_orb_menu_elements.main_boolean:render("Enable Spell", "")
 
        frozen_orb_menu_elements.tree_tab:pop()
    end
end

local spell_id_fozen_orb = 291347;

local frozen_orb_data = spell_data:new(
    1.5,                        -- radius
    2.0,                        -- range
    1.0,                        -- cast_delay
    2.5,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_fozen_orb,             -- spell_id
    spell_geometry.circular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = frozen_orb_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_fozen_orb);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, frozen_orb_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.6;

        console.print("Sorc Plugin, Casted Frozen Orb");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
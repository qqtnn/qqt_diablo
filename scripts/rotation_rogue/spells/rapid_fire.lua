local my_utility = require("my_utility/my_utility")

local menu_elements_rapid_fire_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "rapid_fire_base_main_bool")),

    combo_points_slider = slider_int:new(0, 6, 0, get_hash(my_utility.plugin_label .. "rapid_fire_min_combo_points_2")),

}

local function menu()
    
    if menu_elements_rapid_fire_base.tree_tab:push("Rapid Fire")then
        menu_elements_rapid_fire_base.main_boolean:render("Enable Spell", "")

        menu_elements_rapid_fire_base.combo_points_slider:render("Min Combo Points", "")
 
        menu_elements_rapid_fire_base.tree_tab:pop()
    end
end

local spell_id_rapid_fire = 355926;

local spelL_data_rapid_fire = spell_data:new(
    1.0,                        -- radius
    9.0,                        -- range
    3.0,                        -- cast_delay
    5.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_rapid_fire,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_rapid_fire_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_rapid_fire);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();

    local combo_points = player_local:get_rogue_combo_points()

    local min_combo_points = menu_elements_rapid_fire_base.combo_points_slider:get()
    if min_combo_points > 0 and combo_points < min_combo_points then
        return false
    end
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    local is_collision = prediction.is_wall_collision(player_position, target_position, 0.5)
    if is_collision then
        return false
    end

    -- is this an skillshot? idk, its being casted as target spell
    if cast_spell.target(target, spelL_data_rapid_fire, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 1.0;

        console.print("Rouge, Casted Rapid Fire");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
local my_utility = require("my_utility/my_utility")

---- MENU
local menu_elements_whirl_wind_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "whirl_wind_base_main_bool")),
    use_as_filler_only  = checkbox:new(true, get_hash(my_utility.plugin_label .. "use_as_filler_only_whirl_wind")),
}

local function menu()
    
    if menu_elements_whirl_wind_base.tree_tab:push("whirl_wind")then
        menu_elements_whirl_wind_base.main_boolean:render("Enable Spell", "")

        if menu_elements_whirl_wind_base.main_boolean:get() then
            menu_elements_whirl_wind_base.use_as_filler_only:render("Fury Check", "Prevent casting with a low fury")
         end
 
         menu_elements_whirl_wind_base.tree_tab:pop()
    end
end


-- OTHERS

local spell_id_whirl_wind = 206435;

local spell_data_whirl_wind = spell_data:new(
    0.2,                        -- radius
    4.0,                        -- range
    0.01,                        -- cast_delay
    0.4,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_whirl_wind,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_whirl_wind_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_whirl_wind);

    if not is_logic_allowed then
        return false
    end

    local is_filler_enabled = menu_elements_whirl_wind_base.use_as_filler_only:get();
    if is_filler_enabled then
        local player_local = get_local_player();

        local current_resource_ws = player_local:get_primary_resource_current();
        local max_resource_ws = player_local:get_primary_resource_max();
        local fury_perc = current_resource_ws / max_resource_ws
        local low_in_fury = fury_perc < 0.3

        if low_in_fury then
            return false
        end
    end
    local enemies = actors_manager.get_enemy_npcs();
    local x = 5

    local player_position = get_player_position()
    local is_wall_collision = target_selector.is_wall_collision(player_position, target, 1.20);
    if is_wall_collision then
        return false;
    end

    for i, enemy in ipairs(enemies) do
        local enemy_distance = player_position:dist_to(enemy:get_position())
        if enemy_distance < x then
            if cast_spell.target(target, spell_data_whirl_wind, false) then
                local current_time = get_time_since_inject();
                next_time_allowed_cast = current_time;
                console.print("Casted whirl_wind");
                return true
            end
        end
    end
    return false
end


return 
{
    menu = menu,
    logics = logics,   
}
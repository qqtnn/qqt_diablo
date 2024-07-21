local my_utility = require("my_utility/my_utility")

local menu_elements_puncture_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "puncture_main_boolean_base")),
    use_as_filler_only  = checkbox:new(true, get_hash(my_utility.plugin_label .. "_wind_shear_use_as_filler_only_base")),
    activate_filter     = checkbox:new(true, get_hash(my_utility.plugin_label .. "_activate_filter_base")),
    close_distance      = checkbox:new(false, get_hash(my_utility.plugin_label .. "_close_distance_base")),
    range_slider        = slider_int:new(1, 10, 7, get_hash(my_utility.plugin_label .. "_puncture_range_slider")),
}

local function menu()
    if menu_elements_puncture_base.tree_tab:push("Puncture") then
        menu_elements_puncture_base.main_boolean:render("Enable Spell", "")
        if menu_elements_puncture_base.main_boolean:get() then
            menu_elements_puncture_base.activate_filter:render("Activate Distance Check", "Enable distance check")
            if menu_elements_puncture_base.activate_filter:get() then
                menu_elements_puncture_base.close_distance:render("Close Distance to Target", "Move closer if out of range")
                menu_elements_puncture_base.range_slider:render("Spell Range", "Set the range for Puncture")
            end
            menu_elements_puncture_base.use_as_filler_only:render("Filler Only", "Prevent casting with a lot of energy")
        end
        menu_elements_puncture_base.tree_tab:pop()
    end
end

local spell_id_puncture = 364877;

local spell_data_puncture = spell_data:new(
    1.0,                        -- radius
    2.0,                        -- range
    0.8,                        -- cast_delay
    0.3,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_puncture,          -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)
local next_time_allowed_cast = 0.0;

local function logics(target)
    local local_player = get_local_player()
    if not local_player then
        return false
    end

    local menu_boolean = menu_elements_puncture_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_puncture);

    if not is_logic_allowed then
        return false;
    end;

    local spell_range = menu_elements_puncture_base.range_slider:get()
    local player_position = get_player_position();
    local target_position = target:get_position();
    local distance_sqr = target_position:squared_dist_to_ignore_z(player_position)

    local is_filter_enabled = menu_elements_puncture_base.activate_filter:get();  
    if is_filter_enabled then
        if distance_sqr > (spell_range * spell_range) then
            if menu_elements_puncture_base.close_distance:get() then
                pathfinder.request_move(target_position)
                console.print("Moving closer to target")
                return true
            else
                console.print("Skip")
                return false
            end
        end
    end

    local is_filler_enabled = menu_elements_puncture_base.use_as_filler_only:get();  
    if is_filler_enabled then
        local current_resource_ws = local_player:get_primary_resource_current();
        local max_resource_ws = local_player:get_primary_resource_max();
        local energy_perc = current_resource_ws / max_resource_ws 
        local low_in_energy = energy_perc < 0.4

        if not low_in_energy then
            return false;
        end
    end;

    if cast_spell.target(target, spell_data_puncture, false) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.1;

        console.print("Rogue, Casted Puncture");
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
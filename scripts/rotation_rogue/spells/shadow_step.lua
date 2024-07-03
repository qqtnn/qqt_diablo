local my_utility = require("my_utility/my_utility")

local menu_elements_shadow_step_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "shadow_step_base_bool_main")),
    spell_range         = slider_float:new(1.0, 8.50, 7.50, get_hash(my_utility.plugin_label .. "shadow_step_range")),

    cast_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "shadow_stepbase_cast_mode_base_pos")),
    
    -- area
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "shadow_stepbase_keybind_pos")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hitsshadow_stepbase_pos")),

    trigger_range_area      = slider_float:new(0.0, 6.0, 0.0, get_hash(my_utility.plugin_label .. "shadow_step_trigger_range_area")),
    min_hits              = slider_int:new(1, 20, 4, get_hash(my_utility.plugin_label .. "min_hits_to_castshadow_stepbase_pos")),
    spell_radius        = slider_float:new(1.0, 10.0, 3.30, get_hash(my_utility.plugin_label .. "shadow_step_spell_radius")),
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_shadow_stepbase_pos")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "min_percentage_hits_shadow_stepbase_pos")),
    soft_score            = slider_float:new(2.0, 15.0, 4.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_shadow_stepbase_soft_core_pos")),

    -- space
    trigger_range_space       = slider_float:new(0.0, 6.0, 3.0, get_hash(my_utility.plugin_label .. "shadow_step_trigger_range_space")),
    min_range           = slider_float:new(0.0, 6.50, 5.50, get_hash(my_utility.plugin_label .. "shadow_step_min_range")),
    max_dist_cursor     = slider_float:new(1.0, 10.0, 6.50, get_hash(my_utility.plugin_label .. "shadow_step_max_dist_cursor")),
    angle_max           = slider_int:new(10, 180, 60, get_hash(my_utility.plugin_label .. "shadow_step_angle_max")),
}

local function menu()
    
    if menu_elements_shadow_step_base.tree_tab:push("Shadow Step")then
        menu_elements_shadow_step_base.main_boolean:render("Enable Spell", "")
        menu_elements_shadow_step_base.spell_range:render("Spell Range", "", 1)

        local options =  {"Area", "Space"};
        menu_elements_shadow_step_base.cast_mode:render("Mode", options, "");
        local is_area = menu_elements_shadow_step_base.cast_mode:get() == 0
        if is_area then
            menu_elements_shadow_step_base.keybind:render("Keybind", "");
            menu_elements_shadow_step_base.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

            menu_elements_shadow_step_base.trigger_range_area:render("Trigger Range", "", 1)
            menu_elements_shadow_step_base.min_hits:render("Min Hits", "");
            menu_elements_shadow_step_base.spell_radius:render("Spell Radius", "", 1)
            menu_elements_shadow_step_base.allow_percentage_hits:render("Allow Percentage Hits", "");
            if menu_elements_shadow_step_base.allow_percentage_hits:get() then
                menu_elements_shadow_step_base.min_percentage_hits:render("Min Percentage Hits", "", 1);
                menu_elements_shadow_step_base.soft_score:render("Soft Score", "", 1);
            end
        else
            menu_elements_shadow_step_base.trigger_range_space:render("Trigger Range", "", 1)
            menu_elements_shadow_step_base.min_range:render("Min Range", "", 1)
            menu_elements_shadow_step_base.max_dist_cursor:render("Max Dist Cursor", "", 1)
            menu_elements_shadow_step_base.angle_max:render("Angle Max", "")
        end
        
        menu_elements_shadow_step_base.tree_tab:pop()
    end
end
local my_target_selector = require("my_utility/my_target_selector");
local spell_id_shadow_step = 355606;

local spell_data_shadow_step = spell_data:new(
    0.5,                        -- radius
    8.0,                        -- range
    0.8,                        -- cast_delay
    1.5,                        -- projectile_speed
    false,                       -- has_collision
    spell_id_shadow_step,               -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)

local debug_console = false
local next_time_allowed_cast = 0.0;
local function get_area_target(entity_list, target_selector_data, best_target, closest_target)
    
    local player_position = get_player_position()
    local cursor_position = get_cursor_position();
    local keybind_used = menu_elements_shadow_step_base.keybind:get_state();
    local keybind_ignore_hits = menu_elements_shadow_step_base.keybind_ignore_hits:get();
   
       ---@type boolean
        local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("keybind_used " .. keybind_used)

    if not keybind_can_skip then
        local player_dist_cursor_sqr = cursor_position:squared_dist_to_ignore_z(player_position)
        if player_dist_cursor_sqr < (1.22 * 1.22) then
            return false
        end
    end
    
    local is_percentage_hits_allowed = menu_elements_shadow_step_base.allow_percentage_hits:get();
    local min_percentage = menu_elements_shadow_step_base.min_percentage_hits:get();
    if not is_percentage_hits_allowed then
        min_percentage = 0.0;
    end

    local spell_range =  menu_elements_shadow_step_base.spell_range:get()
    local spell_radius =  menu_elements_shadow_step_base.spell_radius:get()
    local min_hits_menu = menu_elements_shadow_step_base.min_hits:get();

    local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)
    if not area_data.main_target then
        if debug_console then
            console.print("shadow_step AREA leaving 11111")
        end
       
        return nil;
    end

    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage);

    if not is_area_valid and not keybind_can_skip  then
        if debug_console then
            console.print("shadow_step AREA leaving 22222")
        end
        return nil;
    end

    if not area_data.main_target:is_enemy() then
        if debug_console then
            console.print("shadow_step AREA leaving 33333")
        end
        return nil;
    end

    local constains_relevant = false;
    for _, victim in ipairs(area_data.victim_list) do
        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            constains_relevant = true;
        end
    end

    if not constains_relevant and area_data.score < menu_elements_shadow_step_base.soft_score:get() and not keybind_can_skip  then
        if debug_console then
            console.print("shadow_step AREA leaving 44444")
            console.print("constains_relevant " .. tostring(constains_relevant))
            console.print("area_data.score " .. tostring(area_data.score))
            console.print("keybind_can_skip " .. tostring(keybind_can_skip))
        end

        return nil;
    end

    local cast_position_a = area_data.main_target:get_position();
    local best_cast_data = my_utility.get_best_point(cast_position_a, spell_radius, area_data.victim_list);
 
    -- Initialize variables to store the closest target to the point
    local closer_target_to_zone = nil
    local closest_distance_sqr = math.huge

    -- Loop through the list of victims to find the closest one to the point
    for _, victim in ipairs(best_cast_data.victim_list) do
        local victim_position = victim:get_position()
        local distance_sqr =  best_cast_data.point :squared_dist_to_ignore_z(victim_position)
        
        -- If the distance to the current victim is less than the closest distance so far, update the closest target
        if distance_sqr < closest_distance_sqr then
            closer_target_to_zone = victim
            closest_distance_sqr = distance_sqr
        end
    end
    

    return closer_target_to_zone
end

local function get_space_target(entity_list, target_selector_data, best_target, closest_target)

    local player_position = get_player_position();
    local is_auto_play_active = auto_play.is_active();
    local cursor_position = get_cursor_position()
    local spell_range =menu_elements_shadow_step_base.spell_range:get()
    local max_angle =menu_elements_shadow_step_base.angle_max:get()
    local min_range = menu_elements_shadow_step_base.min_range:get()
    local max_dist_cursor = menu_elements_shadow_step_base.max_dist_cursor:get()
    for index, unit in ipairs(entity_list) do
        local unit_position = unit:get_position()
        local distance_sqr = player_position:squared_dist_to_ignore_z(unit_position)
        if distance_sqr < (spell_range * spell_range) then
            if distance_sqr > (min_range * min_range) or min_range <= 0.0 then
                if is_auto_play_active then
                    return unit
                else
                    local cursor_dist_qqr = unit_position:squared_dist_to_ignore_z(cursor_position)
                    if cursor_dist_qqr < (max_dist_cursor * max_dist_cursor) or max_dist_cursor <= 0.0 then
                        local angle = unit_position:get_angle(cursor_position, player_position)
                        if angle < max_angle or max_angle <= 0.0 then
                            return unit
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

local function logics(entity_list, target_selector_data, best_target, closest_target)
    
    local menu_boolean = menu_elements_shadow_step_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shadow_step);

    if not is_logic_allowed then
        return false;
    end;

    local player_position = get_player_position();
    local closer_target_position = closest_target:get_position();
    local distance_sqr_close = closer_target_position:squared_dist_to_ignore_z(player_position)

    local target = nil
    local is_area = menu_elements_shadow_step_base.cast_mode:get() == 0
    if is_area then

        local trigger_range =  menu_elements_shadow_step_base.trigger_range_area:get()
        if trigger_range > 0.0 then
            if distance_sqr_close > (trigger_range * trigger_range) and trigger_range > 0.0 then
                if debug_console then
                    console.print("shadow step no trigger close (area)")
                end
                return false
            end
        end

        local target_to_cast = get_area_target(entity_list, target_selector_data, best_target, closest_target)
        if not target_to_cast then
            return false
        end
        target = target_to_cast
    else

        local trigger_range =  menu_elements_shadow_step_base.trigger_range_space:get()
        if trigger_range > 0.0 then
            if distance_sqr_close > (trigger_range * trigger_range) and trigger_range > 0.0 then
                if debug_console then
                    console.print("shadow step no trigger close (area)")
                end
                return false
            end
        end

        local target_to_cast = get_space_target(entity_list, target_selector_data, best_target, closest_target)
        if not target_to_cast then
            return false
        end
        target = target_to_cast
    end

    if not target then
        return false
    end

    local target_position = target:get_position();
    if evade.is_dangerous_position(target_position) then
        return false;
    end

    local spell_range =menu_elements_shadow_step_base.spell_range:get()
    local target_position = target:get_position();
    local distance_sqr = target_position:squared_dist_to_ignore_z(player_position)
    if distance_sqr > (spell_range * spell_range) then
        if debug_console then
            console.print("shadow step out of range target")
        end
        return false
    end

    if cast_spell.target(target, spell_data_shadow_step, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;

        console.print("Rouge, Casted Shadow Step");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
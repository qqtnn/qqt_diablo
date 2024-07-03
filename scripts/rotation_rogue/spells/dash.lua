local my_utility = require("my_utility/my_utility")

local menu_elements_dash_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "dash_base_main_bool")),
    allow_elite_single_target   = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_elite_single_target_base_dash")),
    min_hits_slider             = slider_int:new(0, 30, 4, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_dash_base")),
    spell_range   = slider_float:new(1.0, 15.0, 3.10, get_hash(my_utility.plugin_label .. "dash_base_spell_range_2")),
   
    trap_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "dash_base_base_pos")),
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "dash_base_keybind_pos")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hit_dash_base_pos")),
}

local function menu()
    
    if menu_elements_dash_base.tree_tab:push("Dash")then
        menu_elements_dash_base.main_boolean:render("Enable Spell", "")

        if  menu_elements_dash_base.main_boolean:get() then
            menu_elements_dash_base.allow_elite_single_target:render("Prio Bosses/Elites", "")
            menu_elements_dash_base.min_hits_slider:render("Min Hit Enemies", "")

            menu_elements_dash_base.spell_range:render("Spell Range", "", 1)

            local options =  {"Auto", "Keybind"};
            menu_elements_dash_base.trap_mode:render("Mode", options, "");
            menu_elements_dash_base.keybind:render("Keybind", "");
            menu_elements_dash_base.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");
        end
 
        menu_elements_dash_base.tree_tab:pop()
    end
end

local spell_id_dash = 358761;

local next_time_allowed_cast = 0.0;
local function get_spell_charges(local_player, spell_id_dash)
    if not local_player then 
        return false 
    end

    local charges = local_player:get_spell_charges(spell_id_dash)
    if not charges then
        return false;
    end
    
    if charges <= 0 then
        return false;
    end
    
    return true;
end;

local is_auto_play_active = auto_play.is_active();
local function logics(target)
    
    local menu_boolean = menu_elements_dash_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_dash);

    if not is_logic_allowed then
        return false;
    end;

    local keybind_used = menu_elements_dash_base.keybind:get_state();
    local trap_mode = menu_elements_dash_base.trap_mode:get();
    if trap_mode == 1 then
        if  keybind_used == 0 then   
            return false;
        end;
    end;

    local keybind_ignore_hits = menu_elements_dash_base.keybind_ignore_hits:get();
   
    ---@type boolean
    local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;

    local local_player = get_local_player();
    local is_spell_ready_charges = get_spell_charges(local_player, spell_id_dash)
    if not is_spell_ready_charges then
        -- if not local_player:is_spell_ready(spell_id_dash) then
            return false;
        -- end
    end

    local player_position = get_player_position()
    local cursor_position = get_cursor_position();

    if not keybind_can_skip then
        local player_dist_cursor_sqr = cursor_position:squared_dist_to_ignore_z(player_position)
        if player_dist_cursor_sqr < (1.22 * 1.22) then
            return false
        end
    end
    
    local spell_range = menu_elements_dash_base.spell_range:get()
    local target_position = target:get_position()
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) and not keybind_can_skip then
        return false
    end

    local rectangle_radius = 1.50;
    local destination_dash = 7.50;
    local area_data = target_selector.get_most_hits_target_rectangle_area_heavy(player_position, destination_dash, rectangle_radius)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, destination_dash, rectangle_radius, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list
    
    local is_single_target_allowed = false;
    if menu_elements_dash_base.allow_elite_single_target:get() then
        for _, unit in ipairs(best_hit_list) do
            local current_health_percentage = unit:get_current_health() / unit:get_max_health()

            if unit:is_boss() and current_health_percentage > 0.15 then
                is_single_target_allowed = true
                break 
            end
       
            if unit:is_elite() and current_health_percentage > 0.35 then
                is_single_target_allowed = true
                break 
            end
        end
    end

    local best_cast_hits = best_cast_data.hits;
    -- console.print("best_cast_hits " .. best_cast_hits)
    if best_cast_hits < menu_elements_dash_base.min_hits_slider:get() and not is_single_target_allowed and not keybind_can_skip then
        return false
    end

    local best_cast_position = best_cast_data.point;

    if not is_auto_play_active then
        -- angle check
        local angle = best_cast_position:get_angle(cursor_position, player_position)
        if angle > 100.0 then
            return false
        end
    end

    local option_1 = best_cast_position:get_extended(player_position, -3.50)
    local enemies_near = target_selector.get_near_target_list(option_1, 2.50)

    if not evade.is_dangerous_position(option_1) and #enemies_near <= 2 then
        
        if cast_spell.position(spell_id_dash, option_1, 0.5) then
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.2;
            -- next_time_allowed_cast = current_time + 7.0;
            console.print("Rouge, Casted Dash (option 1)");
            return true;
        end;
    end

    local option_2 = best_cast_position:get_extended(player_position, -2.00)
    local enemies_near_2 = target_selector.get_near_target_list(option_2, 2.50)

    if not evade.is_dangerous_position(option_2) and #enemies_near_2 <= 1 then
        
        if cast_spell.position(spell_id_dash, option_2, 0.5) then
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.2;
            -- next_time_allowed_cast = current_time + 7.0;
            console.print("Rouge, Casted Dash (option 2)");
            return true;
        end;
    end

    -- local option_2 = best_cast_position
    -- local enemies_near_2 = target_selector.get_near_target_list(option_2, 2.20)
    -- if not evade.is_dangerous_position(option_2) and #enemies_near_2 <= 2 then
    --     if cast_spell.position(spell_id_dash, option_2, 0.5) then
    --         local current_time = get_time_since_inject();
    --         next_time_allowed_cast = current_time + 0.2;
    --         -- next_time_allowed_cast = current_time + 7.0;
    --         console.print("Rouge, Casted Dash (option 2)");
    --         return true;
    --     end;
    -- end
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
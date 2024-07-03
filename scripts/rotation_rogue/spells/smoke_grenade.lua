local my_utility = require("my_utility/my_utility")

local menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "smoke_grenade_base_main_bool")),

    filter_mode         = combo_box:new(1, get_hash(my_utility.plugin_label .. "smoke_grenade_filter_mode")),

    trap_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "smoke_grenade_base_mode")),
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "smoke_grenade_base_keybind_pos")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "smoke_grenade_base_keybind_ignore_min_hitstrap_base_pos")),

    min_hits              = slider_int:new(1, 20, 4, get_hash(my_utility.plugin_label .. "smoke_grenade_base_min_hits_to_casttrap_base_pos")),
    
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_smoke_grenade_base_pos")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "min_percentage_hits_smoke_grenade_base_pos")),
    soft_score            = slider_float:new(2.0, 15.0, 5.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_smoke_grenade_base_soft_core_pos")),

    spell_range   = slider_float:new(1.0, 12.0, 7.50, get_hash(my_utility.plugin_label .. "smoke_grenade_spell_range")),
    spell_radius   = slider_float:new(0.50, 5.0, 2.50, get_hash(my_utility.plugin_label .. "smoke_grenade_spell_radius")),
}

local function menu()
    
    if menu_elements.tree_tab:push("Smoke Grenade")then
        menu_elements.main_boolean:render("Enable Spell", "");

        local dropbox_options = {"No filter", "Elite & Boss Only", "Boss Only"}
        menu_elements.filter_mode:render("Filter Modes", dropbox_options, "")

        local options =  {"Auto", "Keybind"};
        menu_elements.trap_mode:render("Mode", options, "");

        menu_elements.keybind:render("Keybind", "");
        menu_elements.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

        menu_elements.min_hits:render("Min Hits", "");

        menu_elements.allow_percentage_hits:render("Allow Percentage Hits", "");
        if menu_elements.allow_percentage_hits:get() then
            menu_elements.min_percentage_hits:render("Min Percentage Hits", "", 1);
            menu_elements.soft_score:render("Soft Score", "", 1);
        end       

        menu_elements.spell_range:render("Spell Range", "", 1)
        menu_elements.spell_radius:render("Spell Radius", "", 1)

        menu_elements.tree_tab:pop();
    end
end

local spell_id_smoke_grenade = 356162;
local my_target_selector = require("my_utility/my_target_selector");
local next_time_allowed_cast = 0.0;
local function logics(entity_list, target_selector_data, best_target)

    -- local spell_data_smoke_grenade = spell_data:new(
    --     spell_radius,                        -- radius
    --     spell_range,                        -- range
    --     1.0,                        -- cast_delay
    --     5.0,                        -- projectile_speed
    --     true,                      -- has_collision
    --     spell_id_smoke_grenade,           -- spell_id
    --     spell_geometry.circular, -- geometry_type
    --     targeting_type.targeted    --targeting_type
    -- )
    
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_smoke_grenade);

    if not is_logic_allowed then
        return false;
    end;

    local player_position = get_player_position()
    local keybind_used = menu_elements.keybind:get_state();
    local trap_mode = menu_elements.trap_mode:get();
    if trap_mode == 1 then
        if  keybind_used == 0 then   
            return false;
        end;
    end;

    local keybind_ignore_hits = menu_elements.keybind_ignore_hits:get();
  
      ---@type boolean
        local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("keybind_used " .. keybind_used)
    
    local is_percentage_hits_allowed = menu_elements.allow_percentage_hits:get();
    local min_percentage = menu_elements.min_percentage_hits:get();
    if not is_percentage_hits_allowed then
        min_percentage = 0.0;
    end

    local spell_range =  menu_elements.spell_range:get()
    local spell_radius =  menu_elements.spell_radius:get()
    local min_hits_menu = menu_elements.min_hits:get();

    local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)

    if not area_data.main_target then
        return false;
    end


    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage);
    -- console.print("hits " .. area_data.hits_amount)
    -- console.print("is_area_valid " .. tostring(is_area_valid) )
    if not is_area_valid and not keybind_can_skip  then
        return false;
    end

    if not area_data.main_target:is_enemy() then
        return false;
    end

    
    local filter_mode = menu_elements.filter_mode:get()

    local constains_relevant_2 = false;
    local constains_relevant = false;
    for _, victim in ipairs(area_data.victim_list) do
        if constains_relevant_2 and constains_relevant then
            break
        end

        if filter_mode == 1 then
            -- boss / elite
            local is_elite = victim:is_elite()
            local is_boss = victim:is_boss()
            local is_champion = victim:is_champion()
            if is_elite or is_boss or is_champion then
                constains_relevant_2 = true
            end
        end
    
        if filter_mode == 2 then
            local is_boss = victim:is_boss()
            if not is_boss then
                constains_relevant_2 = true
            end
        end

        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            constains_relevant = true
        end
    end

    if filter_mode > 0 and not constains_relevant_2 then
        return false
    end

    if not constains_relevant and area_data.score < menu_elements.soft_score:get() and not keybind_can_skip  then
        return false;
    end

    local cast_position = area_data.main_target:get_position();
    local player_position = get_player_position()
    local is_wall_collision = prediction.is_wall_collision(player_position, cast_position, 0.5);
    if is_wall_collision then
        return false
    end

    -- Initialize variables to store the closest target to the point
    local closer_target_to_zone = nil
    local closest_distance_sqr = math.huge

    -- Loop through the list of victims to find the closest one to the point
    for _, victim in ipairs(area_data.victim_list) do
        local victim_position = victim:get_position()
        local distance_sqr = player_position:squared_dist_to_ignore_z(victim_position)
        
        -- If the distance to the current victim is less than the closest distance so far, update the closest target
        if distance_sqr < closest_distance_sqr then
            closer_target_to_zone = victim
            closest_distance_sqr = distance_sqr
        end
    end
    
    if closest_distance_sqr > (spell_range * spell_range) and not keybind_can_skip  then
        -- if debug_console then
        --     console.print("poison_trap leaving 55555 -> " .. math.sqrt(closest_distance_sqr))
        -- end
        return false;
    end

    if cast_spell.position(spell_id_smoke_grenade, cast_position, 0.4)then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.4;
            
        global_poison_trap_last_cast_time = current_time
        global_poison_trap_last_cast_position = cast_position
        console.print("Rouge Plugin, smoke granade");
        return true;
    end
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
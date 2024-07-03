local my_utility = require("my_utility/my_utility")

local menu_elements_iron_maiden_base = {
    decrepify_submenu               = tree_node:new(1),
    main_boolean                    = checkbox:new(true, get_hash(my_utility.plugin_label .. "iron_maiden_boolean_base")),
    decrepify_mode                  = combo_box:new(0, get_hash(my_utility.plugin_label .. "iron_maiden_cast_modes_base")),
    min_hits_slider                 = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "iron_maiden_min_hits_slider_base")),

    allow_elite_single_target       = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_elite_single_target_base_maiden")),
    effect_size_affix_mult      = slider_float:new(0.0, 200.0, 0.0, get_hash(my_utility.plugin_label .. "iron_maiden_effect_size_affix_mult_slider_base")),
}

local function menu()
    if menu_elements_iron_maiden_base.decrepify_submenu:push("Iron Maiden") then
        menu_elements_iron_maiden_base.main_boolean:render("Enable Iron Maiden Cast", "")

        if menu_elements_iron_maiden_base.main_boolean:get() then
            -- create the combo box elements as a table
            local dropbox_options = {"PvP & PvE", "PvP Only", "PvE Only"}
            menu_elements_iron_maiden_base.decrepify_mode:render("Cast Modes", dropbox_options, "")
            menu_elements_iron_maiden_base.min_hits_slider:render("Min Hits", "")
            menu_elements_iron_maiden_base.allow_elite_single_target:render("Allowed Cast On Solo Elites", "")
            menu_elements_iron_maiden_base.effect_size_affix_mult:render("Effect Size Affix Mult", "", 1)
        end

        menu_elements_iron_maiden_base.decrepify_submenu:pop()
    end
end

local iron_maiden_buff_name = "Necromancer_Iron_Maiden";
local iron_maiden_buff_name_hashed_c = 915152;

local decrepify_spell_id = 915152;
-- to get the spell id, go to debug -> draw spell ids

local next_time_allowed_cast = 0.0
-- local last_decrepify_cast_time = 0.0
local function logics()

    local menu_boolean = menu_elements_iron_maiden_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                decrepify_spell_id);

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local current_resource = local_player:get_primary_resource_current();
    local max_resource = local_player:get_primary_resource_max();
    local resource_percentage = current_resource / max_resource; 
    local is_low_resources = resource_percentage < 0.55;

    if is_low_resources then
        return false;
    end;

    local mult = menu_elements_iron_maiden_base.effect_size_affix_mult:get() * 0.01

    local spell_effect_radius_raw = 3.90 -- radius of decrepify
    local circle_radius = spell_effect_radius_raw * (1.0 + mult)
    local player_position = get_player_position();
    local area_data = target_selector.get_most_hits_target_circular_area_heavy(player_position, 9.0, circle_radius)
    local best_target = area_data.main_target;
    
    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point(best_target_position, circle_radius, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list

    local is_single_target_allowed = false;
    if menu_elements_iron_maiden_base.allow_elite_single_target:get() then
        for _, unit in ipairs(best_hit_list) do
            local current_health_percentage = unit:get_current_health() / unit:get_max_health() * 100

            -- Check if the unit is a boss with more than 22% health
            if unit:is_boss() and current_health_percentage > 22 then
                is_single_target_allowed = true
                break -- Exit the loop as the condition has been met
            end
        
            -- Check if the unit is an elite with more than 45% health
            if unit:is_elite() and current_health_percentage > 45 then
                is_single_target_allowed = true
                break -- Exit the loop as the condition has been met
            end
        end
    end

    local best_cast_hits = best_cast_data.hits;
    if best_cast_hits < menu_elements_iron_maiden_base.min_hits_slider:get() and not is_single_target_allowed then
        -- add your logs here if needed
        return false
    end

    local decrepify_count = 0

    -- loop through each unit in the list
    for _, unit in ipairs(best_hit_list) do
        -- retrieve the list of buffs for the unit
        local buffs = unit:get_buffs()

        -- check each buff to see if it's 'decrepify'
        for _, buff in ipairs(buffs) do
            if buff.name_hash == iron_maiden_buff_name_hashed_c then
                decrepify_count = decrepify_count + 1
                break -- break the inner loop once 'decrepify' is found
            end
        end
    end

    -- calculate the percentage of units with the 'decrepify' buff
    local percentage_with_buff = (decrepify_count / best_cast_hits);

    -- set is_allowed based on the percentage
    local is_allowed = percentage_with_buff < 0.25;

    if not is_allowed then
        return false;
    end

    local best_cast_position = best_cast_data.point;
    if cast_spell.position(decrepify_spell_id, best_cast_position, 0.40) then
        console.print("Necromancer Plugin, Casted Decrepify, Target " .. best_target:get_skin_name() .. " Hits: " .. best_cast_hits);
        -- last_decrepify_cast_time = get_time_since_inject();
        return true;
    end
    
    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
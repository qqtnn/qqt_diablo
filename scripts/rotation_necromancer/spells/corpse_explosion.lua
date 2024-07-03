local my_utility = require("my_utility/my_utility")

local menu_elements = {
    corpse_explosion_submenu      = tree_node:new(1),
    corpse_explosion_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "corpse_explosion_boolean_base")),
    corpse_explosion_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "corpse_explosion_cast_modes_base")),
    corpse_explosion_logic        = combo_box:new(0, get_hash(my_utility.plugin_label .. "corpse_explosion_logic_base")),
    effect_size_affix_mult   = slider_float:new(0.0, 200.0, 0.0, get_hash(my_utility.plugin_label .. "corpse_explosion_effect_size_affix_mult_base")), -- Slider from 0.0 to 100.0
}

local function menu()
    if menu_elements.corpse_explosion_submenu:push("Corpse Explosion") then
        menu_elements.corpse_explosion_boolean:render("Enable Explosion Cast", "")

        if menu_elements.corpse_explosion_boolean:get() then
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only"}
            menu_elements.corpse_explosion_mode:render("Cast Modes", dropbox_options, "")
            local logic_options = {"Default", "Runing Corpses"};
            menu_elements.corpse_explosion_logic:render("Logic", logic_options, "");
            menu_elements.effect_size_affix_mult:render("Effect Size Affix Mult", "", 1)
        end

        menu_elements.corpse_explosion_submenu:pop()
    end
end

local corpse_explosion_id = 432897
-- to get the spell id, go to debug -> draw spell ids

local corpse_explosion_spell_data = spell_data:new(
    1.0,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    10.0,                       -- projectile_speed
    true,                       -- has_collision
    corpse_explosion_id,        -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.targeted     --targeting_type
)

local function get_corpse_explosion_data_default()
-- Hit Calculation: We now calculate the number of enemies each corpse can hit using utility.get_amount_of_units_inside_circle(center, radius).
-- Sorting: The list of corpses is sorted by the number of hits in descending order.
-- Return Value: The function returns the corpse that can potentially hit the most enemies. If no such corpse is found, it returns {is_valid = false, corpse = nil, hits = 0}.

    local raw_radius = 3.0;  -- Base radius for the explosion
    local multiplier = menu_elements.effect_size_affix_mult:get() / 100;  -- Convert the percentage to a multiplier
    local corpse_explosion_range = raw_radius * (1.0 + multiplier);  -- Calculate the new radius
    -- local corpse_explosion_range = 3.0; -- default corpse range
    local player_position = get_player_position();
    local actors = actors_manager.get_ally_actors();

    local great_corpse_list = {};
    for _, object in ipairs(actors) do
        local skin_name = object:get_skin_name();
        local is_corpse = skin_name == "Necro_Corpse";
        
        if is_corpse then
            local corpse_position = object:get_position();
            local distance_to_player_sqr = corpse_position:squared_dist_to_ignore_z(player_position);
            if distance_to_player_sqr <= (9.0 * 9.0) then
                -- Calculate how many enemies this corpse can hit
                local hits = utility.get_amount_of_units_inside_circle(corpse_position, corpse_explosion_range)
                if hits > 0 then
                    table.insert(great_corpse_list, {hits = hits, corpse = object});
                end
            end
        end
    end

    -- Sort the list by the number of hits
    table.sort(great_corpse_list, function(a, b)
        return a.hits > b.hits
    end);

    -- Return the corpse that can hit the most enemies, if any
    if #great_corpse_list > 0 then
        local corpse_ = great_corpse_list[1].corpse;
        if corpse_ then
            return {is_valid = true, corpse = corpse_, hits = great_corpse_list[1].hits};
        end       
    end

    return {is_valid = false, corpse = nil, hits = 0};
end


local function get_corpse_explosion_data_runing_corpses()
-- Find the nearest enemy to each corpse within a 9-meter radius.
-- For each of these nearest enemies, calculate how many enemies are within a 3-meter radius (the explosion radius).
-- Choose the corpse whose nearest enemy has the most enemies packed around it within the explosion radius.

    local travel_distance = 9.0;  -- Distance for skeleton to travel
    local explosion_radius = 3.0;  -- Explosion radius
    local player_position = get_player_position();
    local actors = actors_manager.get_ally_actors();
    local enemies = actors_manager.get_enemy_npcs();

    local best_corpse = nil;
    local max_packed_enemies = 0;

    for _, corpse in ipairs(actors) do
        local skin_name = corpse:get_skin_name();
        local is_corpse = skin_name == "Necro_Corpse";

        if is_corpse then
            local corpse_position = corpse:get_position();
            local distance_to_player_sqr = corpse_position:squared_dist_to_ignore_z(player_position);

            if distance_to_player_sqr <= (travel_distance * travel_distance) then
                local nearest_enemy, nearest_enemy_distance = nil, travel_distance * travel_distance;

                -- Find the nearest enemy to the corpse
                for _, enemy in ipairs(enemies) do
                    local enemy_position = enemy:get_position();
                    local distance_sqr = enemy_position:squared_dist_to_ignore_z(corpse_position);

                    if distance_sqr < nearest_enemy_distance then
                        nearest_enemy = enemy;
                        nearest_enemy_distance = distance_sqr;
                    end
                end

                -- If a nearest enemy is found, check how packed the enemies are around it
                if nearest_enemy then
                    local packed_enemies = utility.get_amount_of_units_inside_circle(nearest_enemy:get_position(), explosion_radius);

                    if packed_enemies > max_packed_enemies then
                        best_corpse = corpse;
                        max_packed_enemies = packed_enemies;
                    end
                end
            end
        end
    end

    -- Return the corpse with the most packed enemies around its nearest enemy
    if best_corpse then
        return {is_valid = true, corpse = best_corpse, hits = max_packed_enemies};
    end

    return {is_valid = false, corpse = nil, hits = 0};
end

local function get_corpse_explosion_data()
    local is_runing_corpse_logic = menu_elements.corpse_explosion_logic:get() == 1;
    if is_runing_corpse_logic then
        return get_corpse_explosion_data_runing_corpses();
    end

    return get_corpse_explosion_data_default();
end

local last_corpse_explosion = 0.0;
local function logics()
    
    local menu_boolean = menu_elements.corpse_explosion_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_corpse_explosion, 
                corpse_explosion_id);

    if not is_logic_allowed then
        return false;
    end;

    if not utility.can_cast_spell(corpse_explosion_id) then
        return false;
    end

    local corpses_data = get_corpse_explosion_data();
    if not corpses_data.is_valid then
        return false;
    end
     
    if cast_spell.target(corpses_data.corpse, corpse_explosion_id, 0.60, false) then
        local current_time = get_time_since_inject();
        last_corpse_explosion = current_time + 0.70;

        console.print("[Necromancer] [SpellCast] [Corpse Explosion] Hits ", corpses_data.hits);
        
        return true;
    end

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
    get_corpse_explosion_data = get_corpse_explosion_data,
}
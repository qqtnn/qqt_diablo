local my_utility = require("my_utility/my_utility")

local menu_elements_corpse_base = {
    tree_tab_tendrils               = tree_node:new(1),
    main_boolean_tendrils           = checkbox:new(true, get_hash(my_utility.plugin_label .. "tendrils_boolean_base")),
    min_hits                        = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "tendrils_min_hits_base")),
    effect_size_affix_mult      = slider_float:new(0.0, 200.0, 0.0, get_hash(my_utility.plugin_label .. "tendrils__effect_size_affix_mult_slider_base")),
}

local function menu()
    
    if menu_elements_corpse_base.tree_tab_tendrils:push("Corpse Tendrils") then
        menu_elements_corpse_base.main_boolean_tendrils:render("Enable Spell", "")

        if menu_elements_corpse_base.main_boolean_tendrils:get() then
            menu_elements_corpse_base.min_hits:render("Min Hits", "")
            menu_elements_corpse_base.effect_size_affix_mult:render("Effect Size Affix Mult", "", 1)
        end;

        menu_elements_corpse_base.tree_tab_tendrils:pop()
    end 
end

local spell_id_corpse_tendrils = 463349
local next_time_allowed_cast = 0.0;
local corpse_tendrils_spell_data = spell_data:new(
    4.0,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    7.0,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_corpse_tendrils,   -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.targeted     --targeting_type
)

local function corpse_tendrils_data()
    
    -- local travel_distance = 8.0
    local raw_radius = 7.0;  -- Base radius for the explosion
    local multiplier = menu_elements_corpse_base.effect_size_affix_mult:get() / 100;  -- Convert the percentage to a multiplier
    local corpse_tendrils_range = raw_radius * (1.0 + multiplier);  -- Calculate the new radius
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
                local hits = utility.get_amount_of_units_inside_circle(corpse_position, corpse_tendrils_range)
                if hits > 0 then
                    table.insert(great_corpse_list, {hits = hits, corpse = object});
                end
            end
        end
    end

    table.sort(great_corpse_list, function(a, b)
        return a.hits > b.hits
    end);

    if #great_corpse_list > 0 then
        local corpse_ = great_corpse_list[1].corpse;
        if corpse_ then
            return {is_valid = true, corpse = corpse_, hits = great_corpse_list[1].hits};
        end       
    end

    return {is_valid = false, corpse = nil, hits = 0};
end

local function logics()

    local menu_boolean = menu_elements_corpse_base.main_boolean_tendrils:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_corpse_tendrils);

    if not is_logic_allowed then
        return false;
    end;

    local circle_radius = 7.0
    local player_position = get_player_position();
    local area_data = target_selector.get_most_hits_target_circular_area_heavy(player_position, 8.0, circle_radius)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end

    local tendrils_data = corpse_tendrils_data()
    if not tendrils_data.is_valid then
        return false;
    end;
    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point(best_target_position, circle_radius, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list

    local best_cast_hits = best_cast_data.hits;
    local is_min_hit_enabled = menu_elements_corpse_base.min_hits:get()
    if is_min_hit_enabled then
    if best_cast_hits < menu_elements_corpse_base.min_hits:get() then
        return false
    end

    if cast_spell.target(tendrils_data.corpse, spell_id_corpse_tendrils, 2.0, false) then
        console.print("[Necromancer] [SpellCast] [Corpse Tendrils] Hits ", tendrils_data.hits);
        return true;
    end
end
end


return
{
    menu = menu,
    logics = logics,
}
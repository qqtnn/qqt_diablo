local my_utility = require("my_utility/my_utility")
local bash = require("spells/bash")

local menu_elements_steel_grasp =
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_grasp_steel_b_pos")),

    trap_mode             = combo_box:new(0, get_hash(my_utility.plugin_label .. "grasp_steel_b_base_pos")),
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "grasp_steel_b_keybind_pos")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hitsgrasp_steel_b_pos")),

    min_hits              = slider_int:new(1, 20, 4, get_hash(my_utility.plugin_label .. "min_hits_to_castgrasp_steel_b_pos")),

    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_grasp_steel_b_pos")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "min_percentage_hits_grasp_steel_b_pos")),
    soft_score            = slider_float:new(0.50, 15.0, 6.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_grasp_steel_b_soft_core_pos")),

    spell_range           = slider_float:new(1.0, 15.0, 8.0, get_hash(my_utility.plugin_label .. "poison_trap_spell_range")),
    spell_radius          = slider_float:new(0.50, 5.0, 3.25, get_hash(my_utility.plugin_label .. "poison_trap_spell_radius")),
}

local function menu()

    if menu_elements_steel_grasp.tree_tab:push("Steel Grasp") then
        menu_elements_steel_grasp.main_boolean:render("Enable Spell", "");

        local options =  {"Auto", "Keybind"};
        menu_elements_steel_grasp.trap_mode:render("Mode", options, "");

        menu_elements_steel_grasp.keybind:render("Keybind", "");
        menu_elements_steel_grasp.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

        menu_elements_steel_grasp.min_hits:render("Min Hits", "");

        menu_elements_steel_grasp.allow_percentage_hits:render("Allow Percentage Hits", "");
        if menu_elements_steel_grasp.allow_percentage_hits:get() then
            menu_elements_steel_grasp.min_percentage_hits:render("Min Percentage Hits", "", 2);
            menu_elements_steel_grasp.soft_score:render("Soft Score", "", 2);
        end

        menu_elements_steel_grasp.spell_range:render("Spell Range", "", 2)
        menu_elements_steel_grasp.spell_radius:render("Spell Radius", "", 2)

        menu_elements_steel_grasp.tree_tab:pop();
    end
end

local spell_id_steel_grasp = 964631;

local steel_grasp_spell_data = spell_data:new(
    5.0,                        -- radius
    5.0,                       -- range
    0.5,                        -- cast_delay
    1.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_steel_grasp,              -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)

local my_target_selector = require("my_utility/my_target_selector");
local next_time_allowed_cast = 0.0;
local function logics(entity_list, target_selector_data, best_targetrget)
    local menu_boolean = menu_elements_steel_grasp.main_boolean:get();
   local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_steel_grasp);

    if not is_logic_allowed then
        return false;
    end;

    local player_position = get_player_position()
    local keybind_used = menu_elements_steel_grasp.keybind:get_state();
    local trap_mode = menu_elements_steel_grasp.trap_mode:get();
    if trap_mode == 1 then
        if  keybind_used == 0 then
            return false;
        end;
    end;

    local keybind_ignore_hits = menu_elements_steel_grasp.keybind_ignore_hits:get();
    local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("keybind_used " .. keybind_used)

    local is_percentage_hits_allowed = menu_elements_steel_grasp.allow_percentage_hits:get();
    local min_percentage = menu_elements_steel_grasp.min_percentage_hits:get();
    if not is_percentage_hits_allowed then
        min_percentage = 0.0;
    end

    local spell_range =  menu_elements_steel_grasp.spell_range:get()
    local spell_radius =  menu_elements_steel_grasp.spell_radius:get()
    local min_hits_menu = menu_elements_steel_grasp.min_hits:get();

    local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)
    if not area_data.main_target then
        return false;
    end

    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage);

    -- console.print("1111")
    if not is_area_valid and not keybind_can_skip  then
        return false;
    end

    if not area_data.main_target:is_enemy() then
        return false;
    end

    local constains_relevant = false;
    for _, victim in ipairs(area_data.victim_list) do
        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            constains_relevant = true;
            break;
        end
    end

    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("area_data.score " .. tostring(area_data.score))
    -- console.print("constains_relevant " .. tostring(constains_relevant))
    if not constains_relevant and area_data.score < menu_elements_steel_grasp.soft_score:get() and not keybind_can_skip then
        return false;
    end

    local main_target_position = area_data.main_target:get_position()
    local best_cast_data = my_utility.get_best_point(main_target_position, spell_radius, area_data.victim_list);

    -- Initialize variables to store the closest target to the point
    local closer_target_to_zone = nil
    local closest_distance_sqr = math.huge

    -- Loop through the list of victims to find the closest one to the point
    for _, victim in ipairs(best_cast_data.victim_list) do
        local victim_position = victim:get_position()
        local distance_sqr = main_target_position:squared_dist_to_ignore_z(victim_position)

        -- If the distance to the current victim is less than the closest distance so far, update the closest target
        if distance_sqr < closest_distance_sqr then
            closer_target_to_zone = victim
            closest_distance_sqr = distance_sqr
        end
    end

    local player_position = get_player_position()
    local is_wall_collision = target_selector.is_wall_collision(player_position, closer_target_to_zone, 1.20);
    if is_wall_collision then
        return false;
    end

    -- Cast the spell targeting the best_target with steel_grasp_spell_data if there's a closer target
    if closer_target_to_zone and cast_spell.target(closer_target_to_zone, steel_grasp_spell_data, false) then
        -- Update the next allowed cast time
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 6.0;

        -- Print a message indicating the spell was cast
        console.print("Casted Steel Grasp");
        return true; -- Return true to indicate successful spell casting
    end

    return false;
end


return
{
    menu = menu,
    logics = logics,
}
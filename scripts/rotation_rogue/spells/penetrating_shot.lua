local my_utility = require("my_utility/my_utility")

local menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "pen_shot_base_main_bool")),

    trap_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "pen_shot_base_mode")),
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "pen_shot_base_keybind_pos")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "pen_shot_base_keybind_ignore_min_hitstrap_base_pos")),

    min_hits              = slider_int:new(1, 20, 4, get_hash(my_utility.plugin_label .. "pen_shot_base_min_hits_to_casttrap_base_pos")),
    
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_pen_shot_base_pos")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "min_percentage_hits_pen_shot_base_pos")),
    soft_score            = slider_float:new(2.0, 15.0, 6.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_pen_shot_base_soft_core_pos")),

    spell_range   = slider_float:new(1.0, 15.0, 10.0, get_hash(my_utility.plugin_label .. "pen_shot_base_spell_range")),
    spell_radius   = slider_float:new(0.50, 5.0, 1.50, get_hash(my_utility.plugin_label .. "pen_shot_base_spell_radius")),
}

local function menu()
    
    if menu_elements.tree_tab:push("Penetrating Shot") then
        menu_elements.main_boolean:render("Enable Spell", "");

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

local spell_id_penetration_shot = 377137;
local my_target_selector = require("my_utility/my_target_selector");
local spell_data_penetration_shot = spell_data:new(
    1.50,                        -- radius
    20.0,                        -- range
    1.0,                        -- cast_delay
    5.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_penetration_shot,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(entity_list, target_selector_data, best_target)
    
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_penetration_shot);

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

    local area_data = my_target_selector.get_most_hits_rectangle(player_position, spell_range, spell_radius)

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

    local constains_relevant = false;
    for _, victim in ipairs(area_data.victim_list) do
        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            constains_relevant = true;
            break;
        end
    end

    if not constains_relevant and area_data.score < menu_elements.soft_score:get() and not keybind_can_skip  then
        return false;
    end    

    local cast_position = area_data.main_target:get_position();
    local player_position = get_player_position()
    local is_wall_collision = prediction.is_wall_collision(player_position, cast_position, 0.15);
    if is_wall_collision then
        return false
    end

    if cast_spell.position(spell_id_penetration_shot, cast_position, 0.4)then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.4;
            
        console.print("Rouge Plugin, Casted pen shot");
        return true;
    end
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
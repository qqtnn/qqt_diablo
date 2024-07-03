local my_utility = require("my_utility/my_utility")

local menu_elements = {
    golem_control_submenu      = tree_node:new(1),
    golem_control_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "golem_control_boolean_base")),
    golem_control_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "golem_control_cast_modes_base")),

    golem_control_selected_spell         = combo_box:new(0, get_hash(my_utility.plugin_label .. "golem_control_selected_spell_base")),
    
    iron_min_hits    = slider_int:new(1, 20, 4, get_hash(my_utility.plugin_label .. "golem_control_iron_min_hits_base")),
    blood_min_hits    = slider_int:new(1, 20, 5, get_hash(my_utility.plugin_label .. "golem_control_blood_min_hits_base")),
    bone_min_hits    = slider_int:new(1, 20, 5, get_hash(my_utility.plugin_label .. "golem_control_bone_min_hits_base")),
    allow_elite_single_target       = checkbox:new(true, get_hash(my_utility.plugin_label .. "golem_control_allow_elite_single_target_base")),
}

local function menu()
    if menu_elements.golem_control_submenu:push("Golem Control") then
        menu_elements.golem_control_boolean:render("Enable Explosion Cast", "")

        if menu_elements.golem_control_boolean:get() then
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only"}
            menu_elements.golem_control_mode:render("Cast Modes", dropbox_options, "")
            
            menu_elements.allow_elite_single_target:render("Allow Single Target Elites", "")
            local spells_options = {"Iron Active", "Blood Active", "Bone Active"}
            menu_elements.golem_control_selected_spell:render("Spell", spells_options, "")
            if menu_elements.golem_control_selected_spell:get() == 0 then
                menu_elements.iron_min_hits:render("Iron Min Hits", "")
                
            end
            if menu_elements.golem_control_selected_spell:get() == 1 then
                menu_elements.blood_min_hits:render("Blood Min Hits", "")
                
            end
            if menu_elements.golem_control_selected_spell:get() == 2 then
                menu_elements.bone_min_hits:render("Bone Min Hits", "")
                
            end
            
        end

        menu_elements.golem_control_submenu:pop()
    end
end

local golem_control_id = 440463
-- to get the spell id, go to debug -> draw spell ids

local golem_control_spell_data = spell_data:new(
    1.0,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    10.0,                       -- projectile_speed
    true,                       -- has_collision
    golem_control_id,        -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.targeted     --targeting_type
)

--Necromancer_Golem_Bone
--Necromancer_Golem_Blood
--Necromancer_Golem_Iron
local golem_bone_name = "Necromancer_Golem_Bone"
local golem_blood_name = "Necromancer_Golem_Blood"
local golem_iron_name = "Necromancer_Golem_Iron"

local function get_current_golem_game_object()

    local actors = actors_manager.get_ally_actors();
    for _, object in ipairs(actors) do
        local skin_name = object:get_skin_name();
        local is_golem = skin_name == golem_bone_name 
        or skin_name == golem_blood_name 
        or skin_name == golem_iron_name
        if is_golem then
            return object
        end
    end

    return nil
end

local last_golem_control = 0.0;
local function logics()
    
    local menu_boolean = menu_elements.golem_control_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_golem_control, 
                golem_control_id);

    if not is_logic_allowed then
        return false;
    end;

    if not utility.can_cast_spell(golem_control_id) then
        return false;
    end
   
    local golem = get_current_golem_game_object()
    if not golem then
        return false
    end
  
    local is_spell_selected_iron_active =  menu_elements.golem_control_selected_spell:get() == 0
    local is_spell_selected_blood_active =  menu_elements.golem_control_selected_spell:get() == 1
    local is_spell_selected_bone_active =  menu_elements.golem_control_selected_spell:get() == 2
    local min_hits = menu_elements.iron_min_hits:get()
    local is_single_allowed = menu_elements.allow_elite_single_target:get()
    if is_spell_selected_iron_active then
        min_hits = menu_elements.iron_min_hits:get()
    end

    if is_spell_selected_blood_active then
        min_hits = menu_elements.blood_min_hits:get()
    end

    if is_spell_selected_bone_active then
        min_hits = menu_elements.bone_min_hits:get()
    end

    local circle_radius = 3.50 -- radius of iron area stun -- invented number idk i dont rly play the game
    if not is_spell_selected_iron_active then
        circle_radius = 5.0
    end
    local player_position = get_player_position();
    local logic_position = player_position
    local max_search_range = 10
    if not is_spell_selected_iron_active then
        logic_position = golem:get_position()
        max_search_range = circle_radius
    end
    local area_data = target_selector.get_most_hits_target_circular_area_heavy(logic_position, max_search_range, circle_radius)
    local best_target = area_data.main_target;
    
    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point(best_target_position, circle_radius, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list

    local is_single_target_allowed = false;
    if is_single_allowed then
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
    if best_cast_hits < min_hits and not is_single_target_allowed then
        -- add your logs here if needed
        return false
    end
   
    -- if true then return false end
    local best_cast_position = best_cast_data.point;
    if cast_spell.position(golem_control_id, best_cast_position, 0.66) then
        local current_time = get_time_since_inject();
        last_golem_control = current_time + 2.0;

        if is_spell_selected_iron_active then
            console.print("[Necromancer] [SpellCast] [Golem Control] (IRON ACTIVE)");
        else
            if is_spell_selected_blood_active then
                console.print("[Necromancer] [SpellCast] [Golem Control] (BLOOD ACTIVE)");
            else
                console.print("[Necromancer] [SpellCast] [Golem Control] (BONE ACTIVE)");
            end
           
        end
        return true;
    end

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
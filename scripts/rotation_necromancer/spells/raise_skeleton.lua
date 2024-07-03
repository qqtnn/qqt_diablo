local my_utility = require("my_utility/my_utility")

local menu_elements = {
    raise_skeleton_submenu      = tree_node:new(1),
    raise_skeleton_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "raise_skeleton_boolean_base")),
    raise_skeleton_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "raise_skeleton_cast_modes_base")),
    spell_max_range    = slider_int:new(5, 20, 12, get_hash(my_utility.plugin_label .. "raise_skeleton_spell_max_range_base")),
    raise_skeleton_melee        = checkbox:new(true, get_hash(my_utility.plugin_label .. "raise_skeleton_melee_base")),
    raise_skeleton_melee_max    = slider_int:new(0, 10, 2, get_hash(my_utility.plugin_label .. "raise_skeleton_melee_max_base")),
    raise_skeleton_ranged       = checkbox:new(true, get_hash(my_utility.plugin_label .. "raise_skeleton_melee_base")),
    raise_skeleton_ranged_max   = slider_int:new(0, 10, 2, get_hash(my_utility.plugin_label .. "raise_skeleton_ranged_max_base")),

    priest_threshold    = slider_int:new(0, 10, 2, get_hash(my_utility.plugin_label .. "raise_skeleton_priest_threshold_base")),
    priest_delay    = slider_int:new(0, 8, 4, get_hash(my_utility.plugin_label .. "raise_skeleton_priest_delay_base")),
}

local function menu()
    if menu_elements.raise_skeleton_submenu:push("Raise Skeleton") then
        menu_elements.raise_skeleton_boolean:render("Enable Explosion Cast", "")

        if menu_elements.raise_skeleton_boolean:get() then
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only"}
            menu_elements.raise_skeleton_mode:render("Cast Modes", dropbox_options, "")
            menu_elements.spell_max_range:render("Spell Max Range", "")
            
            menu_elements.raise_skeleton_melee:render("Skeletons: Melee", "")
            if menu_elements.raise_skeleton_melee:get() then
                menu_elements.raise_skeleton_melee_max:render("Max Melee Skeletons", "")
            end

            menu_elements.raise_skeleton_ranged:render("Skeletons: Ranged", "")
            if menu_elements.raise_skeleton_ranged:get() then
                menu_elements.raise_skeleton_ranged_max:render("Max Ranged Skeletons", "")
            end

            if menu_elements.raise_skeleton_melee:get() or menu_elements.raise_skeleton_ranged:get() then
                menu_elements.priest_threshold:render("Priest Threshold", "")
                menu_elements.priest_delay:render("Priest Delay", "Extra delay to avoid spam priest")
            end
            
        end

        menu_elements.raise_skeleton_submenu:pop()
    end
end

local raise_skeleton_id = 1059157
-- to get the spell id, go to debug -> draw spell ids

local raise_skeleton_spell_data = spell_data:new(
    1.0,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    10.0,                       -- projectile_speed
    true,                       -- has_collision
    raise_skeleton_id,        -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.targeted     --targeting_type
)

--Necromancer_Golem_Bone
--Necromancer_Golem_Blood
--Necromancer_Golem_Iron
local golem_bone_name = "Necromancer_Golem_Bone"
local golem_blood_name = "Necromancer_Golem_Blood"
local golem_iron_name = "Necromancer_Golem_Iron"

--Necromancer_SkeletonWarrior_Sword
--Necromancer_SkeletonWarrior_Shield
--Necromancer_SkeletonWarrior_Scythe
local skeleton_melee_sword_name = "Necromancer_SkeletonWarrior_Sword"
local skeleton_melee_shield_name = "Necromancer_SkeletonWarrior_Shield"
local skeleton_melee_scythe_name = "Necromancer_SkeletonWarrior_Scythe"

--necro_skeletonMage_shadow
--necro_skeletonMage_cold
--necro_skeletonMage_sacrifice
local skeleton_ranged_shadow_name = "necro_skeletonMage_shadow"
local skeleton_ranged_cold_name = "necro_skeletonMage_cold"
local skeleton_ranged_sacrifice_name = "necro_skeletonMage_sacrifice"

local function get_max_melee_skeletons()
    if not menu_elements.raise_skeleton_melee:get() then
        return 0
    end

    return menu_elements.raise_skeleton_melee_max:get()
end

local function get_max_ranged_skeletons()
    if not menu_elements.raise_skeleton_ranged:get() then
        return 0
    end

    return menu_elements.raise_skeleton_ranged_max:get()
end

local function get_current_skeletons_melee_list()

    local list = {};
    local actors = actors_manager.get_ally_actors();
    for _, object in ipairs(actors) do
        local skin_name = object:get_skin_name();
        local is_melee = skin_name == skeleton_melee_sword_name 
        or skin_name == skeleton_melee_shield_name 
        or skin_name == skeleton_melee_scythe_name
        if is_melee then
            table.insert(list, object);
        end
    end

    return list
end

local function get_current_skeletons_ranged_list()
    local list = {};
    local actors = actors_manager.get_ally_actors();
    for _, object in ipairs(actors) do
        local skin_name = object:get_skin_name();
        local is_ranged = skin_name == skeleton_ranged_shadow_name 
        or skin_name == skeleton_ranged_cold_name 
        or skin_name == skeleton_ranged_sacrifice_name
        if is_ranged then
            table.insert(list, object);
        end
    end

    return list
end

local function get_corpses_to_rise_list()

    local player_position = get_player_position();
    local actors = actors_manager.get_ally_actors();

    local corpse_list = {};
    for _, object in ipairs(actors) do
        local skin_name = object:get_skin_name();
        local is_corpse = skin_name == "Necro_Corpse";
        
        if is_corpse then
            table.insert(corpse_list, object);
        end
    end

    -- Sort the list by the number of hits
    table.sort(corpse_list, function(a, b)
        return a:get_position():squared_dist_to(player_position) < b:get_position():squared_dist_to(player_position)
    end);

    -- Return the corpse that is closer to local_player
    return corpse_list
end

local last_raise_skeleton = 0.0;
local function logics()
    
    local menu_boolean = menu_elements.raise_skeleton_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_raise_skeleton, 
                raise_skeleton_id);

    if not is_logic_allowed then
        return false;
    end;

    
    if not utility.can_cast_spell(raise_skeleton_id) then
        return false;
    end
   
    local corpses_to_rise = get_corpses_to_rise_list();
    if #corpses_to_rise <= 0 then
        return false
    end
  
    local corpse_to_rise = corpses_to_rise[1]
    local corpse_position = corpse_to_rise:get_position()
    local distance = corpse_position:dist_to(get_player_position())
    if distance > menu_elements.spell_max_range:get() then
        return false
    end
 
    local is_ranged_maxed_out = false
    local max_melee_skeletons = get_max_melee_skeletons()
    local current_melee_skeletons_list = get_current_skeletons_melee_list()
    local melee_maxed_out = #current_melee_skeletons_list >= max_melee_skeletons
    if melee_maxed_out then
        local max_ranged_skeletons = get_max_ranged_skeletons()
        local current_ranged_skeletons_list = get_current_skeletons_ranged_list()
        is_ranged_maxed_out = #current_ranged_skeletons_list  >= max_ranged_skeletons
        if is_ranged_maxed_out then

            local melee_low_count = 0
            -- priest check
            for index, value in ipairs(current_melee_skeletons_list) do
                local current_health = value:get_current_health()
                local max_health = value:get_max_health()
                local current_health_percentage = current_health  / max_health
                if current_health_percentage <= 0.60 then
                    melee_low_count = melee_low_count + 1
                end
            end

            local ranged_low_count = 0
            for index, value in ipairs(current_ranged_skeletons_list) do
                local current_health = value:get_current_health()
                local max_health = value:get_max_health()
                local current_health_percentage = current_health  / max_health
                if current_health_percentage <= 0.60 then
                    ranged_low_count = ranged_low_count + 1
                end
            end

            local total_count = melee_low_count + ranged_low_count
            -- console.print("total_count " .. total_count)
            if total_count < menu_elements.priest_threshold:get() then
                return false
            end
        end
    end
    
    if cast_spell.target(corpses_to_rise[1], raise_skeleton_id, 0.60, false) then
        local current_time = get_time_since_inject();
        last_raise_skeleton = current_time + 0.70;

        if not melee_maxed_out then
            console.print("[Necromancer] [SpellCast] [Raise Skeleton] (MELEE) Hits ", 1);
           
        else
            if not is_ranged_maxed_out then
                console.print("[Necromancer] [SpellCast] [Raise Skeleton] (MAGE) Hits ", 1);
            else
                last_raise_skeleton = current_time + 0.70 + menu_elements.priest_delay:get();
                console.print("[Necromancer] [SpellCast] [Raise Skeleton] (PRIEST) Hits ", 1);
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
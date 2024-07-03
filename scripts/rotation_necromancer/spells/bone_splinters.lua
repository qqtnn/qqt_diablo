local my_utility = require("my_utility/my_utility")

local menu_elements_base_splint =
{
    tree_tab_splint            = tree_node:new(1),
    main_boolean_splint        = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_split_boolean_base")),
    use_as_filler_only_splint  = checkbox:new(true, get_hash(my_utility.plugin_label .. "use_when_no_bone_spear_only_base"))
}

local function menu()
    if menu_elements_base_splint.tree_tab_splint:push("Bone Splinters") then
        menu_elements_base_splint.main_boolean_splint:render("Enable Spell", "")
 
         if menu_elements_base_splint.main_boolean_splint:get() then
            menu_elements_base_splint.use_as_filler_only_splint:render("Filler Only", "Prevent casting with a lot of essence")
         end

         menu_elements_base_splint.tree_tab_splint:pop()
        end
    end

local spell_id_bone_spliters = 500962;
local next_time_allowed_cast = 0.0;
local bone_spliters_spell_data = spell_data:new(
    0.4,                            -- radius
    10.0,                           -- range
    0.5,                            -- cast_delay
    8.0,                            -- projectile_speed
    false,                           -- has_collision
    spell_id_bone_spliters,         -- spell_id
    spell_geometry.rectangular,     -- geometry_type
    targeting_type.skillshot        --targeting_type
)

local local_player = get_local_player();
if local_player == nil then
    return
end
local function logics(target)
    
    local menu_boolean = menu_elements_base_splint.main_boolean_splint:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_bone_spliters);

    if not is_logic_allowed then
        return false;
    end;
    
    local is_filler_enabled = menu_elements_base_splint.use_as_filler_only_splint:get();  
    if is_filler_enabled then
        local current_resource_ws = local_player:get_primary_resource_current();
        local max_resource_ws = local_player:get_primary_resource_max();
        local essence_perc = current_resource_ws / max_resource_ws 
        local low_in_essence = essence_perc < 0.3
    
        if not low_in_essence then
            return false;
        end
    end;
    
    local player_position = local_player:get_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_id_bone_spliters, 0.3, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;

        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
local my_utility = require("my_utility/my_utility");

local menu_elements_bone_prison_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_boner_prison")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_prison_base")),
}

local function menu()
    
    if menu_elements_bone_prison_base.tree_tab:push("Bone Prison") then
        menu_elements_bone_prison_base.main_boolean:render("Enable Spell", "")

        if menu_elements_bone_prison_base.main_boolean:get() then
            menu_elements_bone_prison_base.min_max_targets:render("Min Enemies Around", "Amount of targets to cast the spell")
        end
 
        menu_elements_bone_prison_base.tree_tab:pop()
    end
end

local bone_prison_spell_id = 493453;
local next_time_allowed_cast = 0.0;

local bone_prison_data = spell_data:new(
    2.0,                       -- radius
    7.0,                       -- range
    1.0,                       -- cast_delay
    1.0,                       -- projectile_speed
    true,                       -- has_collision
    bone_prison_spell_id,        -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.skillshot     --targeting_type
)
local function logics(target)

    local menu_boolean = menu_elements_bone_prison_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                bone_prison_spell_id);

    if not is_logic_allowed then
    return false;
    end;

    local player_pos = get_player_position()
    local area_data = target_selector.get_most_hits_target_circular_area_light(player_pos, 4.0, 4.0, false)
    local units = area_data.n_hits

    if units < menu_elements_bone_prison_base.min_max_targets:get() then
        return false;
    end;

    local target_position = target:get_position();

    cast_spell.target(target, bone_prison_data, false)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.7;
        
    console.print("Necro Plugin, Casted Blight");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
local my_utility = require("my_utility/my_utility");

local menu_elements_bone_spirit_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_bone_spirit_base")),
}

local function menu()
    
    if menu_elements_bone_spirit_base.tree_tab:push("Bone Spirit") then
        menu_elements_bone_spirit_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_bone_spirit_base.tree_tab:pop()
    end
end

local spell_id_bone_spirit= 469641
local next_time_allowed_cast = 0.0;
local bone_spirit_data = spell_data:new(
    1.0,                        -- radius
    12.0,                       -- range
    0.10,                       -- cast_delay
    1.0,                       -- projectile_speed
    true,                       -- has_collision
    spell_id_bone_spirit,        -- spell_id
    spell_geometry.rectangular,    -- geometry_type
    targeting_type.targeted     --targeting_type
)
local function logics(target)

    local menu_boolean = menu_elements_bone_spirit_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_bone_spirit);

    if not is_logic_allowed then
    return false;
    end;

    local target_position = target:get_position();

    cast_spell.target(target, bone_spirit_data, false)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.8;
        
    console.print("Necro Plugin, Bone Spirit");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
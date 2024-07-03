local my_utility = require("my_utility/my_utility");

local menu_elements_pulverize = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_arc_lash")),

}

local function menu()
    
    if menu_elements_pulverize.tree_tab:push("Pulverize") then
        menu_elements_pulverize.main_boolean:render("Enable Spell", "")

        menu_elements_pulverize.tree_tab:pop()
    end
end

local local_player = get_local_player();
if local_player == nil then
    return
end

local spell_id_pulverize = 272138
local pulverize_data = spell_data:new(
    2.0,                                -- radius
    0.5,                                -- range
    0.4,                                -- cast_delay
    0.2,                                -- projectile_speed
    false,                              -- has_collision
    spell_id_pulverize,                 -- spell_id
    spell_geometry.circular,            -- geometry_type
    targeting_type.targeted             --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_pulverize.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast,
                spell_id_pulverize);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.target(target, pulverize_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 1.3;

        return true;
    end;


    return false;
end

return
{
    menu = menu,
    logics = logics,
}


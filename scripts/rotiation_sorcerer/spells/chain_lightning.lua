local my_utility = require("my_utility/my_utility");

local menu_elements_sorc_base_lightning = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_chain_lightning")),
}

local function menu()
    
    if menu_elements_sorc_base_lightning.tree_tab:push("Chain Lightning") then
        menu_elements_sorc_base_lightning.main_boolean:render("Enable Spell", "")

        menu_elements_sorc_base_lightning.tree_tab:pop()
    end 
end

local spell_id_chain_lightning = 292757
local chain_lightning_spell_data = spell_data:new(
    0.5,                        -- radius
    11.0,                       -- range
    2.0,                        -- cast_delay
    4.0,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_chain_lightning,   -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)
local local_player = get_local_player();
if local_player == nil then
    return
end
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_sorc_base_lightning.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast,
                spell_id_chain_lightning);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.target(target, spell_id_chain_lightning, 0.4, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.8;

        return true;
    end;

    return false;
end

return
{
    menu = menu,
    logics = logics,
}
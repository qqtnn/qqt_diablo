local my_utility = require("my_utility/my_utility")

local menu_elements_teleport_ench =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "base_teleport_ench_base_main_bool")),
    enchant_jmr_logic        = checkbox:new(true, get_hash(my_utility.plugin_label .. "base_teleport_ench_enchant_jmr_logic_bool")),
}

local function menu()
    
    if menu_elements_teleport_ench.tree_tab:push("teleport_ench")then
        menu_elements_teleport_ench.main_boolean:render("Enable Spell", "")
        menu_elements_teleport_ench.enchant_jmr_logic:render("Enable JMR Logic", "")
 
        menu_elements_teleport_ench.tree_tab:pop()
    end
end

local spell_id_teleport_ench= 959728;

local spell_data_teleport_ench = spell_data:new(
    5.0,                        -- radius
    8.0,                        -- range
    1.0,                        -- cast_delay
    0.7,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_teleport_ench,              -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.skillshot   --targeting_type
)
local next_time_allowed_cast = 0.0;
local_player = get_local_player();
local function logics(target)
    local_player = get_local_player();
    local menu_boolean = menu_elements_teleport_ench.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_teleport_ench);

    local current_orb_mode = orbwalker.get_orb_mode()

    if not menu_boolean then
        return false
    end

    if current_orb_mode == orb_mode.none then
        return false
    end

    if not local_player:is_spell_ready(959728) then
        return false
    end

    -- if not is_logic_allowed then
    --     console.print("is_logic_allowed false")
    --     return false;
    -- end;

    if cast_spell.target(target, spell_data_teleport_ench, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;

        console.print("Casted Teleport Enchantment");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
    menu_elements_teleport_ench = menu_elements_teleport_ench,
}
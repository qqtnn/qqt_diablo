local my_utility = require("my_utility/my_utility")

local frozen_orb_menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "frozen_orb_main_boolean")),
    elite_filter        = checkbox:new(false, get_hash(my_utility.plugin_label .. "frozen_orb_elite_filter")),
}

local function menu()
    
    if frozen_orb_menu_elements.tree_tab:push("Frozen Orb")then
        frozen_orb_menu_elements.main_boolean:render("Enable Spell", "")
        frozen_orb_menu_elements.elite_filter:render("Elite Filter", "")
 
        frozen_orb_menu_elements.tree_tab:pop()
    end
end

local spell_id_fozen_orb = 291347;

local frozen_orb_data = spell_data:new(
    1.5,                        -- radius
    2.0,                        -- range
    1.0,                        -- cast_delay
    2.5,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_fozen_orb,             -- spell_id
    spell_geometry.circular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)

local next_time_allowed_cast = 0.0;

---@param target game.object
local function logics(target)
    
    local menu_boolean = frozen_orb_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_fozen_orb);

    if not is_logic_allowed then
        return false;
    end;

    if frozen_orb_menu_elements.elite_filter:get() then
        -- local player_local = get_local_player();
        if not target:is_boss() and not target:is_elite() and not target:is_champion() then
            return false;
        end
    end
    
    local player_position = get_player_position();
    local target_position = target:get_position();
    local is_collision = prediction.is_wall_collision(player_position, target_position, 1.0)
    if is_collision then
        return false
    end

    if cast_spell.position(spell_id_fozen_orb, target_position:get_extended(player_position, -0.5), 0.4) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.4;

        console.print("Sorc Plugin, Casted Frozen Orb");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
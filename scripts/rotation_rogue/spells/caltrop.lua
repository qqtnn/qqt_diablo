local my_utility = require("my_utility/my_utility")

local menu_elements_caltrop =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "caltrop_base_main_bool")),
    spell_range   = slider_float:new(1.0, 15.0, 2.60, get_hash(my_utility.plugin_label .. "caltrop_spell_range_2")),

}

local function menu()
    
    if menu_elements_caltrop.tree_tab:push("Caltrop")then
        menu_elements_caltrop.main_boolean:render("Enable Spell", "")
        menu_elements_caltrop.spell_range:render("Spell Range", "", 1)
 
        menu_elements_caltrop.tree_tab:pop()
    end
end

local spell_id_caltrop = 389667;

local pois_trap = require("spells/poison_trap")

local caltrop_spell_data = spell_data:new(
    3.0,                        -- radius
    1.0,                       -- range
    0.5,                        -- cast_delay
    1.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_caltrop,              -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)

local debug_console = false
local next_time_allowed_cast = 0.0;
local function logics(entity_list, target_selector_data, target)
    
    local menu_boolean = menu_elements_caltrop.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_caltrop);

    if not is_logic_allowed then
        return false;
    end;

    local poison_trap_id = 416528;
    if utility.is_spell_ready(poison_trap_id) then
        -- local pos = pois_trap.is_valid_logics(entity_list, target_selector_data, target)
        -- if pos then
        --     return false
        -- end
        if debug_console then
            console.print("caltrop leaving 1111")
        end
        return false
    end

    if target:is_vulnerable() then
        return false
    end

    local max_health = target:get_max_health()
    local current_health = target:get_current_health()
    local health_percentage = current_health / max_health
    local is_fresh = health_percentage >= 1.0
    if is_fresh then
        return false
    end

    local spell_range = menu_elements_caltrop.spell_range:get()
    local target_position = target:get_position()
    local player_position = get_player_position()
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) then

        if debug_console then
            console.print("caltrop leaving 2222")
        end
        return false
    end

    if cast_spell.target(target, caltrop_spell_data, true) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 6.0;

        console.print("Casted Caltrop");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
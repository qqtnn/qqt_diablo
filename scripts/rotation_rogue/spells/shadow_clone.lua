local my_utility = require("my_utility/my_utility")

local menu_elements_shadow_clone_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "shadow_clone_main_bool_base")),
    spell_range   = slider_float:new(1.0, 15.0, 2.60, get_hash(my_utility.plugin_label .. "shadow_clone_spell_range")),
}

local function menu()
    
    if menu_elements_shadow_clone_base.tree_tab:push("Shadow Clone")then
        menu_elements_shadow_clone_base.main_boolean:render("Enable Spell", "")
        menu_elements_shadow_clone_base.spell_range:render("Spell Range", "", 1)
 
        menu_elements_shadow_clone_base.tree_tab:pop()
    end
end

local spell_id_shadow_clone = 357628;


local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_shadow_clone_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shadow_clone);

    if not is_logic_allowed then
        return false;
    end;


    local is_exception = target:get_current_health() < target:get_max_health() and target:is_boss()
    local spell_range = menu_elements_shadow_clone_base.spell_range:get()
    local target_position = target:get_position()
    local player_position = get_player_position()
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) and not is_exception  then
        return false
    end

    if cast_spell.position(spell_id_shadow_clone, target_position, 0.6) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.6;

        console.print("Rouge, Casted Rain Of Arrows");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
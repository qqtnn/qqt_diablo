local my_utility = require("my_utility/my_utility")

local menu_elements_deep_freeze = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_deep_freeze")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast"))
}

local function menu()
    
    if menu_elements_deep_freeze.tree_tab:push("Deep Freeze") then
        menu_elements_deep_freeze.main_boolean:render("Enable Spell", "")

        if menu_elements_deep_freeze.main_boolean:get() then
            menu_elements_deep_freeze.min_max_targets:render("Min Enemies Around", "Amount of targets to cast the spell")
        end

        menu_elements_deep_freeze.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;
local spell_id_deep_freeze = 291827;
local function logics()

    local menu_boolean = menu_elements_deep_freeze.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_deep_freeze);

    if not is_logic_allowed then
    return false;
    end;

    local area_data = target_selector.get_most_hits_target_circular_area_light(get_player_position(), 5.5, 5.5, false)
    local units = area_data.n_hits

    if units < menu_elements_deep_freeze.min_max_targets:get() then
        return false;
    end;

    if cast_spell.self(spell_id_deep_freeze, 0.0) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 4;
        return true;
    end;


    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
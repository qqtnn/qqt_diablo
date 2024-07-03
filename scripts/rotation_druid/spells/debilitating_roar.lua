local my_utility = require("my_utility/my_utility")

local roar_menu_elements =
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_ability")),
    -- min_max_targets    = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast"))
}

local function menu()

    if roar_menu_elements.main_tab:push("Delibitating Roar") then
        roar_menu_elements.main_boolean:render("Enable Spell", "")
 
        --  if roar_menu_elements.main_boolean:get() then
        --     roar_menu_elements.min_max_targets:render("Min hits", "Amount of targets to cast the spell")
        --  end

         roar_menu_elements.main_tab:pop()
    end
end

local local_player = get_local_player();
if local_player == nil then
    return
end
local next_time_allowed_cast = 0.0;
local spell_id_debilitating_roar = 336238;
local function logics()
    
    local menu_boolean = roar_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_debilitating_roar);

    if not is_logic_allowed then
        return false;
    end;

    -- local area_data = target_selector.get_most_hits_target_circular_area_light(get_player_position(), 4, 4, false)
    -- local units = area_data.n_hits

    -- if units < roar_menu_elements.min_max_targets:get() then
    --     return false;
    -- end;

    if cast_spell.self(spell_id_debilitating_roar, 0.0) then
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.2;
    console.print("Druid Plugin, Casted Debilitating Roar");
        return true;
    end;
        
    return false;
end

return
{
    menu = menu,
    logics = logics,
}


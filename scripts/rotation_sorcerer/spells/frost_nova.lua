local my_utility = require("my_utility/my_utility")

local menu_elements_sorc_base_frost =
{
    tree_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_ability")),
    min_max_targets    = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast"))
}

local function menu()

    if menu_elements_sorc_base_frost.tree_tab:push("Frost Nova") then
        menu_elements_sorc_base_frost.main_boolean:render("Enable Spell", "")

        if menu_elements_sorc_base_frost.main_boolean:get() then
            menu_elements_sorc_base_frost.min_max_targets:render("Min hits", "Amount of targets to cast the spell")
        end

        menu_elements_sorc_base_frost.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;
local spell_id_frost_nova = 291215;
local function logics()



    local menu_boolean = menu_elements_sorc_base_frost.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_frost_nova);

    if not is_logic_allowed then
        return false;
    end;

    local time = get_time_since_inject()
    if  time - next_time_allowed_cast < 0.2 then
        return false
    end

    local area_data = target_selector.get_most_hits_target_circular_area_heavy(get_player_position(), 3.66, 3.66)
    local amount_hits = area_data.n_hits

    if amount_hits < menu_elements_sorc_base_frost.min_max_targets:get() then
        local is_boss = false
        for index, value in ipairs(area_data.victim_list) do
            if value:is_boss() then
                is_boss = true
                break
            end
        end

        if not is_boss then
            return false;
        end

    end;

    if cast_spell.self(spell_id_frost_nova, 0.15) then
        next_time_allowed_cast = time
        return true;
    end;

    return false;
end

return
{
    menu = menu,
    logics = logics,
}
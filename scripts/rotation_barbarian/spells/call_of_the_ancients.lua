local my_utility = require("my_utility/my_utility")

local menu_elements_call_of_the_anc= 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_call_anc_base")),
    filter_mode           = combo_box:new(0, get_hash(my_utility.plugin_label .. "call_anc_base_filter_mode")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_anc_base"))
}

local function menu()
    
    if menu_elements_call_of_the_anc.tree_tab:push("Call Of The Ancient") then
        menu_elements_call_of_the_anc.main_boolean:render("Enable Spell", "")

        if menu_elements_call_of_the_anc.main_boolean:get() then
            local dropbox_options = {"No filter", "Elite & Boss Only", "Boss Only"}
            menu_elements_call_of_the_anc.filter_mode:render("Filter Modes", dropbox_options, "")
            menu_elements_call_of_the_anc.min_max_targets:render("Min Enemies Around", "Amount of targets to cast the spell")
        end

        menu_elements_call_of_the_anc.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;
local spell_id_ancient = 309802;
local function logics()

    local menu_boolean = menu_elements_call_of_the_anc.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_ancient);

    if not is_logic_allowed then
    return false;
    end;
    
    local player_pos = get_player_position()
    local area_data = target_selector.get_most_hits_target_circular_area_light(player_pos, 3.0, 3.0, false)
    local units = area_data.n_hits
    local elite_units, champion_units, boss_units = my_utility.should_pop_cds()
    local filter_mode = menu_elements_call_of_the_anc.filter_mode:get()

    local elite_collision = target_selector.is_wall_collision(player_pos, elite_pos, 1.50)
    local champion_collision = target_selector.is_wall_collision(player_pos, champion_pos, 1.50)
    local boss_collision = target_selector.is_wall_collision(player_pos, boss_pos, 1.50)


    if  ((filter_mode == 1 and elite_units >= 1 and not elite_collision)
        or (champion_units >= 1 and not champion_collision)
        or (boss_units >= 1 and not boss_collision))

        or (filter_mode == 2 and boss_units >= 1 and not boss_collision)
        or (units >= menu_elements_call_of_the_anc.min_max_targets:get())
        then
            if cast_spell.self(spell_id_ancient, 0.0) then
            -- ignore global cooldown -- test 04/06/2024 -- qqt
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.4;
            console.print("Casted Call of the ancients")
            return true;
        end
    end


    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
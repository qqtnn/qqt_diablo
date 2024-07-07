local my_utility = require("my_utility/my_utility")
local bash = require("spells/bash")

local menu_elements_hammer_anc_base =
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_hammer_base")),
    only_bash_buffed      = checkbox:new(true, get_hash(my_utility.plugin_label .. "only_bash_buffed_hammer_base")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_hammer_base"))
}

local function menu()

    if menu_elements_hammer_anc_base.tree_tab:push("Hammer Of The Ancients") then
        menu_elements_hammer_anc_base.main_boolean:render("Enable Spell", "")
        menu_elements_hammer_anc_base.only_bash_buffed:render("Only Bash Buff", "Only use HotA for buffing Bash")

        if menu_elements_hammer_anc_base.main_boolean:get() then
            menu_elements_hammer_anc_base.min_max_targets:render("Min Enemies Hit", "Amount of targets to cast the spell")
        end

        menu_elements_hammer_anc_base.tree_tab:pop()
    end
end

local counter = bash.bash_counter
local bash_counter_func = bash.get_bash_counter

local next_time_allowed_cast = 0.0;
local spell_id_hammer_of_anc = 213673
local spell_data_hammer = spell_data:new(
    1.0,                        -- radius
    1.5,                        -- range
    0.8,                        -- cast_delay
    0.4,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_hammer_of_anc,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type

)

local function logics(target)

    local menu_boolean = menu_elements_hammer_anc_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_hammer_of_anc);
    local elite_units, champion_units, boss_units = my_utility.should_pop_cds()

    if not is_logic_allowed then
        return false;
    end;

    -- local player_pos = get_player_position()
    local target_pos = target:get_position();
    local area_data = target_selector.get_most_hits_target_circular_area_light(target_pos, 3.0, 3.0, false)
    local units = area_data.n_hits

    local player_local = get_local_player();
    local current_resource_ws = player_local:get_primary_resource_current();
    if units < menu_elements_hammer_anc_base.min_max_targets:get() and current_resource_ws < 95.0 then
        return false;
    end;


    local target_position = target:get_position()
    local distance_sqr = get_player_position():squared_dist_to_ignore_z(target_position)
    if distance_sqr > (3.0 * 3.0) then
        return false
    end
    --console.print_full(1.0,1.0,"Bash casts: " .. bash_counter_func() .. "currently and slider set to " .. menu_elements_hammer_anc_base.bash_buff_number:get())

    local bash_passive_count = my_utility.count_and_display_buffs()
    if (menu_elements_hammer_anc_base.only_bash_buffed:get() and bash_passive_count >= 2)
        or (menu_elements_hammer_anc_base.only_bash_buffed:get() ==false) then
        if cast_spell.target(target, spell_data_hammer, false) then
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.2;
            console.print("Casted hammer of ancients");
            bash.reset_bash_counter()
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
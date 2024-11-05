
local my_utility = require("my_utility/my_utility")

local dance_of_knives_menu_elements_base =
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_dance")),
    distance   = slider_float:new(1.0, 20.0, 7.50, get_hash(my_utility.plugin_label .. "dance_knives_distance")),
    animation_delay   = slider_float:new(0.0, 5.0, 0.00, get_hash(my_utility.plugin_label .. "dance_knives_animation_delay")),
    interval   = slider_float:new(0.0, 5.0, 0.40, get_hash(my_utility.plugin_label .. "dance_knives_interval")),
}

local function menu()
    if dance_of_knives_menu_elements_base.main_tab:push("Dance of Knives") then
        dance_of_knives_menu_elements_base.main_boolean:render("Enable Spell", "")

        if dance_of_knives_menu_elements_base.main_boolean:get() then


            dance_of_knives_menu_elements_base.distance:render("Distance", "", 2)
            dance_of_knives_menu_elements_base.animation_delay:render("Animation Delay", "", 2)
            dance_of_knives_menu_elements_base.interval:render("Interval", "", 2)
        end

        dance_of_knives_menu_elements_base.main_tab:pop()
    end
end

local spell_id_dance_of_knives = 1690398
local next_time_allowed_cast = 0.0

local function logics(target)

    local menu_boolean = dance_of_knives_menu_elements_base.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean,
        next_time_allowed_cast,
        spell_id_dance_of_knives)

    if not is_logic_allowed then
        return false
    end

    local enemies = actors_manager.get_enemy_npcs();
    local distance = dance_of_knives_menu_elements_base.distance:get()

    local player_position = get_player_position()
    local is_wall_collision = target_selector.is_wall_collision(player_position, target, 1.20);
    if is_wall_collision then
        return false;
    end

    for i, enemy in ipairs(enemies) do
        local enemy_distance = player_position:dist_to(enemy:get_position())
        if enemy_distance < distance then

            -- adding multiple channel spells just overrides the current one 
            cast_spell.add_channel_spell(spell_id_dance_of_knives, 0, 1, nil, get_cursor_position(),
            dance_of_knives_menu_elements_base.animation_delay:get(), dance_of_knives_menu_elements_base.interval:get())
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time;
            console.print("Channeling dance of knives");

        end
    end

    return false
end

return
{
    menu = menu,
    logics = logics,
}

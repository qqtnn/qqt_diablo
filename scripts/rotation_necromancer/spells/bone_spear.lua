local my_utility = require("my_utility/my_utility");

local menu_elements_spear_base =
{
    tree_tab_bone                       = tree_node:new(1),
    main_boolean_bone                   = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_bone_spear_base")),
    allow_elite_single_target           = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_elite_single_target_spear_base")),
    min_hits_slider                     = slider_int:new(0, 30, 4, get_hash(my_utility.plugin_label .. "bone_spear_min_hits_slider")),
    animation_delay_slider              = slider_float:new(0.0, 0.75, 0.50, get_hash(my_utility.plugin_label .. "bone_spear_animation_delay_slider")),
    recast_delay_slider                 = slider_float:new(0.0, 2.0, 0.66, get_hash(my_utility.plugin_label .. "bone_spear_recast_delay_slider")),

    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_spear_allow_percentage_hits")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "bone_spear_min_percentage_hits")),
    soft_score            = slider_float:new(2.0, 15.0, 6.0, get_hash(my_utility.plugin_label .. "bone_spear_min_percentage_hits_soft")),
}

local function menu()

    if menu_elements_spear_base.tree_tab_bone:push("Bone Spear") then
        menu_elements_spear_base.main_boolean_bone:render("Enable Spell", "")
        menu_elements_spear_base.allow_elite_single_target:render("Prio Bosses/Elites", "")

        menu_elements_spear_base.min_hits_slider:render("Min Hits", "");
        menu_elements_spear_base.recast_delay_slider:render("Recast Delay", "", 2);
        menu_elements_spear_base.animation_delay_slider:render("Animation Delay", "", 2);

        menu_elements_spear_base.allow_percentage_hits:render("Allow Percentage Hits", "");
        if menu_elements_spear_base.allow_percentage_hits:get() then
            menu_elements_spear_base.min_percentage_hits:render("Min Percentage Hits", "", 1);
            menu_elements_spear_base.soft_score:render("Soft Score", "", 1);
        end

        menu_elements_spear_base.tree_tab_bone:pop()
    end
end

local spell_id_bone_spear = 432879
local next_time_allowed_cast = 0.0;
local bone_spear_spell_data = spell_data:new(
    0.5,                        -- radius
    10.0,                       -- range
    1.7,                        -- cast_delay
    4.0,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_bone_spear,        -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local my_target_selector = require("my_utility/my_target_selector");

local function logics(target, entity_list)

    local menu_boolean = menu_elements_spear_base.main_boolean_bone:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_bone_spear);

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local player_pos = get_player_position();
    local current_resource = local_player:get_primary_resource_current();
    local max_resource = local_player:get_primary_resource_max();
    local resource_percentage = current_resource / max_resource;
    local is_low_resources = resource_percentage < 0.2;

    if is_low_resources then

        -- note: qqt, not included file so for now i comment im quickly solving all warnings idc, feel free to change
        -- local corpses_data = corpse_explosion_.get_corpse_explosion_data_default();
        -- if corpses_data.is_valid then
        --     return false;
        -- end
    end

    local rectangle_width = 2.0;
    local rectangle_lenght = 10
    -- return table:
-- hits_amount(int)
-- score(float)
-- main_target(gameobject)
-- victim_list(table game_object)
    local area_data = my_target_selector.get_most_hits_rectangle(player_pos, rectangle_lenght, rectangle_width)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end


    console.print("best_target found " .. best_target:get_skin_name())
    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, 1, 1, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list

    local is_single_target_allowed = false;
    if menu_elements_spear_base.allow_elite_single_target:get() then
        for _, unit in ipairs(best_hit_list) do
            local current_health_percentage = unit:get_current_health() / unit:get_max_health() * 100

            if unit:is_boss() and current_health_percentage > 2 then
                is_single_target_allowed = true
                break
            end


            if unit:is_elite() and current_health_percentage > 4 then
                is_single_target_allowed = true
                break
            end

            if unit:is_champion() and current_health_percentage > 4 then
                is_single_target_allowed = true
                break
            end
        end
    end


    local is_percentage_hits_allowed = menu_elements_spear_base.allow_percentage_hits:get();
    local min_percentage = menu_elements_spear_base.min_percentage_hits:get();
    if not is_percentage_hits_allowed then
        min_percentage = 0.0;
    end

    local min_hits_menu = menu_elements_spear_base.min_hits_slider:get()
    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage);

    if not is_area_valid  then
        console.print("is_area_valid")
        return false;
    end

    if not area_data.main_target:is_enemy() then
        console.print("not enemy")
        return false;
    end

    if not is_single_target_allowed and area_data.score < menu_elements_spear_base.soft_score:get() and menu_elements_spear_base.min_hits_slider:get() > 1 then
        console.print("not is_single_target_allowed")
        return false;
    end

    local best_cast_position = best_cast_data.point;
    if prediction.is_wall_collision(player_pos, best_cast_position, 0.66) then
        console.print("is_wall_collision")
        return false
    end

    local best_cast_hits = #best_hit_list
    if cast_spell.position(spell_id_bone_spear, best_cast_position, menu_elements_spear_base.animation_delay_slider:get()) then
        local extra_recast_delay = menu_elements_spear_base.recast_delay_slide:get()
        next_time_allowed_cast = get_time_since_inject() + extra_recast_delay
        console.print("Necromancer Plugin, Casted Spear, Target " .. best_target:get_skin_name() .. " Hits: " .. best_cast_hits);
        return true;
    end

    return false;
end

return
{
    menu = menu,
    logics = logics,
}
local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_rouge = character_id == 1;
if not is_rouge then
 return
end;

local menu = require("menu");

local spells =
{
    lunging_strike          = require("spells/lunging_strike"),
    bash                    = require("spells/bash"),
    frenzy                  = require("spells/frenzy"),
    flay                    = require("spells/flay"),
    hammer_of_ancients      = require("spells/hammer_of_ancients"),
    upheaval                = require("spells/upheaval"),
    double_swing            = require("spells/double_swing"),
    rend                    = require("spells/rend"),
    rallying_cry            = require("spells/rallying_cry"),
    challenging_shout       = require("spells/challenging_shout"),
    war_cry                 = require("spells/war_cry"),
    iron_skin               = require("spells/iron_skin"),
    ground_stomp            = require("spells/ground_stomp"),
    kick                    = require("spells/kick"),
    charge                  = require("spells/charge"),
    leap                    = require("spells/leap"),
    rupture                 = require("spells/rupture"),
    death_blow              = require("spells/death_blow"),
    wrath_of_the_berserk    = require("spells/wrath_of_the_berserk"),
    call_of_the_ancients    = require("spells/call_of_the_ancients"),
    -- iron_maelstorm          = require("spells/iron_maelstorm"),
    steel_grasp             = require("spells/steel_grasp"),
}

on_render_menu (function ()

    if not menu.main_tree:push("Warrior: Base") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.lunging_strike.menu();
    spells.bash.menu();
    spells.frenzy.menu();
    spells.flay.menu();
    spells.hammer_of_ancients.menu();
    spells.upheaval.menu();
    spells.double_swing.menu();
    spells.rend.menu();
    spells.rallying_cry.menu();
    spells.challenging_shout.menu();
    spells.war_cry.menu();
    spells.iron_skin.menu();
    spells.ground_stomp.menu();
    spells.kick.menu();
    spells.charge.menu();
    spells.leap.menu();
    spells.rupture.menu();
    spells.death_blow.menu();
    spells.wrath_of_the_berserk.menu();
    spells.call_of_the_ancients.menu();
    -- spells.iron_maelstorm.menu();
    spells.steel_grasp.menu();
    menu.main_tree:pop();
    
end
)

local can_move = 0.0;
local cast_end_time = 0.0;

local mount_buff_name = "Generic_SetCannotBeAddedToAITargetList";
local mount_buff_name_hash = mount_buff_name;
local mount_buff_name_hash_c = 1923;

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end
    
    if menu.main_boolean:get() == false then
        -- if plugin is disabled dont do any logic
        return;
    end;


    if spells.challenging_shout.logics()then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.4;
        -- return;
    end;

    if spells.war_cry.logics()then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.4;
        -- return;
    end;

    if spells.rallying_cry.logics()then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.4;
        -- return;
    end;

    if spells.iron_skin.logics()then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.2;
        -- return;
    end;

    if spells.call_of_the_ancients.logics()then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.2;
        -- return;
    end;

    if spells.wrath_of_the_berserk.logics()then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.2;
        -- return;
    end;

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    if not my_utility.is_action_allowed() then
        return;
    end  

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end
 
    local is_auto_play_active = auto_play.is_active();
    local max_range = 8.50;
    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = target_selector_data.closest_unit;
    -- local best_target_bash = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   

    if not best_target then
        return;
    end


    local best_target_position = best_target:get_position();
    local distance_sqr = best_target_position:squared_dist_to_ignore_z(player_position);

    if distance_sqr > (max_range * max_range) then            
        best_target = target_selector_data.closest_unit;
        local closer_pos = best_target:get_position();
        local distance_sqr_2 = closer_pos:squared_dist_to_ignore_z(player_position);
        if distance_sqr_2 > (max_range * max_range) then
            return;
        end
    end

    -- if spells.iron_maelstorm.logics(best_target)then
    --     cast_end_time = current_time + 0.3;
    --     return;
    -- end;

    if spells.ground_stomp.logics(best_target)then
        cast_end_time = current_time + 0.5;
        return;
    end;

    if spells.charge.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.steel_grasp.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.hammer_of_ancients.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.kick.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.leap.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.upheaval.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.double_swing.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.rend.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.death_blow.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.rupture.logics(best_target)then
        cast_end_time = current_time + 1.0;
        return;
    end;

    if spells.frenzy.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.flay.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.lunging_strike.logics(entity_list)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.bash.logics(entity_list)then
        -- ignore global cooldown -- test 04/06/2024 -- qqt
        -- cast_end_time = current_time + 0.2;
        return;
   end;
   
    local move_timer = get_time_since_inject()
    if move_timer < can_move then
        return;
    end;

    local is_auto_play = my_utility.is_auto_play_enabled();
    if is_auto_play then
        local player_position = local_player:get_position();
        local is_dangerous_evade_position = evade.is_dangerous_position(player_position);
        if not is_dangerous_evade_position then
            local closer_target = target_selector.get_target_closer(player_position, 15.0);
            if closer_target then
                -- if is_blood_mist then
                --     local closer_target_position = closer_target:get_position();
                --     local move_pos = closer_target_position:get_extended(player_position, -5.0);
                --     if pathfinder.move_to_cpathfinder(move_pos) then
                --         cast_end_time = current_time + 0.40;
                --         can_move = move_timer + 1.50;
                --         --console.print("auto play move_to_cpathfinder - 111")
                --     end
                -- else
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, 4.0);
                    if pathfinder.move_to_cpathfinder(move_pos) then
                        can_move = move_timer + 1.50;
                        --console.print("auto play move_to_cpathfinder - 222")
                    end
                -- end
                
            end
        end
    end
    
end)

local draw_player_circle = false;
local draw_enemy_circles = false;

on_render(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    local player_position = local_player:get_position();
    local player_screen_position = graphics.w2s(player_position);
    if player_screen_position:is_zero() then
        return;
    end

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end    

    if draw_enemy_circles then
        local enemies = actors_manager.get_enemy_npcs()

        for i,obj in ipairs(enemies) do
        local position = obj:get_position();
        local distance_sqr = position:squared_dist_to_ignore_z(player_position);
        local is_close = distance_sqr < (8.0 * 8.0);
            -- if is_close then
                graphics.circle_3d(position, 1, color_white(100));

                local future_position = prediction.get_future_unit_position(obj, 0.4);
                graphics.circle_3d(future_position, 0.5, color_yellow(100));
            -- end;
        end;
    end


    -- glow target -- quick pasted code cba about this game

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end
 
    local is_auto_play_active = auto_play.is_active();
    local max_range = 6.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

    -- console.print(max_range)

    local best_target = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   

    if not best_target then
        return;
    end

    if best_target and best_target:is_enemy()  then
        local glow_target_position = best_target:get_position();
        local glow_target_position_2d = graphics.w2s(glow_target_position);
        graphics.line(glow_target_position_2d, player_screen_position, color_red(180), 2.5)
        graphics.circle_3d(glow_target_position, 0.80, color_red(200), 2.0);
    end


end);

console.print("Lua Plugin - Barbarian Base - Version 1.5");
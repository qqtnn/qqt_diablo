local local_player = get_local_player();
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_sorc = character_id == 0;
if not is_sorc then
 return
end;

local menu = require("menu");

local spells =
{
    teleport_ench           = require("spells/teleport_ench"),
    teleport                = require("spells/teleport"),
    flame_shield            = require("spells/flame_shield"),           
    ice_blade               = require("spells/ice_blade"),               
    spear                   = require("spells/spear"),                     
    ball                    = require("spells/ball"),                  
    unstable_current        = require("spells/unstable_current"),     
    fire_bolt               = require("spells/fire_bolt"),
    frost_bolt              = require("spells/frost_bolt"),
    spark                   = require("spells/spark"),
    fireball                = require("spells/fireball"),
    frozen_orb              = require("spells/frozen_orb"),
    ice_shards              = require("spells/ice_shards"),
    charged_bolts           = require("spells/charged_bolts"),
    ice_armor               = require("spells/ice_armor"),
    hydra                   = require("spells/hydra"),
    blizzard                = require("spells/blizzard"),
    meteor                  = require("spells/meteor"),
    firewall                = require("spells/firewall"),
    deep_freeze             = require("spells/deep_freeze"),
    inferno                 = require("spells/inferno"),
    frost_nova              = require("spells/frost_nova"),
    arc_lash                = require("spells/arc_lash"),
    chain_lightning         = require("spells/chain_lightning")
}

on_render_menu (function ()

    if not menu.main_tree:push("Sorcerer: Base") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.teleport_ench.menu();
    spells.spark.menu();
    spells.frost_bolt.menu();
    spells.fire_bolt.menu();
    spells.arc_lash.menu();
    spells.fireball.menu();
    spells.frozen_orb.menu();
    spells.ice_shards.menu();
    spells.chain_lightning.menu();
    spells.charged_bolts.menu();
    spells.flame_shield.menu();
    spells.teleport.menu();
    spells.ice_armor.menu();
    spells.frost_nova.menu();
    spells.hydra.menu();
    spells.ice_blade.menu();
    spells.spear.menu();
    spells.blizzard.menu();
    spells.meteor.menu();
    spells.firewall.menu();
    spells.ball.menu();
    spells.deep_freeze.menu();
    spells.inferno.menu();
    spells.unstable_current.menu();
    menu.main_tree:pop();
    
end)

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

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    if not my_utility.is_action_allowed() then
        return;
    end  

    -- local local_player_buffs = local_player:get_buffs();
    -- for _, buff in ipairs(local_player_buffs) do
    --     --   console.print("buff name ", buff:name());
    --     --   console.print("buff hash ", buff.name_hash);

    -- end

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
    local max_range = 10.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

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

    -- spells logics begins:
    -- if local_player:is_spell_ready(959728) then
    --     console.print("spell is ready")
    -- end

    -- if not local_playeris_spell_ready(959728) then
    --     console.print("spell is not ready")
    -- end

    if spells.deep_freeze.logics()then
        cast_end_time = current_time + 4.0;
        return;
    end;

    if spells.blizzard.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.inferno.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.unstable_current.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.chain_lightning.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.arc_lash.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.frost_nova.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.flame_shield.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.ice_armor.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.teleport_ench.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    -- if local_player:is_spell_ready(959728)then
    --     cast_spell.position(959728, best_target_position, 0.3);
    --     return;
    -- end;

    if spells.teleport.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.ice_blade.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.spear.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.ball.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.fire_bolt.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.frost_bolt.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.spark.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.fireball.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.frozen_orb.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.ice_shards.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.charged_bolts.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.hydra.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.meteor.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.firewall.logics(best_target)then
        cast_end_time = current_time + 0.3;
    end
    
    -- auto play engage far away monsters
    local move_timer = get_time_since_inject()
    if move_timer < can_move then
        return;
    end;

    -- auto play engage far away monsters
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
                --         can_move = move_timer + 1.5;
                --         --console.print("auto play move_to_cpathfinder - 111")
                --     end
                -- else
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, 4.0);
                    if pathfinder.move_to_cpathfinder(move_pos) then
                        can_move = move_timer + 1.5;
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
    local max_range = 10.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

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

console.print("Lua Plugin - Sorcerer Base - Version 1.5");
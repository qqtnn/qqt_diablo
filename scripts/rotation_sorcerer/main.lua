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
    incinerate              = require("spells/incinerate"),
    chain_lightning         = require("spells/chain_lightning")
}

on_render_menu (function ()

    if not menu.main_tree:push("Sorcerer: Base") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");
    menu.immortal_boolean:render("Immortal Firebolt Sorc", "Needs 50 percent or higher Cooldown Reduction to work properly");
    if menu.immortal_boolean:get() then
        menu.immortal_drawings:render("Info Text", "Draws Immortal Firebolt Sorc related information");
    end

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.teleport_ench.menu();
    spells.spark.menu();
    spells.frost_bolt.menu();
    spells.fire_bolt.menu();
    spells.incinerate.menu();
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

    local local_player_buffs = local_player:get_buffs();
    for _, buff in ipairs(local_player_buffs) do
        --   console.print("buff name ", buff:name());
        --   console.print("buff hash ", buff.name_hash);
          if buff.name_hash == blood_mist_buff_name_hash_c then
              is_blood_mist = true;
              break;
          end
    end

    local screen_range = 12.0;
    local player_position = get_player_position();

    local collision_table = { true, 1.0 };
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

    local enemies_nearby = target_selector_data.is_valid or (best_target_position and best_target_position:squared_dist_to_ignore_z(player_position) > (8 * 8))
    -- Imortal Sorc
    local time_left = nil
    if menu.immortal_boolean:get() then
        local cursor_pos = get_cursor_position()
        local valid_height_cursor_pos = utility.set_height_of_valid_position(cursor_pos)
        local current_orb_mode = orbwalker.get_orb_mode();

        -- flame_shield
        if local_player:is_spell_ready(167341) then
            if current_orb_mode == orb_mode.none then
                return;
            end
            if current_orb_mode ~= orb_mode.none then
                local shield_time = get_time_since_inject()
                local next_shield_cast = 0.0
                if next_shield_cast > shield_time then
                    return;
                end
                if cast_spell.self(167341, 0.0) then
                    next_shield_cast = shield_time + 4.0
                    return;
                end
            end
            -- return;
        end;
        -- check if player has flame shield buff, if not, cast flameshield if orb mode does not equal none
        -- local has_flame_shield = false
        -- for _, buff in ipairs(local_player_buffs) do
        --     if buff.name_hash == 167341 then
        --         has_flame_shield = true
        --         break
        --     end
        -- end
        -- if not has_flame_shield then
        --     if local_player:is_spell_ready(167341) then
        --         if current_orb_mode == orb_mode.none then
        --             return;
        --         end
        --         if (current_orb_mode ~= orb_mode.none) or target_selector_data.is_valid then
        --             cast_spell.self(167341, 0.0);
        --             return;
        --         end
        --         return;
        --     end;
        -- end

        -- teleport_ench
        if spells.teleport_ench.menu_elements_teleport_ench.enchant_jmr_logic:get() then
            if local_player:is_spell_ready(959728) then
                if current_orb_mode == orb_mode.none then
                    return;
                end
                if current_orb_mode ~= orb_mode.none then
                    cast_spell.position(959728, valid_height_cursor_pos, 0.0);
                    return;
                end
                return;
            end;
        end
       

        -- fire_bolt
        if spells.fire_bolt.menu_elements_fire_bolt.jmr_logic:get() then
            if not enemies_nearby then
                if local_player:is_spell_ready(153249) then
                    if current_orb_mode == orb_mode.none then
                        return;
                    end
                    if current_orb_mode ~= orb_mode.none then
                        cast_spell.position(153249, valid_height_cursor_pos, 0.0);
                        return;
                    end
                    return;
                end;
            end;
        end
        
    end;

    if not target_selector_data.is_valid then
        return;
    end

    local is_auto_play_active = auto_play.is_active();
    local max_range = 12.0;
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

    local best_target = target_selector_data.closest_unit;

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
    if menu.immortal_boolean:get() then
        local current_orb_mode = orbwalker.get_orb_mode();  

        local function count_and_display_buffs()
            local local_player = get_local_player()
            local buff_name_check = "Ring_Unique_Sorc_101"
            if not local_player then return 0 end

            local buffs = local_player:get_buffs()
            if not buffs then return 0 end

            local buff_stack_count = -1

            for _, buff in ipairs(buffs) do
                local buff_name = buff:name()
                if buff_name == buff_name_check then
                    buff_stack_count = buff_stack_count + 1
                end
            end
            return buff_stack_count
        end

        local buff_stack_count = count_and_display_buffs()

        -- frostbolt for tal rasha
        if buff_stack_count == 3 and enemies_nearby then
            local local_player = get_local_player()
            if local_player:is_spell_ready(287256) then
                if current_orb_mode == orb_mode.none then
                    return;
                end
                if current_orb_mode ~= orb_mode.none then
                    cast_spell.position(287256, best_target_position, 0.0);
                    return;
                end
                return;
            end;
        end;
        -- auto attack exploit for 4 stacks
        -- if buff_stack_count == 4 and best_target:get_position():squared_dist_to_ignore_z(player_position) < 2 then
        --     if local_player:is_spell_ready(1201192) then
        --         if current_orb_mode == orb_mode.none then
        --             return;
        --         end
        --         if current_orb_mode ~= orb_mode.none then
        --             cast_spell.position(1201192, best_target_position, 0.0);
        --             return;
        --         end
        --         return;
        --     end;
        -- end;
    end

    local function should_firewall()
        local actors = actors_manager.get_all_actors()
        for _, actor in ipairs(actors) do
            local actor_name = actor:get_skin_name()
            if actor_name == "Generic_Proxy_firewall" then
                local actor_position = actor:get_position()
                local dx = math.abs(best_target_position:x() - actor_position:x())
                local dy = math.abs(best_target_position:y() - actor_position:y())    
                if dx <= 2 and dy <= 8 then  -- rectangle width is 2 and height is 8
                    return false
                end
            end
        end
        return true
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

    if spells.incinerate.logics(best_target)then
        cast_end_time = current_time + 0.1;
        return;
    end;

    if spells.frost_nova.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.flame_shield.logics()then
        cast_end_time = current_time;
        return;
    end;

    if spells.ice_armor.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if should_firewall and spells.firewall.logics(local_player, best_target)then
        cast_end_time = current_time;
    end

    if spells.teleport_ench.logics(best_target)then
        cast_end_time = current_time;
        return;
    end;

    -- if local_player:is_spell_ready(959728)then
    --     cast_spell.position(959728, best_target_position, 0.3);
    --     return;
    -- end;

    if spells.teleport.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time;
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

    if spells.spark.logics(best_target)then
        cast_end_time = current_time + 0.3;
        return;
    end;

    if spells.fireball.logics(best_target)then
        cast_end_time = current_time;
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

    if spells.fire_bolt.logics(best_target)then
        cast_end_time = current_time;
        return;
    end;
    
    if spells.frost_bolt.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;
    
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

    local function count_and_display_buffs()
        local local_player = get_local_player()
        local player_position = get_player_position()
        local player_position_2d = graphics.w2s(player_position)
        local text_position = vec2.new(player_position_2d.x, player_position_2d.y + 15)
        local buff_name_check = "Ring_Unique_Sorc_101"
        if not local_player then return 0 end

        local buffs = local_player:get_buffs()
        if not buffs then return 0 end

        local buff_stack_count = -1

        for _, buff in ipairs(buffs) do
            local buff_name = buff:name()
            if buff_name == buff_name_check then
                buff_stack_count = buff_stack_count + 1
            end
        end
        return buff_stack_count
    end

    local buff_stack_count = count_and_display_buffs()
    if menu.immortal_boolean:get() and menu.immortal_drawings:get() then
        if buff_stack_count == -1 then
            graphics.text_2d("Immortal Firebolt Sorc Loaded but you do not have Tal Rasha equipped", player_screen_position, 20, color_red(255), true, true);
        end
        if buff_stack_count >= 1 then
            -- print Tal Rasha buff stack is currently at buff_stack_count
            graphics.text_2d("Immortal Firebolt Sorc Loaded with Tal Rasha buff stack at " .. buff_stack_count - 1, player_screen_position, 20, color_green(255), true, true);
        end
        if buff_stack_count == 3 then
            -- print Tal Rasha needs Frost Bolt to gain stack. CASTING FROST Bolt
            graphics.text_2d("Immortal Firebolt Sorc Loaded with Tal Rasha buff stack at 2", vec2:new(player_screen_position.x, player_screen_position.y + 20), 20, color_cyan(255), true, true);
            graphics.text_2d("Casting Frost Bolt to gain stack", vec2:new(player_screen_position.x, player_screen_position.y + 40), 20, color_cyan(255), true, true);
        end
        -- Immortal sorc needs 165023(Fireball, 959728(Teleport Enchantment), 111422(Firewall), 153249(Firebolt), 167341(Flame Shield) and 287256(Frostbolt) to work properly
        -- place needed spells into a list. check if the spells are equipped. If a spell is not equipped, display a message that the spell name is not equipped
        local needed_spells = {165023, 111422, 153249, 167341, 287256}
        local spell_ids = get_equipped_spell_ids() -- Returns a table of 6 spell IDs

        -- Convert spell_ids to a set for faster lookup
        local spell_ids_set = {}
        for _, id in ipairs(spell_ids) do
            spell_ids_set[id] = true
        end

        for i, spell_id in ipairs(needed_spells) do
            local spell_name = "Unknown Spell"

            if spell_id > 1 then
                spell_name = get_name_for_spell(spell_id);
            end
            
            -- Check if the spell is missing
            if not spell_ids_set[spell_id] then
                local missing_spell_info = string.format("%s is missing and is needed for Immortal Firebolt Sorc", spell_name)
                graphics.text_2d(missing_spell_info, vec2:new(player_screen_position.x, 200 + 20 * (i + #needed_spells)), 20, color_red(255))
            end
        end
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

    local screen_range = 12.0;
    local player_position = get_player_position();

    local collision_table = { true, 1.0 };
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
    local max_range = 12.0;
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
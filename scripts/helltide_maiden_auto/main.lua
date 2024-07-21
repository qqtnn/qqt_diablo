-- failsafe to not run script early or during loading screens
local local_player = get_local_player()
if local_player == nil then 
    return
end

-- used to create ingame menu via LUA scripting engine, merges with menu.lua
local menu = require("menu")
-- tick rate for on_update() logic (does not affect on_render())
local last_update_time = 0
-- used to check if current zone is running active helltide
local player_in_helltide_zone = 0
-- used to check if player is already mounted
local did_mount_player = 0
-- iterator for helltide_tps
local helltide_tps_iter = 1
-- current helltide zone name
local helltide_zone_name = "Unknown"
-- if is target waypoint maiden location is pinned on map already
local helltide_zone_pin = 0
-- stored final maidenpos for map pin
local helltide_final_maidenpos = nil
local helltide_tps_next_zone_name = ""
-- internal app finish state
local helltide_maiden_arrivalstate = 0
-- custom waypoint list to walk to helltide maiden boss for EACH helltide_tps
-- running with custom waypoint list to hopefully not get stuck and it is way faster then dynamically going there
-- will be filled dynamically based on helltide_zone_name
local maidenpos = {}
-- vec3 next position
local pathfinder_nextpos = nil
-- vec3 previous position
local pathfinder_prevpos = nil
-- vec3 last position to allow checking for being stuck
local distance_check_distance = 0
local distance_check_last_player_position = nil
local distance_check_last_time = 0
local distance_check_is_stuck = 0
local distance_check_is_stuck_counter = 0
local distance_check_is_stuck_first_time = 0
-- available app tasks
local helltide_maiden_auto_tasks = {
    FIND_ZONE = "Trying to find helltide zone using teleporter",
    IN_TELEPORT = "Waiting for teleporter to finish",
    FOUND_ZONE = "Found helltide zone, walking to maiden",
    FOUND_ZONE_STUCK = "Found helltide zone, walking to maiden - WARNING: Pathfinder stuck detected, running alternative",
    ARRIVED = "Arrived at helltide maiden",
    INSERT = "Inserting heart to spawn helltide maiden",
    LOOT = "Looting items",
    REPAIR = "Auto-Play REPAIR",
    SELLSALVAGE = "Auto-Play SELL OR SALVAGE"
}
-- current running app task
local helltide_maiden_auto_task = helltide_maiden_auto_tasks.FIND_ZONE
-- helper text window at arival
local show_helper_text_time_up = nil
-- enable or disable explorer at helltide maiden
local run_explorer = 0
local run_explorer_is_close = 0
local run_explorer_modes = {
    OFF = "Disabled",
    CLOSERANDOM = "Enabled - Run to close/distance enemies then use random position",
    RANDOM = "Enabled - Run to random positions and ignore enemies"
}
-- current running explorer mode
local run_explorer_mode = run_explorer_modes.OFF
local explorer_points = nil
local explorer_point = nil
local explorer_go_next = 1
local explorer_threshold = 0.0
local explorer_thresholdvar = 0.0
local last_explorer_threshold_check = 0
local explorer_circle_radius = 1.0
local explorer_circle_radius_prev = 0.0
-- tick rate to insert hearts to spawn helltide Maiden
local insert_hearts = 0
local insert_hearts_afterboss = 0
local insert_hearts_time = 0
-- tick rate after put hearts 10seconds to give chance to insert before restarting explorer logic
local insert_hearts_waiter = 0
local insert_hearts_waiter_interval = 10.0
local insert_hearts_waiter_elapsed = 0
local old_currenthearts = 0
local last_insert_hearts_waiter_time = 0
local seen_boss_dead = 0
local seen_boss_dead_time = 0
local seen_enemies = 0
local last_seen_enemies_elapsed = 0
local insert_only_with_npcs_playercount = 0

-- helper function to reset app variables, try to find next closes point and re-start app logic e.g. being at helltide maiden boss
local function reset_helltide_maiden()
    player_in_helltide_zone = 0
    helltide_zone_pin = 0
    -- helltide_tps_iter = 1
    -- helltide_tps_next_zone_name = ""
    helltide_zone_name = "Unknown"
    helltide_maiden_auto_task = helltide_maiden_auto_tasks.FIND_ZONE
    helltide_maiden_arrivalstate = 0
    pathfinder_nextpos = nil
    pathfinder_prevpos = nil
    distance_check_distance = 0
    distance_check_last_player_position = nil
    distance_check_last_time = 0
    distance_check_is_stuck = 0
    distance_check_is_stuck_counter = 0
    distance_check_is_stuck_first_time = 0
    helltide_final_maidenpos = nil
    show_helper_text_time_up = nil
    maidenpos = {}
    pathfinder.clear_stored_path()
    run_explorer_mode = run_explorer_modes.OFF
    explorer_points = nil
    explorer_go_next = 1
    run_explorer_is_close = 0
    explorer_point = nil
    last_explorer_threshold_check = 0
    insert_hearts_time = 0
    insert_hearts_waiter = 0
    insert_hearts_waiter_elapsed = 0
    last_insert_hearts_waiter_time = 0
    seen_boss_dead = 0
    seen_boss_dead_time = 0
    seen_enemies = 0
    last_seen_enemies_elapsed = 0
    insert_only_with_npcs_playercount = 0
    -- current_mount_state = 0
    -- do_a_mount_or_unmount_once = 0
    -- do_a_mount_last_time = 0
    -- do_repair_next = 0
    -- is_repair_next = 0
    -- is_sellsalv_next = 0
end

-- helper function to count enum sizes / lengthes of tables
local function table_length(table_in)
    local count = 0
    for _ in pairs(table_in) do
        count = count + 1
    end
    return count
end

-- helper function to math.round with decimal support, LUA does not have the most basics ;-)
local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- helper function to receive random element from table
function random_element(tb)
    local keys = {}
    for k in pairs(tb) do
        table.insert(keys, k)
    end
    return tb[keys[math.random(#keys)]]
end

-- helper function to find positions within circle (Credits: QQT)
local function get_positions_in_radius(center_point, radius)
    local positions = {}
    local radius_squared = radius * radius
    local insert = {}
    insert = table.insert
    local center_x = center_point:x()
    local center_y = center_point:y()
    local center_z = center_point:z()

    for x = -radius, radius do
        local x_pos = center_x + x
        local x_squared = x * x
        for y = -radius, radius do
            local y_pos = center_y + y
            local y_squared = y * y
            local z_max_squared = radius_squared - x_squared - y_squared
            if z_max_squared >= 0 then
                local z_max = math.floor(math.sqrt(z_max_squared))
                for z = -z_max, z_max do
                    insert(positions, vec3:new(x_pos, y_pos, center_z + z))
                end
            end
        end
    end

    return positions
end

-- helltide TP locations
-- only with supported waypoints (TP target must directly lead to helltide zones, sometimes that is not the case and you have to walk, these tp waypoints are not supported, it doesnt matter since you will still hit all helltide zones any time with atleast one valid teleporter - but you will never seen some particular maiden using this logic)
local helltide_tps = {
    {name = "Menestad (internal name: Frac_Tundra_S)", id = 0xACE9B},
    {name = "Marowen (internal name: Scos_Coast)", id = 0x27E01},
    {name = "Iron Wolves Encampment (internal name: Kehj_Oasis/Kehj_HighDesert)", id = 0xDEAFC},
    {name = "Wejinhani (internal name: Hawe_Verge)", id = 0x9346B},
    {name = "Ruins of Rakhat Keep Inner Court (internal name: Hawe_ZakFort)", id = 0xF77C2},
    {name = "Jirandai (internal name: Step_South)", id = 0x462E2}
}

local loading_start_time = nil
-- helper function to teleport to next waypoint looping all hellpoint_tps
local function tp_to_next()
    -- console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - called")
    
    -- do not jump when already jumping
    local current_time = os.clock()
    local current_world = world.get_current_world()
    if not current_world then
        return
    end

    -- we are in limbo loading screen
    if current_world:get_name():find("Limbo") then
        -- If we are in limbo, set the loading start time
        if not loading_start_time then
            loading_start_time = current_time
        end
        return
    else
        -- If we were in limbo, but now we are not, check if 4 seconds have passed since loading started
        if loading_start_time and (current_time - loading_start_time) < 4 then
            return
        end
        -- Reset loading start time after waiting
        loading_start_time = nil
    end

    -- teleport to next waypoint from helltide_tps
    for i in pairs(helltide_tps) do
        if i == helltide_tps_iter then
            console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - teleporting to helltide_tps_iter = " .. helltide_tps_iter .. " Zone Name = " .. helltide_tps[i].name .. " ID = " .. helltide_tps[i].id)
            helltide_tps_next_zone_name = helltide_tps[i].name
            -- teleport to waypoint
            teleport_to_waypoint(helltide_tps[i].id)
            -- make sure we increment to next waypoint for next run, we dont want to jump again here
            helltide_tps_iter = helltide_tps_iter + 1
            -- when found we are done
            break
        end
    end

    -- check if we reached the end of available waypoint TPs, then we start over from the beginning
    local length_helltide_tps = table_length(helltide_tps)
    if helltide_tps_iter > length_helltide_tps then
        -- reset current tp iterator will loop back to start
        helltide_tps_iter = 1
    end
end


-- load fixed waypoint list for each helltide zone maiden boss depending on current helltide zone
local function maidenpos_load()
    -- failsafe to not run script early or during loading screens
    local local_player = get_local_player()
    if not local_player then
        return
    end
    -- get current player position vec3 x,y,z
    local player_position = local_player:get_position()
    if not player_position then
        return
    end

    -- console.print("[HELLTIDE-MAIDEN-AUTO] maidenpos_load() - LOADING maidenpos for helltide zone = " .. helltide_zone_name)
    local maidenpos_length = 0

    -- waypoints recorded with 1.75 distance
    maidenpos_length = table_length(maidenpos)
    if maidenpos_length == 0 then
        -- maidenpos empty, fill depending on current helltide zone
        -- Helltide Zone: Marowen (Scos_Coast)
        if helltide_zone_name == "Scos_Coast" then
            helltide_final_maidenpos = vec3:new(-1982.549438, -1143.823364, 12.758240)

        -- Menestad (Frac_Tundra_S)
        elseif helltide_zone_name == "Frac_Tundra_S" then
            helltide_final_maidenpos = vec3:new(-1517.776733, -20.840151, 105.299805)

        -- Iron Wolves Encampment starts at: (Kehj_Oasis) but ends in: (Kehj_HighDesert)
        elseif helltide_zone_name == "Kehj_Oasis" or helltide_zone_name == "Kehj_HighDesert" then
            helltide_final_maidenpos =  vec3:new(120.874367, -746.962341, 7.089052)
        -- Ruins of Rakhat Keep Inner Court (Hawe_ZakFort)
        elseif helltide_zone_name == "Hawe_ZakFort" then
            helltide_final_maidenpos = vec3:new(-680.988770, 725.340576, 0.389648) 
        -- Wejinhani (Hawe_Verge)
        elseif helltide_zone_name == "Hawe_Verge" then
            helltide_final_maidenpos = vec3:new(-1070.214600, 449.095276, 16.321373)
          
        -- Jirandai (Step_South)
        elseif helltide_zone_name == "Step_South" then
            helltide_final_maidenpos = vec3:new(-464.924530, -327.773132, 36.178608)
          
        else
            -- unsupported helltide zone yet, requires manual waypoint, landing here means developer missed something
            console.print("[HELLTIDE-MAIDEN-AUTO] maidenpos_load() - ERROR 111 no waypoints for helltide zone = " .. helltide_zone_name)
        end

        if helltide_final_maidenpos and not helltide_final_maidenpos:is_zero() then
            pathfinder.clear_stored_path()
            utility.set_map_pin(helltide_final_maidenpos)
            maidenpos = pathfinder.create_path_game_engine(helltide_final_maidenpos)
            console.print("create_path_game_engine called to maiden place")
    
            if #maidenpos > 0 then
                
                pathfinder.set_last_waypoint_index(1)
                pathfinder.sort_waypoints(maidenpos, get_player_position())
            end
        else
            console.print("[HELLTIDE-MAIDEN-AUTO] maidenpos_load() - ERROR 222 no final pos for helltide zone = " .. helltide_zone_name)
        end
    end

    -- -- set final waypoint for utility pin based on last waypoint in array
    -- maidenpos_length = table_length(maidenpos)
    -- if maidenpos_length > 0 then
    --     helltide_final_maidenpos = maidenpos[maidenpos_length]
    -- end
end

-- configure ingame menu
on_render_menu(function()

    if not menu.main_tree:push("Mera-Helltide Maiden Auto v1.3") then
        return
    end

    -- checkbox to enable/disable plugin
    menu.main_helltide_maiden_auto_plugin_enabled:render("Enable Plugin", "Enable or disable this plugin, starting it will start teleporting")

    -- checkbox to enable/disable run_explorer after arriving at helltide maiden
    menu.main_helltide_maiden_auto_plugin_run_explorer:render("Run Explorer At Maiden", "Walks to enemies first around at helltide maiden boss within the Limit Explore circle radius, if no enemies found, uses random positions.")
    if menu.main_helltide_maiden_auto_plugin_run_explorer:get() then
        menu.main_helltide_maiden_auto_plugin_run_explorer_close_first:render("Explorer Run To Enemies First", "Focus on close and distance enemies and then try random positions")
        menu.main_helltide_maiden_auto_plugin_explorer_threshold:render("Mov. Threshold", "Slows down selecting of new positions for anti-bot behaviour", 2)
        menu.main_helltide_maiden_auto_plugin_explorer_thresholdvar:render("Randomizer", "Adds random threshold on top of movement threshold for more randomness", 2)
        -- checkbox to enable/disable rendering circle around final helltide maiden position
        menu.main_helltide_maiden_auto_plugin_show_explorer_circle:render("Explorer Draw Circle", "Show Exploring Circle to verify walking range (white) and target walkpoints (blue)")
        menu.main_helltide_maiden_auto_plugin_explorer_circle_radius:render("Limit Explore", "Limit exploring location", 2)
    end

    -- checkbox to enable/disable auto revive on death
    menu.main_helltide_maiden_auto_plugin_auto_revive:render("Auto Revive", "Automatically revive on death")

    -- checkbox to enable/disable helltide zone printing
    menu.main_helltide_maiden_auto_plugin_show_task:render("Show Task", "Show current task at top left screen location")

    -- checkbox to insert hearts after desired time to spawn helltide maiden boss
    menu.main_helltide_maiden_auto_plugin_insert_hearts:render("Insert hearts", "Will try to insert hearts after reaching heart timer, requires hearts available")
    if menu.main_helltide_maiden_auto_plugin_insert_hearts:get() then
        menu.main_helltide_maiden_auto_plugin_insert_hearts_afterboss:render("Insert heart after maiden death", "Directly put in heart after helltide maiden boss was seen dead")
        menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:render("Insert heart after seen no enemies", "Put in heart after no enemies are seen for a particular time in the circle")
        if menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:get() then
            menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider:render("Timer No enemies", "Time in seconds after trying to insert heart when no enemies are seen", 2)
        end
        menu.main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs:render("Insert Only If Players In Range", "Inserts hearts only if players are in range, may disable all other features if no players seen at altar")
    end

    -- Loot Logic Configuration
    menu.enable_loot_logic:render("Enable Auto-Loot Logic", "Enable or disable the loot logic feature")
    if menu.enable_loot_logic:get() then
        menu.only_loot_ga:render("Only Loot GA Items", "Only loot items containing greater affixes")
    end

    menu.enable_sell_logic:render("Enable Auto-Sell Logic", "Enable or disable the sell logic feature")
    if menu.enable_sell_logic:get() then
        menu.salvage_instead:render("Salvage Instead", "Salvage items instead of selling them")
    end

    menu.enable_repair_logic:render("Enable Auto-Repair Logic", "Enable or disable the repair logic feature")
    
    -- checkbox to reset any time after arriving at helltide maiden or being in weired states / perma-stuck
    menu.main_helltide_maiden_auto_plugin_reset:render("Reset (dont keep on)", "Temporary enable reset mode to reset plugin")

end)

-- variables for autoreset script
local last_reset_time = 0
-- variables to track the last active spell time
local last_active_spell_time = 0
-- variables for auto-mounting, which needs time to get the buff up
local current_mount_state = 0
local do_a_mount_or_unmount_once = 0
local do_a_mount_last_time = 0
local do_repair_next = 0
local is_repair_next = 0
local is_sellsalv_next = 0
local item_attempt_counter = {}
local item_blacklist = {}

-- Utility function to get time in milliseconds
local function get_time_ms()
    return os.clock() * 1000
end

-- Function to check if the time since the last active spell is less than 2000 ms
local function can_run_loot_logic()
   
    return get_time_ms() - last_active_spell_time >= 2000
end

-- Function to run the loot logic
function is_running_loot_logic(objective_id)
    if not can_run_loot_logic() then
        -- console.print("aborting runing loot logic")
        return false
    end

    if objective_id ~= objective.loot then
        return
    end

    if not menu.enable_loot_logic:get() then
        -- console.print("aborting runing loot logic - menu")
        return false
    end

    -- Fetch all items
    local items = actors_manager.get_all_items()

    -- Sort items by distance
    table.sort(items, function(a, b)
        return a:get_position():squared_dist_to(local_player:get_position()) < b:get_position():squared_dist_to(local_player:get_position())
    end)

    -- Pick up items based on configuration
    for _, item in ipairs(items) do
        local item_id = item:get_id()

        -- Skip blacklisted items
        if item_blacklist[item_id] then
            -- console.print("Item " .. item_id .. " is blacklisted")
            goto continue
        end

        -- Initialize attempt counter for this item if not already set
        if not item_attempt_counter[item_id] then
            item_attempt_counter[item_id] = 0
        end

        -- Check if the item meets the criteria
        if not menu.only_loot_ga:get() then
           -- console.print("runing loot logic")
            helltide_maiden_auto_task = helltide_maiden_auto_tasks.LOOT
            local success = loot_manager.loot_item(item, true, true)
            if success then
                -- Reset attempt counter on success
                item_attempt_counter[item_id] = 0
                return
            else
                -- Increment attempt counter on failure
                item_attempt_counter[item_id] = item_attempt_counter[item_id] + 1
                if item_attempt_counter[item_id] >= 200 then
                    -- Blacklist item after 200 attempts
                    item_blacklist[item_id] = true
                    -- console.print("Blacklisting item " .. item_id)
                end
            end
        else
            local item_data = item:get_item_info()
            if item_data and item_data:is_valid() then -- prevent accesing invalid ptr
                if string.find(item_data:get_display_name(), "GreaterAffix") then
                    -- console.print("runing loot logic")
                    helltide_maiden_auto_task = helltide_maiden_auto_tasks.LOOT
                    local success = loot_manager.loot_item(item, true, true)
                    if success then
                        -- Reset attempt counter on success
                        item_attempt_counter[item_id] = 0
                        return true
                    else
                        -- Increment attempt counter on failure
                        item_attempt_counter[item_id] = item_attempt_counter[item_id] + 1
                        if item_attempt_counter[item_id] >= 200 then
                            -- Blacklist item after 200 attempts
                            item_blacklist[item_id] = true
                            -- console.print("Blacklisting item " .. item_id)
                        end
                    end
                end
            end
        end -- end of only_loot_ga

        ::continue::
    end

    return false
end

local dorepair_after_being_full = 0
function run_sell_logic(objective_id)
    -- console.print("objective_id " .. objective_id)
    if objective_id ~= objective.sell then
        return
    end

    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return false
    end

    if not menu.enable_sell_logic:get() then
        return false
    end
    
    local local_player = get_local_player()
    if not local_player then
        return false
    end
    -- local inventory_items = local_player:get_inventory_items()
    -- local amount_of_items_in_inventory = table_length(inventory_items)
    -- if amount_of_items_in_inventory > 3 then
    -- --if amount_of_items_in_inventory == 33 then -- 33 is full inventory
    --     console.print("[HELLTIDE-MAIDEN-AUTO] run_sell_logic() - Starting Auto_Play Salvage or Sell")
    --     helltide_maiden_auto_task = helltide_maiden_auto_tasks.SELLSALVAGE
    --     dorepair_after_being_full = 1 -- trigger auto_play.repair_routine() after salvage or sell

    
    -- inventory full start salvage or sell
    if menu.salvage_instead:get() then
        auto_play.salvage_routine()
        return true
    else
        auto_play.sell_routine()
        return true
    end

    return false
end

function run_repair_logic(objective_id)

    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return false
    end

    -- console.print("objective_id " .. objective_id)
    if objective_id ~= objective.repair then
        return
    end
    
    if not menu.enable_repair_logic:get() then
        return false
    end

    auto_play.repair_routine()
    return true
end
  
-- use for core logic
on_update(function()

    -- failsafe to not run script early or during loading screens
    local local_player = get_local_player()
    if not local_player then
        return
    end
    
    -- check if plugin is enabled/disabled via ingame menu
    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return
    end
    
    local active_spell = local_player:get_active_spell_id();
    if active_spell == 197833 then
        return
    end

    if active_spell > 0 then
        last_active_spell_time = get_time_ms()
    end
    
    local is_in_helltides = 0
    local buffs = local_player:get_buffs()
    if buffs then
        for i, buff in ipairs(buffs) do
            -- player buff name during helltide zone equals to "UberSubzone_TrackingPower"
            if buff.name_hash == 1066539 then 
                is_in_helltides = 1
            end
        end
    end

    if get_time_ms() - last_active_spell_time >= 10000 and helltide_maiden_arrivalstate > 0 
    and found_player_in_helltide_zone == 0 then
       if get_time_ms() - last_reset_time >= 200000 then -- 200 seconds
           console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Resetting Helltide")
           reset_helltide_maiden()
           last_reset_time = get_time_ms()
       end
    end

    local objective_id = auto_play.get_objective()
    
    if run_sell_logic(objective_id) then
        return
    end

    if run_repair_logic(objective_id) then
       return
    end

     -- we are inside helltides and in maiden, we loot around anytime idk
    -- good place
    if is_running_loot_logic(objective_id) then
        return
    end

    -- console.print("objective_id " .. objective_id)
    if objective_id == objective.fight then
        auto_play.set_tmp_override(get_time_since_inject())
    end

    -- tick rate logic
    local current_time = os.clock()
    if current_time - last_update_time < 0.1 then
        return
    end
    last_update_time = current_time

    -- get current player position vec3 x,y,z
    local player_position = local_player:get_position()
    if not player_position then
        return
    end

    -- configure run_explorer and run_explorer_is_close / run_explorer_mode depending on UI menu
    if menu.main_helltide_maiden_auto_plugin_run_explorer:get() then
        run_explorer = 1
        if menu.main_helltide_maiden_auto_plugin_run_explorer_close_first:get() then
            run_explorer_is_close = 1
            run_explorer_mode = run_explorer_modes.CLOSERANDOM
        else
            run_explorer_is_close = 0
            run_explorer_mode = run_explorer_modes.RANDOM
        end
        explorer_circle_radius = menu.main_helltide_maiden_auto_plugin_explorer_circle_radius:get()
    else
        run_explorer = 0
        run_explorer_mode = run_explorer_modes.OFF
    end

    -- configure inserts_hearts depending on UI menu
    if menu.main_helltide_maiden_auto_plugin_insert_hearts:get() then
        insert_hearts = 1
        if menu.main_helltide_maiden_auto_plugin_insert_hearts_afterboss:get() then
            insert_hearts_afterboss = 1
        else
            insert_hearts_afterboss = 0
        end
    else
        insert_hearts = 0
        insert_hearts_afterboss = 0
        insert_only_with_npcs_playercount = 0
    end

    -- check if reset is enabled/disabled via ingame menu
    if menu.main_helltide_maiden_auto_plugin_reset:get() then
        console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Resetting")
        reset_helltide_maiden()
        return
    end

    -- always try to revive in case we are dead
    if menu.main_helltide_maiden_auto_plugin_auto_revive:get() then
        if local_player:is_dead() then
            revive_at_checkpoint()
        end
    end
  
    -- give mount animation time
    if do_a_mount_or_unmount_once == 1 then
        if current_time - do_a_mount_last_time < 2.0 then -- give 2 seconds animation time
            return
        else 
            -- waited enough time
            do_a_mount_or_unmount_once = 0
            -- force being in helltide even if buff is gone while being mounted, if we called to be mounted we are in a helltide zone
            player_in_helltide_zone = 1
        end
    end     

    -- get all current player buffs to identify if player is being in helltide zone
    local buffs = local_player:get_buffs()
    if buffs then
        -- allow to return to 0 state when nothing is found
        local found_player_in_helltide_zone = 0
        local found_player_is_mounted = 0
        -- check if being mounted to allow some accidentally mounting clicks
        for i, buff in ipairs(buffs) do
            if buff.name_hash == 1066539 then          -- player buff name during helltide zone equals to "UberSubzone_TrackingPower"
                found_player_in_helltide_zone = 1
            end
            if buff.name_hash == 1924 then             -- player buff name during mount state, this really takes time to get up after the mount
                found_player_is_mounted = 1
            end
        end
  
        -- if player was in helltide before and is_mounted now, dont reset
        if found_player_is_mounted == 1 and player_in_helltide_zone == 1 and found_player_in_helltide_zone == 0 then
            -- force being in helltide even if buff is gone while being mounted
            player_in_helltide_zone = 1
            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player probably accidentally mounted in helltide zone, forcing active helltide zone")
        else
            if found_player_in_helltide_zone == 1 then
                player_in_helltide_zone = 1
            else
                -- buff/unmount arrival timing issue
                if helltide_maiden_arrivalstate == 1 and found_player_in_helltide_zone == 1 then
                    player_in_helltide_zone = 1
                else
                    player_in_helltide_zone = 0
                end
            end
        end
        
         -- always reset current value depending on buff found in loop
        current_mount_state = found_player_is_mounted       
    end

    -- check if being stuck via distance_check
    -- dont do this while waiting for teleport
    if helltide_maiden_auto_task ~= helltide_maiden_auto_tasks.IN_TELEPORT then
        -- calculate distance moved based on 4 seconds old previous player_position
        if not distance_check_last_player_position or current_time - distance_check_last_time > 4.0 then
            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Distance-Check - 4s passed saving current player_position")
            distance_check_last_player_position = player_position
            distance_check_last_time = current_time
        end
        -- calculate distance moved (executed more frames, but uses old data then)
        distance_check_distance = player_position:dist_to(distance_check_last_player_position)
        if distance_check_distance < 1.0 then
            distance_check_is_stuck_counter = distance_check_is_stuck_counter + 1
            if distance_check_is_stuck_counter == 1 then
                distance_check_is_stuck_first_time = current_time
                -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Distance-Check - Possible stuck, first time detected")
            end
        else
            distance_check_is_stuck_counter = 0
            distance_check_is_stuck = 0
        end
        -- try to wait 5 seconds based on update_interval calling this thread (give 0.5 extra because distance_check triggers FP for the first time on reset)
        if distance_check_is_stuck_counter >= 55 then
            distance_check_is_stuck = 1
            distance_check_is_stuck_counter = 0
            local elapsed = current_time - distance_check_is_stuck_first_time
            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Distance-Check - WARNING - Stuck threshold reached, enabling Is_Stuck - took: " .. elapsed .. " seconds to detect")
        end
    end

    -- check if player is in helltide
    if player_in_helltide_zone == 1 then
    
        -- player is IN helltide
        -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player IN helltide detected")
        helltide_maiden_auto_task = helltide_maiden_auto_tasks.FOUND_ZONE

        local world_instance = world.get_current_world()
        if world_instance then
            helltide_zone_name = world_instance:get_current_zone_name()
        end

        -- load the required waypoints into maidenpos based on the current helltide_zone_name and helltide_final_maidenpos
        maidenpos_load()

        -- load waypoints for helltide_final_maidenpos after maidenpos_load()
        -- check if run_explorer is enabled/disabled via ingame menu
        if not explorer_points or explorer_circle_radius_prev ~= explorer_circle_radius then
            explorer_circle_radius_prev = explorer_circle_radius
            explorer_points = get_positions_in_radius(helltide_final_maidenpos, explorer_circle_radius)
            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - LOADED positions in helltide_final_maidenpos circle")
        end

        -- check if player arrived at helltide maiden boss
        if helltide_maiden_arrivalstate == 0 then
        
            -- mount if we are not mounted and not yet arrived at maiden  
            if current_mount_state == 0 then
                do_a_mount_or_unmount_once = 1
                do_a_mount_last_time = current_time
                -- this might get called twice because it was called to early after TP and game doesnt accept the call, next run will catch it
                utility.toggle_mount()
                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - (Re)-Mounting player in next game tick as this requires animation time and takes time to get the buffs up")
                return
            end
            
            -- proceed moving
            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Using pathfinder to walk to maiden")
            -- add final walking as pin on map for convenience
            -- set pin for final vec3 waypoint on map
            if helltide_final_maidenpos and helltide_zone_pin == 0 then
                utility.set_map_pin(helltide_final_maidenpos)
                helltide_zone_pin = 1
            end

            -- use pathfinder from core engine find closed position within vec3 table maidenpos using 1.1 threshold
            -- run only if not currently stuck
            if distance_check_is_stuck == 0 then
                -- run if NOT being stuck
                pathfinder_nextpos = pathfinder.get_next_waypoint(player_position, maidenpos, 1.1)
                if not pathfinder_nextpos then
                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - ERROR - Pathfinder cannot find next position from maidenpos")
                    return
                end
                pathfinder_nextpos = utility.set_height_of_valid_position(pathfinder_nextpos)
                pathfinder_prevpos = pathfinder_nextpos
                -- pathfinder.force_move(pathfinder_nextpos) -- faster with horse than request_move() else it would look bad
                pathfinder.force_move_raw(pathfinder_nextpos)
            else
                -- run if being stuck
                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - WARNING - Pathfinder STUCK detected finding next best walkable position based on current player position")
                helltide_maiden_auto_task = helltide_maiden_auto_tasks.FOUND_ZONE_STUCK
                -- find random position around player and force_move() instead of request_move()
                local random_pos_around_player = get_positions_in_radius(player_position, 10.0)
                local walkeable_pos = random_element(random_pos_around_player)
                walkeable_pos = utility.set_height_of_valid_position(walkeable_pos)
                if utility.is_point_walkeable_heavy(walkeable_pos) then
                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Found get_positions_in_radius() around current player_position, walking to alternative waypoint")
                    pathfinder.clear_stored_path()
                    -- pathfinder.force_move(walkeable_pos)
                    pathfinder.force_move_raw(walkeable_pos)
                end
            end

            -- check if we arrived
            if helltide_final_maidenpos then
                local distance_to_maiden = helltide_final_maidenpos:squared_dist_to(player_position)
                if distance_to_maiden < (8.0 * 8.0) then
                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Detected Player NEAR helltide maiden, setting helltide_maiden_arrivalstate")
                    helltide_maiden_arrivalstate = 1
                    -- throw away rest of this gametick to speed up
                    return
                end
            end

        else
            -- arrived at helltide maiden boss
            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player ARRIVED at helltide maiden")
            -- setting task to arrived
            helltide_maiden_auto_task = helltide_maiden_auto_tasks.ARRIVED
            
            -- unmount on arrival if mounted
            -- mount if we are not mounted and not yet arrived at maiden  
            if current_mount_state == 1 then
                do_a_mount_or_unmount_once = 1
                do_a_mount_last_time = current_time
                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - (Re)-UnMounting player in next game tick as this requires animation time and takes time to get the buffs up")
                utility.toggle_mount()
                return
            end             

            -- check if players are in range, else we dont insert any heart at all
            if insert_hearts == 1 and menu.main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs:get() then
                -- check NO if players are in range
                local player_actors = actors_manager.get_all_actors()
                local count_players_near = 0
                for i, obj in ipairs(player_actors) do
                    local position = obj:get_position()
                    local obj_class = obj:get_character_class_id()
                    local distance_maidenposcenter_to_player = position:squared_dist_to_ignore_z(helltide_final_maidenpos)
                    -- look for other players (have obj_class via get_character_class_id) alive near explorer_circle_radius units from center of maidenpos
                    -- get_all_players() and get_ally_players() dont return any player actors, probably bugged
                    -- get_ally_actors() is much slower hence we use get_all_actors()
                    if obj_class > -1 and distance_maidenposcenter_to_player <= (explorer_circle_radius * explorer_circle_radius) then
                        count_players_near = count_players_near + 1
                    end
                end
                -- dont count yourself
                insert_only_with_npcs_playercount = count_players_near - 1
                if insert_only_with_npcs_playercount == 0 then
                    -- found no other players in range
                    -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - NO OTHER PLAYERS FOUND IN CIRCLE, disabling to put in any heart")
                    insert_hearts = 0
                end
            end -- end of insert_only_with_npcs

            -- insert one heart after some interval into altar to spawn helltide maiden boss (if enabled in plugin menu)
            if insert_hearts == 1 then

                -- check if insert_hearts_waiter isnt enabled
                if insert_hearts_waiter == 0 then

                    -- if we see helltide boss dead and user enabled to directly put heart after it, force to put heart in
                    if insert_hearts_afterboss == 1 then
                        -- check if we see the boss dead yet (filters dead enemies)
                        -- check if we werent here before, coming from previous tick still seeing the same boss as dead
                        if current_time - seen_boss_dead_time > 30.0 then -- boss cant spawn more than 30seconds after each other, impossible
                            local enemies = actors_manager.get_all_actors()
                            for i, obj in ipairs(enemies) do
                                local name = string.lower(obj:get_skin_name())
                                local is_dead = obj:is_dead() and "Dead" or "Alive"
                                -- helltide maiden asset name
                                if is_dead == "Dead" and obj:is_enemy() and name == "s04_demon_succubus_miniboss" and seen_boss_dead == 0 then
                                    -- just do this once, the corpse is there for some longer time
                                    seen_boss_dead = 1
                                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - BOSS DEAD SEEN, enabling insert_hearts_time")
                                    -- forces to put in heart on next tick
                                    insert_hearts_time = 1
                                    -- we must throttle seen_boss because this will trigger multiply frames, making us to inserting multiply times, we dont want this
                                    seen_boss_dead_time = current_time
                                end
                            end
                        end
                    end -- end of insert_hearts_afterboss

                    -- check for enemies around helltide boss, count them and place heart after we see no enemies for particular time, enable insert_hearts_time
                    local enemies_seen_in_circle = utility.get_units_inside_circle_list(helltide_final_maidenpos, explorer_circle_radius)
                    local seeing_enemies = 0
                    for i, obj in ipairs(enemies_seen_in_circle) do
                        -- look for alive enemies
                        if obj:is_enemy() and not obj:is_dead() then
                            seeing_enemies = seeing_enemies + 1
                            last_seen_enemies_elapsed = 0
                        end
                    end
                    seen_enemies = seeing_enemies
                    -- check if we see enemies and reached the seen_enemies_interval and user has feature enabled
                    if menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:get() then
                        if last_seen_enemies_elapsed >= menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider:get() then
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - INSERTING HEART because timer of seen_enemies_interval reached while having active enemies of = " .. seen_enemies)
                            -- reset last_seen_enemies timer
                            last_seen_enemies_elapsed = 0
                            -- forces to put in heart on next tick
                            insert_hearts_time = 1
                        else
                            last_seen_enemies_elapsed = last_seen_enemies_elapsed + 0.1
                        end
                    end

                    -- check if its time to insert a heart
                    if insert_hearts_time == 1 and insert_hearts_waiter == 0  and helltide_final_maidenpos then
                        console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - INSERTING HEART because timer of seen_enemies or seen_boss_dead")
                        -- insert logic part 1
                        -- enable the waiter and walk to center of maidenpos
                        pathfinder.clear_stored_path()
                        -- pathfinder.force_move(helltide_final_maidenpos)
                        pathfinder.force_move_raw(helltide_final_maidenpos)
                        insert_hearts_waiter = 1
                        helltide_maiden_auto_task = helltide_maiden_auto_tasks.INSERT
                        last_insert_hearts_waiter_time = current_time
                        insert_hearts_waiter_elapsed = insert_hearts_waiter_interval
                        -- save current amount of hearts
                        old_currenthearts = get_helltide_coin_hearts()
                    end
                else
                    -- insert_hearts_waiter is still enabled
                    -- check if waiter is done, which waits after putting in something to give chance to put in
                    if current_time - last_insert_hearts_waiter_time > insert_hearts_waiter_interval then
                        console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - WAITED ENOUGH TIME AFTER INTERACTION - Falling back to exploring")
                        -- we gave enough time after inserting, fall back to exploring
                        insert_hearts_waiter = 0
                        insert_hearts_waiter_elapsed = insert_hearts_waiter_interval
                        insert_hearts_time = 0
                        seen_boss_dead = 0
                    else
                        -- we are still waiting for finishing of waiter
                        helltide_maiden_auto_task = helltide_maiden_auto_tasks.INSERT
                        insert_hearts_waiter_elapsed = insert_hearts_waiter_elapsed - 0.1
                        local current_hearts = get_helltide_coin_hearts()
                        -- we should be at the center of maidenpos
                        -- try inserting at least one heart
                        if current_hearts > 0 then
                            -- check if the altar is_interactable() -- TODO fix when core improved
                            -- for now we look if enemies are there
                            -- after boss dead it is also for sure interactable
                            if seen_enemies == 0 or seen_boss_dead == 1 then
                                local actors = actors_manager.get_all_actors()
                                -- try interacting once with all of the altar as long as get_helltide_coin_hearts() doesnt change
                                for _, actor in ipairs(actors) do
                                    local name = string.lower(actor:get_skin_name())
                                    -- check if we placed a heart yet, we try every 3 altars
                                    -- this might loop multiply times because interact_object() is NOT reliable
                                    if current_hearts >= old_currenthearts then
                                        -- altar asset name
                                        if name == "s04_smp_succuboss_altar_a_dyn" then
                                          -- insert logic part 2
                                          console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - INTERACTING WITH ONE ALTER OF MAIDEN, TRYING TO INSERT ONE HEART (MIGHT FAIL)")
                                          -- interact with maiden altar
                                          interact_object(actor)
                                          -- move one to next until we have plugged in one heart at any altar
                                        end
                                    else
                                        -- we plugged one break up, kill this tick and wait for waiter mode to finish
                                        return
                                    end
                               end
                           end
                        else -- no hearts
                            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - WARNING - No hearts available to put into altar")
                        end
                    end
                end
            end

            -- start explorer logic (if enabled in plugin menu)
            -- dont run while/after inserting
            if run_explorer == 1 and insert_hearts_waiter == 0 then
                -- console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - RUN EXPLORER")

                if explorer_points then
                    local close_enemy_pos = nil
                    if run_explorer_is_close == 1 then
                        -- first find a close enemy within circle
                        local enemies = utility.get_units_inside_circle_list(helltide_final_maidenpos, explorer_circle_radius)
                        for i, obj in ipairs(enemies) do
                            if obj:is_enemy() then
                                local position = obj:get_position()
                                local distance = position:dist_to(player_position)
                                local is_close = distance < 6.0
                                if is_close then
                                    close_enemy_pos = position
                                    -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer found close distance enemy, walking to it")
                                    -- take first close enemy
                                    break
                                else
                                    -- not in close range but in circle within
                                    -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer found far distance enemy, walking to it")
                                    close_enemy_pos = position
                                end
                            end
                        end
                    end
                    -- if no enemy is found, use random waypoint within circle
                    if not close_enemy_pos then
                        local random_waypoint = random_element(explorer_points)
                        random_waypoint = utility.set_height_of_valid_position(random_waypoint)
                        if utility.is_point_walkeable_heavy(random_waypoint) then
                            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer found random position within circle")
                            close_enemy_pos = random_waypoint
                        end
                    end
                    -- run to next walkpoint using explorer
                    if explorer_go_next == 1 then
                        -- before evaluating to go to next waypoint, check if we reach a threshold, this will make us idle around randomly
                        -- tick rate logic slowing down movement
                        if current_time - last_explorer_threshold_check < explorer_threshold then
                            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - WARNING - Explorer thresholding...")
                            return
                        end
                        last_explorer_threshold_check = current_time
                        -- use best suggested waypoint to walk to
                        if not close_enemy_pos then
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - ERROR - Explorer found no position to walk to")
                            return
                        end
                        -- try to never hit the same waypoint twice after same run, this makes it look like a bot shaking on one place
                        -- check if the new waypoint is at least a bit away from usage
                        local skip_new_point = 0
                        if explorer_point then
                            local distance_between_old_and_new = close_enemy_pos:dist_to(explorer_point)
                            if distance_between_old_and_new < 3.0 then
                                -- new point is too close, dont take it
                                skip_new_point = 1
                                -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - SKIPPING - Explorer suggested new position to close to previous position")
                            end
                        end
                        if skip_new_point == 0 then
                            -- randomize threshold variation depending on UI max value given
                            local slider_threshold = menu.main_helltide_maiden_auto_plugin_explorer_threshold:get()
                            explorer_thresholdvar = math.random(0, slider_threshold)
                            -- add the random threshold variation on top of the threshold, resulting in more randomness
                            explorer_threshold = slider_threshold + explorer_thresholdvar
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer walking next (t = " .. explorer_threshold .. " s = " .. slider_threshold .. " v = " .. explorer_thresholdvar)

                            -- use the point if its not too close to previous point
                            explorer_point = close_enemy_pos
                            -- pathfinder.request_move(explorer_point)
                            pathfinder.force_move_raw(explorer_point)

                            -- wait going to next waypoint until we reached previous
                            explorer_go_next = 0
                       end
                    else
                        if explorer_point and not explorer_point:is_zero() then
                            -- check if should go next
                            if player_position:dist_to(explorer_point) < 2.5 then
                                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer reached prev waypoint moving next")
                                explorer_go_next = 1
                            else
                                -- keep moving
                                -- pathfinder.request_move(explorer_point)
                                pathfinder.force_move_raw(explorer_point)
                            end
                        end
                        
                    end
                end
            else
                -- no explorer mode at helltide maiden boss
                -- reset pathfinder
                pathfinder.clear_stored_path()
            end
        end
    else
        -- Player is NOT in helltide zone
        console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player NOT IN helltide zone")
        helltide_maiden_arrivalstate = 0
        reset_helltide_maiden()
        -- teleport to next location
        tp_to_next()
    end
end)

-- use for any graphics rendering drawing
on_render(function()

    -- failsafe to not run script early or during loading screens
    local local_player = get_local_player()
    if not local_player then
        return
    end
    -- get current player position vec3 x,y,z
    local player_position = local_player:get_position()

    -- check if plugin is enabled/disabled via ingame menu
    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return
    end

    -- red (R,G,B,alpha) with 0 opacity
    local color_red = color.new(255, 0, 0, 255)
    local color_white = color.new(255, 255, 255, 255)
    local color_green = color.new(0, 255, 0, 255)
    local color_yellow = color.new(255, 255, 0, 255)
    local color_blue = color.new(0, 0, 255, 255)

    -- check if main_helltide_maiden_auto_plugin_show_task is enabled/disabled via ingame menu
    if menu.main_helltide_maiden_auto_plugin_show_task:get() then
    
        -- used for printing graphics 2D text ingame at top_left_position
        local txta_top_left_position = vec2.new(0, 15)
        local txtb_top_left_position = vec2.new(0, 30)
        local txtc_top_left_position = vec2.new(0, 45)
        local txtd_top_left_position = vec2.new(0, 60)
        local txte_top_left_position = vec2.new(0, 75)
        local txtf_top_left_position = vec2.new(0, 90)

        -- print 2D text at top_left_position using font-size 16 in color red
        if helltide_maiden_auto_task == helltide_maiden_auto_tasks.IN_TELEPORT then
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current task: " .. helltide_maiden_auto_task .. " ... ", txta_top_left_position, 13, color_red)
        else
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current task: " .. helltide_maiden_auto_task, txta_top_left_position, 13, color_red)
        end

        local explorer_threshold_rounded_no_decimals = round(explorer_threshold, 0)
        local explorer_thresholdvar_rounded_no_decimals = round(explorer_thresholdvar, 0)
        if run_explorer_mode == run_explorer_modes.OFF then
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current explorer mode: " .. run_explorer_mode, txtb_top_left_position, 13, color_white)
        else
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current explorer mode: " .. run_explorer_mode .. " Next Position: " .. explorer_threshold_rounded_no_decimals .. "s (added random " .. explorer_thresholdvar_rounded_no_decimals .. "s)", txtb_top_left_position, 13, color_white)
        end

        local distance_check_distance_rounded_no_decimals = round(distance_check_distance, 0)
        graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Distance checker: " .. distance_check_distance_rounded_no_decimals .. "u Is_Stuck: " .. distance_check_is_stuck .. " Stuck Counter: " .. distance_check_is_stuck_counter, txtc_top_left_position, 13, color_white)
        graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current helltide zone: " .. helltide_zone_name .. " Next teleporter zone: " .. helltide_tps_next_zone_name, txtd_top_left_position, 13, color_white)

        if insert_hearts == 1 then
            local seen_enemies_interval_rounded_no_decimals = round(menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider:get(), 0)
            local insert_hearts_waiter_elapsed_rounded_no_decimals = round(insert_hearts_waiter_elapsed, 0)
            local last_seen_enemies_elapsed_rounded_no_decimals = round(last_seen_enemies_elapsed, 0)
            local seen_enemies_is_enabled = 0
            if menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:get() then
                seen_enemies_is_enabled = 1
            end
            local insert_onlywithnpcs_enabled = 0
            if menu.main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs:get() then
                insert_onlywithnpcs_enabled = 1
            end
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Inserting hearts: Enabled (current playersinrange: ".. insert_only_with_npcs_playercount .. " insert when playersinrange: " .. insert_onlywithnpcs_enabled .. " insert afternoenmies: " .. seen_enemies_is_enabled .. " insert afterboss: " .. insert_hearts_afterboss .. ")", txte_top_left_position, 13, color_white)
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Inserting hearts: seen_enemies_interval: " .. seen_enemies_interval_rounded_no_decimals .. "s seen_enemies: " .. seen_enemies .." seen_elapsed: " .. last_seen_enemies_elapsed_rounded_no_decimals .. "s waiter_interval: " .. insert_hearts_waiter_interval .. "s start_waiter: " .. insert_hearts_waiter .." waiter_elapsed: " .. insert_hearts_waiter_elapsed_rounded_no_decimals .. "s", txtf_top_left_position, 13, color_white)
        else
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Inserting hearts: Disabled / Or currently no player in range", txte_top_left_position, 13, color_white)
        end

        -- shows helper text on first time arrival
        if helltide_maiden_auto_task == helltide_maiden_auto_tasks.ARRIVED then
            if not show_helper_text_time_up then
                show_helper_text_time_up = os.clock()
            end
            -- show helper_text only for 20 seconds
            if os.clock() - show_helper_text_time_up < 20.0 then
                local help_middle_left = vec2.new((get_screen_width() / 6), (get_screen_height() / 2))
                local help_middle_lefta = vec2.new((get_screen_width() / 6), (get_screen_height() / 2) + 40)
                local help_middle_leftb = vec2.new((get_screen_width() / 6), (get_screen_height() / 2) + 80)
                local help_middle_leftc = vec2.new((get_screen_width() / 6), (get_screen_height() / 2) + 120)
                -- print 2D text at top_left_position using font-size 16 in color red
                graphics.text_2d("Arrived at helltide maiden boss", help_middle_left, 40, color_red)
                graphics.text_2d("Everything is automatic", help_middle_lefta, 40, color_red)
             
            end
        end
    end
    
    -- draw exploring circle
    if menu.main_helltide_maiden_auto_plugin_show_explorer_circle:get() and run_explorer == 1 then
        if helltide_maiden_arrivalstate == 1 then
            if helltide_final_maidenpos then
                -- draw circle around helltide_final_maidenpos based on draw_explorer_circle_radius in color_white
                graphics.circle_3d(helltide_final_maidenpos, explorer_circle_radius, color_white)

                -- draw next explorer_point position in color_blue
                if explorer_point then
                    graphics.circle_3d(explorer_point, 2, color_blue)
                end

                -- draw all explorer_points positions in color_yellow
                if explorer_points then
                    local lengths = table_length(explorer_points)
                    -- for i, points in ipairs(explorer_points) do
                        -- only useful during debugging
                        -- graphics.circle_3d(points, 1, color_yellow)
                    -- end
                end
            end
        end
    end
end)

console.print("Lua Plugin - Helltide Maiden Auto - Version 1.3")
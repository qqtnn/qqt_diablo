
local menu_elements = {
    main_tree = tree_node:new(0),

    -- Game Objects Debug
    gameobjects_tree = tree_node:new(1),
    object_type_dropdown = combo_box:new(0, get_hash("debug_module_unique_id_gameobjects_debug_object_type_dropdown")),
    affiliation_dropdown = combo_box:new(0, get_hash("debug_module_unique_id_gameobjects_debug_affiliation_dropdown")),
    list_toggle = keybind:new(0x0A, true, get_hash("debug_module_unique_id_gameobjects_debug_list_toggle")),
    gameobjects_settings_tree = tree_node:new(2),
    distance_slider = slider_float:new(0.0, 50.0, 6.0, get_hash("debug_module_unique_id_gameobjects_debug_distance_slider")),
    distance_mode = combo_box:new(0, get_hash("debug_module_unique_id_gameobjects_debug_distance_mode_dropdown")),
    draw_health_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_gameobjects_debug_draw_health_checkbox")),
    draw_name_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_gameobjects_debug_draw_name_checkbox")),
    draw_direction_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_gameobjects_debug_draw_direction_checkbox")),
    draw_interactable_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_gameobjects_debug_draw_interactable_checkbox")),
    draw_dead_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_gameobjects_debug_draw_dead_checkbox")),
    name_filter_input = input_text:new(get_hash("debug_module_unique_id_gameobjects_name_filter_input")),

    show_future_position_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_gameobjects_debug_show_future_position_checkbox")),
    future_position_time_slider = slider_float:new(0.1, 2.0, 0.5, get_hash("debug_module_unique_id_gameobjects_debug_future_position_time_slider")),
    future_position_radius_slider = slider_float:new(0.2, 2.0, 0.5, get_hash("debug_module_unique_id_gameobjects_debug_future_position_radius_slider")),

    -- Local Player Debug
    local_player_debug_tree = tree_node:new(1),
    draw_map_info_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_localplayer_debug_draw_map_info_checkbox")),
    draw_spells_id_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_localplayer_debug_draw_spells_id_checkbox")),
    print_active_spells_id_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_localplayer_debug_print_active_spells_id_checkbox")),
    draw_circles_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_localplayer_debug_draw_circles_checkbox")),
    circles_settings_tree = tree_node:new(2),
    current_position_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_localplayer_debug_current_position_checkbox")),
    current_position_radius_slider = slider_float:new(1.0, 20.0, 3.0, get_hash("debug_module_unique_id_localplayer_debug_current_position_radius_slider")),
    future_position_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_localplayer_debug_future_position_checkbox")),
    future_position_radius_slider_2 = slider_float:new(0.2, 2.0, 0.5, get_hash("debug_module_unique_id_localplayer_debug_future_position_radius_slider")),
    future_position_time_slider_2 = slider_float:new(0.1, 2.0, 0.5, get_hash("debug_module_unique_id_localplayer_debug_future_position_time_slider")),

    miscellaneous_tree = tree_node:new(1),
    debug_quests_checkbox = checkbox:new(false, get_hash("debug_module_unique_id_debug_quests_checkbox")),

    cursor_position_info = tree_node:new(1),
    debug_cursor_pos_keybind = keybind:new(0x0A, false, get_hash("debug_module_unique_id_debug_cursor_pos_keybind")),

    enable_buffs_render = checkbox:new(false, get_hash("debug_module_enable_buffs_render_checkbox")),
}

-- Add item filter menu elements
menu_elements.filter_input = input_text:new(get_hash("item_filter_input"))
menu_elements.rarity_checkboxes = {}
local rarities = {"Normal", "Magic", "Magic2", "Rare", "Rare2", "Legendary", "Unique", "Set"}
for _, rarity in ipairs(rarities) do
    menu_elements.rarity_checkboxes[rarity] = checkbox:new(true, get_hash("rarity_checkbox_" .. rarity))
end

-- Function to render the item filter menu
local function render_item_filter_menu()
    if menu_elements.gameobjects_tree:push("Item Filters") then
        menu_elements.filter_input:render("Filter Text", "Enter text to filter items", true, "Goto Input", "Item Text Filter")

        for rarity, checkbox in pairs(menu_elements.rarity_checkboxes) do
            checkbox:render("Show " .. rarity:upper(), "Toggle to filter " .. rarity .. " items")
        end

        menu_elements.gameobjects_tree:pop()
    end
end

local function render_menu()
    if menu_elements.main_tree:push("Debug Tools") then

        if menu_elements.gameobjects_tree:push("Show Game Objects") then
            local object_types = {"Disabled", "Actors", "Particles", "Items"}
            menu_elements.object_type_dropdown:render("Object Types", object_types, "Choose object type to display")

            local affiliations = {"All", "Enemy", "Ally"}
            menu_elements.affiliation_dropdown:render("Affiliations", affiliations, "Select affiliation filter")

            menu_elements.list_toggle:render("Toggle Keybind", "Toggles The Current List");

            if menu_elements.object_type_dropdown:get() == 3 then
                render_item_filter_menu();
            end

            if menu_elements.gameobjects_settings_tree:push("Extra Settings") then
                menu_elements.distance_slider:render("Distance", "Set the max distance for object display", 2)
                local distance_options = {"Cursor", "Localplayer"}
                menu_elements.distance_mode:render("Distance Mode", distance_options, "")
                menu_elements.draw_health_checkbox:render("Draw Health", "Toggle drawing health bars")
                menu_elements.draw_name_checkbox:render("Draw Name", "Toggle drawing names")
                menu_elements.draw_direction_checkbox:render("Draw Direction", "Toggle drawing direction indicators")
                menu_elements.draw_interactable_checkbox:render("Draw Interactable", "Toggle drawing interactable state")
                menu_elements.draw_dead_checkbox:render("Draw Dead State", "Toggle drawing dead state of objects")

                menu_elements.show_future_position_checkbox:render("Show Future Position", "Toggle drawing future position of objects")
                if menu_elements.show_future_position_checkbox:get() then
                    menu_elements.future_position_time_slider:render("Time", "Set the time ahead for future position", 2)
                    menu_elements.future_position_radius_slider:render("Radius", "Set the radius for the future position circle", 2)
                end

                if menu_elements.gameobjects_settings_tree:push("Name Filter") then
                    menu_elements.name_filter_input:render("Filter Text", "Enter text to filter objects by name", true, "Go to Input", "Name Text Filter")
                    menu_elements.gameobjects_settings_tree:pop()
                end

                menu_elements.gameobjects_settings_tree:pop()
            end

            menu_elements.gameobjects_tree:pop()
        end

        if menu_elements.local_player_debug_tree:push("Local Player Debug") then
            menu_elements.draw_map_info_checkbox:render("Draw Map Info", "Toggle drawing map info")
            menu_elements.draw_spells_id_checkbox:render("Draw Spells ID", "Toggle drawing spell IDs")
            menu_elements.print_active_spells_id_checkbox:render("Print Active Spells ID", "Console Prints, Active Spell, spell ID")
            menu_elements.draw_circles_checkbox:render("Draw Circles", "Toggle drawing circles around the player")

            if menu_elements.draw_circles_checkbox:get() then
                if menu_elements.circles_settings_tree:push("Circles Settings") then
                    menu_elements.current_position_checkbox:render("Current Position", "Toggle drawing circle at current position")
                    if menu_elements.current_position_checkbox:get() then
                        menu_elements.current_position_radius_slider:render("Circle Radius", "Set the radius for the current position circle", 2)
                    end

                    menu_elements.future_position_checkbox:render("Future Position", "Toggle drawing circle at future position")
                    if menu_elements.future_position_checkbox:get() then
                        menu_elements.future_position_radius_slider_2:render("Future Radius", "Set the radius for the future position circle", 2)
                        menu_elements.future_position_time_slider_2:render("Time", "Set the time ahead for future position", 2)
                    end

                    menu_elements.circles_settings_tree:pop()
                end
            end

            menu_elements.local_player_debug_tree:pop()
        end


        if menu_elements.miscellaneous_tree:push("Miscellaneous") then

            menu_elements.debug_quests_checkbox:render("Print Quests Info", "Toggle to print quest information")

            menu_elements.debug_cursor_pos_keybind:render("Log Keybind", "Press to log cursor position")

            menu_elements.miscellaneous_tree:pop()
        end

        menu_elements.enable_buffs_render:render("Enable Buffs Render", "")

        menu_elements.main_tree:pop()
    end
end

-- Function to draw health information
local function draw_object_health(obj, position_2d)
    local current_health = obj:get_current_health()
    local max_health = obj:get_max_health()
    local health_info = string.format("%.2f / %.2f", current_health, max_health)
    graphics.text_2d(health_info, position_2d, 15, color_white(255))
end
-- Function to draw the name of the game object
local function draw_object_name(obj, position_2d)
    local name = obj:get_skin_name()  -- Or any other appropriate method to get the object's name
    graphics.text_2d(name, position_2d, 12, color_white(255))  -- White text for name
end

local function vector_add(vec1, vec2)
    return vec3:new(vec1:x() + vec2:x(), vec1:y() + vec2:y(), vec1:z() + vec2:z())
end

-- Function to filter and visualize items on the floor
local function visualize_filtered_items(obj)

    if not obj:is_item() then
        return;
    end

    local item_data = obj:get_item_info(obj:get_id())
    -- console.print(item_data:get_name())

    local filter_text = menu_elements.filter_input:get()
    local lower_filter_text = string.lower(filter_text)

    local item_name = item_data:get_name()
    local lower_item_name = string.lower(item_name)
    local item_rarity = item_data:get_rarity()

    local rarity_allowed = menu_elements.rarity_checkboxes[rarities[item_rarity + 1]]:get()
    local name_matches = lower_filter_text == "" or string.find(lower_item_name, lower_filter_text)

    if rarity_allowed and name_matches then
        local item_position = obj:get_position()
        graphics.circle_3d(item_position, 0.20, color_yellow(255), 2.0)
    end
end

-- Function to draw the direction of the game object
local function draw_object_direction(obj, position_2d)
    local direction = obj:get_direction()
    local position = obj:get_position()

    -- Add position and direction
    local new_position = vector_add(position, direction)

    -- Convert new_position to 2D and draw the line
    local end_point_2d = graphics.w2s(new_position)
    if end_point_2d then
        graphics.line(position_2d, end_point_2d, color_white(255), 1)
    end
end

local function draw_object_future_position(obj, player_position, max_distance)
    local show_future_position = menu_elements.show_future_position_checkbox:get()
    if not show_future_position then
        return
    end

    if obj:get_current_speed() < 0.5 then
        return;
    end

    local future_time = menu_elements.future_position_time_slider:get()
    local future_radius = menu_elements.future_position_radius_slider:get()
    local future_position = prediction.get_future_unit_position(obj, future_time)

    if future_position then
        local distance_to_object_sqr = future_position:squared_dist_to_ignore_z(player_position)
        if distance_to_object_sqr <= (max_distance * max_distance) then
            graphics.circle_3d(future_position, future_radius, color_white(255))
        end
    end
end

-- Function to get a list of game objects based on type and affiliation
local function get_gameobjects_list(type, affiliation)
    local toggle_key = menu_elements.list_toggle:get_key();
    local toggle_state = menu_elements.list_toggle:get_state();

    local all_objects = {}
    local filtered_objects = {}

    if toggle_key ~= 0x0A and toggle_state ~= 1 then
        return filtered_objects;
    end

    -- console.print("type ", type)
    -- console.print("affiliation ", affiliation)

    -- Fetch all actors, particles, and items
    if type == 1 then  -- Actors
        all_objects = actors_manager.get_all_actors()
    elseif type == 2 then  -- Particles
        all_objects = actors_manager.get_all_particles()
    elseif type == 3 then  -- Items
        all_objects = actors_manager.get_all_items()
    end

    if affiliation == 0 then  -- All
        filtered_objects = all_objects;
    else

        -- Filter objects based on affiliation
        for _, obj in ipairs(all_objects) do
            if affiliation == 1 and obj:is_enemy() then  -- Enemy
                table.insert(filtered_objects, obj)
            elseif affiliation == 2 and not obj:is_enemy() then  -- Ally
                table.insert(filtered_objects, obj)
            end
        end
    end

    return filtered_objects
end

local function render_player_circles()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    if not menu_elements.draw_circles_checkbox:get() then
        return;
    end

    local player_position = local_player:get_position()
    local draw_current_position = menu_elements.current_position_checkbox:get()
    local draw_future_position = menu_elements.future_position_checkbox:get()

    -- Draw current position circle
    if draw_current_position then
        local current_radius = menu_elements.current_position_radius_slider:get()
        graphics.circle_3d(player_position, current_radius, color_white(255))
    end

    -- Draw future position circle
    if draw_future_position then
        local future_radius = menu_elements.future_position_radius_slider:get()
        local future_time = menu_elements.future_position_time_slider_2:get()
        local future_position = prediction.get_future_unit_position(local_player, future_time)

        if future_position then
            graphics.circle_3d(future_position, future_radius, color_white(255))
        end
    end
end

local function draw_map_info()
    if menu_elements.draw_map_info_checkbox:get() then
        local world_instance = world.get_current_world()
        if world_instance then
            local world_name = world_instance:get_name()
            local zone_name = world_instance:get_current_zone_name()
            local world_id = world_instance:get_world_id()

            graphics.text_2d("World Name: " .. world_name, vec2:new(10, 10), 20, color_white(255))
            graphics.text_2d("Current Zone: " .. zone_name, vec2:new(10, 30), 20, color_white(255))
            graphics.text_2d("World ID: " .. tostring(world_id), vec2:new(10, 50), 20, color_white(255))
        end
    end
end

local function draw_spells_id()
    if menu_elements.draw_spells_id_checkbox:get() then
        local spell_ids = get_equipped_spell_ids() -- Returns a table of 6 spell IDs

        for i, spell_id in ipairs(spell_ids) do
            local spell_name = "Unknown Spell"

            if spell_id > 1 then
                spell_name = get_name_for_spell(spell_id);
            end

            local spell_ready = utility.is_spell_ready(spell_id) and "Ready" or "Not Ready"
            local spell_info = string.format("Spell Slot %d: %s - %s (%s)", i, spell_name, tostring(spell_id), spell_ready)
            graphics.text_2d(spell_info, vec2:new(10, 90 + 20 * i), 20, color_white(255))
        end
    end
end

local function draw_object_information(obj, position_2d, player_position, max_distance)
    -- Drawing Health
    if menu_elements.draw_health_checkbox:get() then
        draw_object_health(obj, position_2d)
        position_2d.y = position_2d.y + 15
    end

    -- Drawing Name
    if menu_elements.draw_name_checkbox:get() then
        draw_object_name(obj, position_2d)
        position_2d.y = position_2d.y + 15
    end

    -- Drawing Direction
    if menu_elements.draw_direction_checkbox:get() then
        draw_object_direction(obj, position_2d)
        position_2d.y = position_2d.y + 15
    end

    -- Drawing Future Position
    if menu_elements.show_future_position_checkbox:get() then
        draw_object_future_position(obj, player_position, max_distance)
        position_2d.y = position_2d.y + 15
    end

     -- Drawing Interactable State
     if menu_elements.draw_interactable_checkbox:get() then
        local is_interactable = not obj:can_not_interact();

        if is_interactable then
            graphics.text_2d("Interactable", position_2d, 12, color_green(255))
        else
            graphics.text_2d("Not Interactable", position_2d, 12, color_red(255))
        end

        position_2d.y = position_2d.y + 15
    end

     -- Drawing Dead State
     if menu_elements.draw_dead_checkbox:get() then
        local is_dead = obj:is_dead() and "Dead" or "Alive"
        graphics.text_2d(is_dead, position_2d, 12, color_white(255))
        position_2d.y = position_2d.y + 15
    end
end

local function render_buff()
    if not menu_elements.enable_buffs_render:get() then
        return
    end
    local local_player = get_local_player()
    if not local_player then return end

    local player_position = get_player_position()

    -- draw Buffs Tracker
    local buffs = local_player:get_buffs();
    if not buffs then
        return;
    end

    -- enemy portion
    local enemies_list = actors_manager.get_enemy_npcs();
    local obj_top_left_position = vec2.new(0, 33)
    
    graphics.text_2d("Enemies Spell ID / Buffs Tracker", obj_top_left_position, 13, color_red(255))

    local cursor_position = get_cursor_position()
    table.sort( enemies_list, function(a, b)
        return a:get_position():squared_dist_to_ignore_z(cursor_position) <
            b:get_position():squared_dist_to_ignore_z(cursor_position)
    end);

    for i, obj in ipairs(enemies_list) do
        local obj_position = obj:get_position();
        local obj_buffs = obj:get_buffs();

        for i, obj_buff in ipairs(obj_buffs) do
            local obj_buff_name = obj_buff:name()
            local obj_buff_id = tostring(obj_buff.name_hash)
            local obj_buff_text = obj_buff_id .. " : " .. obj_buff_name
            obj_top_left_position.y = obj_top_left_position.y + 15
            graphics.text_2d(obj_buff_text, obj_top_left_position, 13, color_white(255))
        end
        
        break;
    end

    local top_left_position = obj_top_left_position
    top_left_position.y = top_left_position.y + 20
    graphics.text_2d("Player Spell ID / Buffs Tracker", top_left_position, 13, color_blue(255))

    for i, buff in ipairs(buffs) do
        local buff_name = buff:name()
        local buff_end_time = buff:get_end_time()
        local buff_remaining = buff:get_remaining_time()
        local buff_stacks = buff.stacks
        local buff_end_tick = buff.stacks
        local buff_id = tostring(buff.name_hash)
        local buff_text = buff_id .. " : " .. buff_name .. " | stacks: " .. buff_stacks .. " | end_tick: " .. string.format("%.1f", buff_end_tick) .. " | end_time: " .. string.format("%.1f", buff_end_time) .. " | remaining: " .. string.format("%.1f", buff_remaining) 
        top_left_position.y = top_left_position.y + 15
        graphics.text_2d(buff_text, top_left_position, 13, color_white(255))
    end

    

end

local function render_visuals()
    local local_player = get_local_player()
    if not local_player then return end

    render_buff()
    local show_gameobjects = menu_elements.object_type_dropdown:get()
    local affiliation = menu_elements.affiliation_dropdown:get()
    local max_distance = menu_elements.distance_slider:get()
    local distance_mode = menu_elements.distance_mode:get()
    local player_position = get_player_position()
    if distance_mode == 0 then
        -- cursor
        player_position = get_cursor_position()
    end
    local name_filter_text = string.lower(menu_elements.name_filter_input:get()) -- Retrieve and lowercase the filter text

    if show_gameobjects > 0 then
        local game_objects = get_gameobjects_list(show_gameobjects, affiliation)
        local processed_positions = {}

        for _, obj in ipairs(game_objects) do
            local object_name = string.lower(obj:get_skin_name()) -- Retrieve and lowercase the object name
            local object_position = obj:get_position()
            local distance_to_object_sqr = object_position:squared_dist_to_ignore_z(player_position)

            if distance_to_object_sqr <= (max_distance * max_distance) and not obj:can_not_interact() and (name_filter_text == "" or string.find(object_name, name_filter_text)) then
                local object_position_2d = graphics.w2s(object_position)
                if not object_position_2d then goto continue end
                local info_position = vec2:new(object_position_2d.x, object_position_2d.y)

                -- Check for close proximity with other objects
                local vertical_offset = 0
                for _, pos in ipairs(processed_positions) do
                    local distance_2d_sqr = object_position_2d:distance_squared(pos.position);
                    if distance_2d_sqr < (20.0  * 20.0) then
                        vertical_offset = vertical_offset + 25
                    end
                end
                table.insert(processed_positions, {object = obj, position = object_position_2d})

                -- Drawing information with adjusted position
                info_position.y = info_position.y + vertical_offset
                draw_object_information(obj, info_position, player_position, max_distance)

                ::continue::
            end
        end
    end

    render_player_circles()
    draw_map_info()
    draw_spells_id()
end

local function on_updates()
    local local_player = get_local_player()
    if not local_player then return end

    -- local equipped_items_list = local_player:get_equipped_items();
    -- for _, item in ipairs(equipped_items_list) do
    --     local durability = item:get_durability()
    --     console.print("Item Name: " .. item:get_display_name())
    --     console.print("Durability: " .. tostring(durability))
    -- end

    local active_spell_id = local_player:get_active_spell_id();
    if active_spell_id > 1 and menu_elements.print_active_spells_id_checkbox:get() then
        console.print_full(0.0, 1.0, "active_spell_id: ", active_spell_id);
    end

    if menu_elements.debug_quests_checkbox:get() then
        local quests = get_quests()
        for _, quest in ipairs(quests) do
            local quest_id = quest:get_id()
            local quest_name = quest:get_name()
            console.print("Quest Name: " .. quest_name)
            console.print("Quest ID: " .. tostring(quest_id))
        end
    end

    if menu_elements.debug_cursor_pos_keybind:get_state() == 1 then
        local cursor_pos = get_cursor_position()
        console.print("Cursor Position: ")
        console.print("vec3:new(" .. cursor_pos:x() .. ", " .. cursor_pos:y() .. ", " .. cursor_pos:z() .. ")")

        local is_wall_collision = prediction.is_wall_collision(get_player_position(), cursor_pos, 1.0)
        -- console.print("Is Wall Collision: " .. tostring(is_wall_collision))

        -- console.print("get_health_potion_max_count: " .. tostring(get_local_player():get_health_potion_max_count()))
        -- console.print("get_health_potion_count: " .. tostring(get_local_player():get_health_potion_count()))
        -- console.print("get_health_potion_tier: " .. tostring(get_local_player():get_health_potion_tier()))

    end
end

-- callbacks
on_render_menu(render_menu)
on_render(render_visuals)
on_update(on_updates)

console.print("Lua Plugin - Debug Tools - Version 1.3");

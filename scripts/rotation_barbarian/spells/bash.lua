local my_utility = require("my_utility/my_utility")

local menu_elements_bash_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "bash_base_main_bool")),
    use_as_filler_only  = checkbox:new(false, get_hash(my_utility.plugin_label .. "use_as_filler_only_bashbase_2")),
    spell_range       = slider_float:new(0.5, 3.0, 1.60, get_hash(my_utility.plugin_label .. "bash_spell_range_2")),
    max_angle       = slider_int:new(45, 180, 180, get_hash(my_utility.plugin_label .. "bash_spell_max_angle_2"))
}

local function menu()
    
    if menu_elements_bash_base.tree_tab:push("Bash")then
        menu_elements_bash_base.main_boolean:render("Enable Spell", "")

        if menu_elements_bash_base.main_boolean:get() then
            menu_elements_bash_base.use_as_filler_only:render("Filler Only", "Prevent casting with a lot of fury")
            menu_elements_bash_base.spell_range:render("Spell Range", "", 2)
            menu_elements_bash_base.max_angle:render("Max Angle", "")
         end
 
         menu_elements_bash_base.tree_tab:pop()
    end
end

local spell_id_bash = 200765;


local next_time_allowed_cast = 0.0;
local function logics(entity_list)
    
    local spell_data_bash = spell_data:new(
    menu_elements_bash_base.spell_range:get(),                        -- radius
    menu_elements_bash_base.spell_range:get(),                        -- range
    0.15,                        -- cast_delay
    -- 0.000,                        -- cast_delay
    5.0,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_bash,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)

    local menu_boolean = menu_elements_bash_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_bash);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();

    local is_filler_enabled = menu_elements_bash_base.use_as_filler_only:get();  
    if is_filler_enabled then
        local current_resource_ws = player_local:get_primary_resource_current();
        local max_resource_ws = player_local:get_primary_resource_max();
        local fury_perc = current_resource_ws / max_resource_ws 
        local low_in_fury = fury_perc < 0.5

        if not low_in_fury then
            return false;
        end
    end;
    
    local spell_range = menu_elements_bash_base.spell_range:get()
    local player_position = get_player_position();
    local cursor_position = get_cursor_position();

    local is_auto_play_active = auto_play.is_active();
    
    local filtered_entities = {}
    for _, target in ipairs(entity_list) do
        local target_position = target:get_position()
        local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
        if distance_sqr <= (spell_range * spell_range) then
            local angle = target_position:get_angle(cursor_position, player_position)
            local is_very_close = distance_sqr <= (0.66 * 0.66)
            local cursor_dist_sqr = cursor_position:squared_dist_to_ignore_z(target_position)
            local is_cursor_far = cursor_dist_sqr > (5.70 * 5.70)
            if is_cursor_far and not is_very_close and angle > menu_elements_bash_base.max_angle:get() then
                if is_auto_play_active then
                    table.insert(filtered_entities, {entity = target, angle = angle})
                end
            else
                table.insert(filtered_entities, {entity = target, angle = angle})
            end
        end
    end

    if is_auto_play_active then
        
    else

        table.sort(filtered_entities, function(a, b) return a.angle < b.angle end)
    end
    
    local target = filtered_entities[1] and filtered_entities[1].entity

    if target then
        if cast_spell.target(target, spell_data_bash, false) then
            local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.15;
            console.print("Casted Bash")
            return true
        end
    end
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
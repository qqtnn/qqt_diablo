-- all in one (aio) target selector data
-- returns table:

-- bool, is_valid -- true once finds 1 valid target inside the list regardless of type
-- game_object, closest unit
-- game_object, lowest current health unit
-- game_object, highest current health unit
-- game_object, lowest max health unit
-- game_object, highest max health unit

-- bool, has_elite -- true once finds 1 elite inside the list
-- game_object, closest elite
-- game_object, lowest current health elite
-- game_object, highest current health elite
-- game_object, lowest max health elite
-- game_object, highest max health elite

-- bool, has_champion -- true once finds 1 champion inside the list
-- game_object, closest champion
-- game_object, lowest current health champion
-- game_object, highest current health champion
-- game_object, lowest max health champion
-- game_object, highest max health champion

-- bool, has_boss -- true once finds 1 boss inside the list
-- game_object, closest boss
-- game_object, lowest current health boss
-- game_object, highest current health boss
-- game_object, lowest max health boss
-- game_object, highest max health boss

local function get_target_selector_data(source, list)
    local is_valid = false;

    local possible_targets_list = list;
    if #possible_targets_list == 0 then
        return
        { 
            is_valid = is_valid;
        }
    end;

    local closest_unit = {};
    local closest_unit_distance = math.huge;

    local lowest_current_health_unit = {};
    local lowest_current_health_unit_health = math.huge;

    local highest_current_health_unit = {};
    local highest_current_health_unit_health = 0.0;

    local lowest_max_health_unit = {};
    local lowest_max_health_unit_health = math.huge;

    local highest_max_health_unit = {};
    local highest_max_health_unit_health = 0.0;

    local has_elite = false;
    local closest_elite = {};
    local closest_elite_distance = math.huge;

    local lowest_current_health_elite = {};
    local lowest_current_health_elite_health = math.huge;

    local highest_current_health_elite = {};
    local highest_current_health_elite_health = 0.0;

    local lowest_max_health_elite = {};
    local lowest_max_health_elite_health = math.huge;

    local highest_max_health_elite = {};
    local highest_max_health_elite_health = 0.0;

    local has_champion = false;
    local closest_champion = {};
    local closest_champion_distance = math.huge;

    local lowest_current_health_champion = {};
    local lowest_current_health_champion_health = math.huge;

    local highest_current_health_champion = {};
    local highest_current_health_champion_health = 0.0;

    local lowest_max_health_champion = {};
    local lowest_max_health_champion_health = math.huge;

    local highest_max_health_champion = {};
    local highest_max_health_champion_health = 0.0;

    local has_boss = false;
    local closest_boss = {};
    local closest_boss_distance = math.huge;

    local lowest_current_health_boss = {};
    local lowest_current_health_boss_health = math.huge;

    local highest_current_health_boss = {};
    local highest_current_health_boss_health = 0.0;

    local lowest_max_health_boss = {};
    local lowest_max_health_boss_health = math.huge;

    local highest_max_health_boss = {};
    local highest_max_health_boss_health = 0.0;

    for _, unit in ipairs(possible_targets_list) do
        local unit_position = unit:get_position()
        local distance_sqr = unit_position:squared_dist_to_ignore_z(source)
        local cursor_pos = get_cursor_position()
        local player_position = get_player_position()
        local max_health = unit:get_max_health()
        local current_health = unit:get_current_health()

        -- update units data
        if unit_position:dist_to(cursor_pos) <= 1 then
            closest_unit = unit;
            closest_unit_distance = distance_sqr;
        elseif distance_sqr < closest_unit_distance then
            closest_unit = unit;
            closest_unit_distance = distance_sqr;
            is_valid = true;
        elseif unit_position:dist_to(cursor_pos) < 2 then
            closest_unit = unit;
            closest_unit_distance = distance_sqr;
        end

        if current_health < lowest_current_health_unit_health then
            lowest_current_health_unit = unit;
            lowest_current_health_unit_health = current_health;
        end

        if current_health > highest_current_health_unit_health then
            highest_current_health_unit = unit;
            highest_current_health_unit_health = current_health;
        end

        if max_health < lowest_max_health_unit_health then
            lowest_max_health_unit = unit;
            lowest_max_health_unit_health = max_health;
        end

        if max_health > highest_max_health_unit_health then
            highest_max_health_unit = unit;
            highest_max_health_unit_health = max_health;
        end

        -- update elites data
        local is_unit_elite = unit:is_elite();
        if is_unit_elite then
            has_elite = true;
            if distance_sqr < closest_elite_distance then
                closest_elite = unit;
                closest_elite_distance = distance_sqr;
            end

            if current_health < lowest_current_health_elite_health then
                lowest_current_health_elite = unit;
                lowest_current_health_elite_health = current_health;
            end

            if current_health > highest_current_health_elite_health then
                highest_current_health_elite = unit;
                highest_current_health_elite_health = current_health;
            end

            if max_health < lowest_max_health_elite_health then
                lowest_max_health_elite = unit;
                lowest_max_health_elite_health = max_health;
            end

            if max_health > highest_max_health_elite_health then
                highest_max_health_elite = unit;
                highest_max_health_elite_health = max_health;
            end
        end

        -- update champions data
        local is_unit_champion = unit:is_champion()
        if is_unit_champion then
            has_champion = true
            if distance_sqr < closest_champion_distance then
                closest_champion = unit;
                closest_champion_distance = distance_sqr;
            end

            if current_health < lowest_current_health_champion_health then
                lowest_current_health_champion = unit;
                lowest_current_health_champion_health = current_health;
            end

            if current_health > highest_current_health_champion_health then
                highest_current_health_champion = unit;
                highest_current_health_champion_health = current_health;
            end

            if max_health < lowest_max_health_champion_health then
                lowest_max_health_champion = unit;
                lowest_max_health_champion_health = max_health;
            end

            if max_health > highest_max_health_champion_health then
                highest_max_health_champion = unit;
                highest_max_health_champion_health = max_health;
            end
        end

        -- update bosses data
        local is_unit_boss = unit:is_boss();
        if is_unit_boss then
            has_boss = true;
            if distance_sqr < closest_boss_distance then
                closest_boss = unit;
                closest_boss_distance = distance_sqr;
            end

            if current_health < lowest_current_health_boss_health then
                lowest_current_health_boss = unit;
                lowest_current_health_boss_health = current_health;
            end

            if current_health > highest_current_health_boss_health then
                highest_current_health_boss = unit;
                highest_current_health_boss_health = current_health;
            end

            if max_health < lowest_max_health_boss_health then
                lowest_max_health_boss = unit;
                lowest_max_health_boss_health = max_health;
            end

            if max_health > highest_max_health_boss_health then
                highest_max_health_boss = unit;
                highest_max_health_boss_health = max_health;
            end
        end
    end

    return 
    {
        is_valid = is_valid,

        closest_unit = closest_unit,
        lowest_current_health_unit = lowest_current_health_unit,
        highest_current_health_unit = highest_current_health_unit,
        lowest_max_health_unit = lowest_max_health_unit,
        highest_max_health_unit = highest_max_health_unit,

        has_elite = has_elite,
        closest_elite = closest_elite,
        lowest_current_health_elite = lowest_current_health_elite,
        highest_current_health_elite = highest_current_health_elite,
        lowest_max_health_elite = lowest_max_health_elite,
        highest_max_health_elite = highest_max_health_elite,

        has_champion = has_champion,
        closest_champion = closest_champion,
        lowest_current_health_champion = lowest_current_health_champion,
        highest_current_health_champion = highest_current_health_champion,
        lowest_max_health_champion = lowest_max_health_champion,
        highest_max_health_champion = highest_max_health_champion,

        has_boss = has_boss,
        closest_boss = closest_boss,
        lowest_current_health_boss = lowest_current_health_boss,
        highest_current_health_boss = highest_current_health_boss,
        lowest_max_health_boss = lowest_max_health_boss,
        highest_max_health_boss = highest_max_health_boss,

        list = possible_targets_list
    }

end

-- get target list with few parameters
-- collision parameter table: {is_enabled(bool), width(float)};
-- floor parameter table: {is_enabled(bool), height(float)};
-- angle parameter table: {is_enabled(bool), max_angle(float)};
local function get_target_list(source, range, collision_table, floor_table, angle_table)

    local new_list = {}
    local possible_targets_list = target_selector.get_near_target_list(source, range);
    
    for _, unit in ipairs(possible_targets_list) do

        if collision_table.is_enabled then
            local is_invalid = prediction.is_wall_collision(source, unit:get_position(), collision_table.width);
            if is_invalid then
                goto continue;
            end
        end

        local unit_position = unit:get_position()

        if floor_table.is_enabled then
            local x_difference = math.abs(source.x() - unit_position.x())
            local is_other_floor = x_difference > floor_table.height
        
            if is_other_floor then
                goto continue
            end
        end

        if angle_table.is_enabled then
            local cursor_position = cursor_pos();
            local angle = unit_position.angle(cursor_position, source);
            local is_outside_angle = angle > floor_table.max_angle
        
            if is_outside_angle then
                goto continue
            end
        end

        table.insert(new_list, unit);
        ::continue::
    end

    return new_list;
end

-- return table:
-- hits_amount(int)
-- score(float)
-- main_target(gameobject)
-- victim_list(table game_object)
local function get_most_hits_rectangle(source, lenght, width)

    local data = target_selector.get_most_hits_target_rectangle_area_heavy(source, lenght, width);

    local is_valid = false;
    local hits_amount = data.n_hits;
    if hits_amount < 1 then
        return
        {
            is_valid = is_valid;
        }
    end

    local main_target = data.main_target;
    is_valid = hits_amount > 0 and main_target;
    return
    {
        is_valid = is_valid,
        hits_amount = hits_amount,
        main_target = main_target,
        victim_list = data.victim_list,
        score = data.score
    }
end


-- return table:
-- is_valid(bool)
-- hits_amount(int)
-- score(float)
-- main_target(gameobject)
-- victim_list(table game_object)
local function get_most_hits_circular(source, distance, radius)

    local data = target_selector.get_most_hits_target_circular_area_heavy(source, distance, radius);

    local is_valid = false;
    local hits_amount = data.n_hits;
    if hits_amount < 1 then
        return
        {
            is_valid = is_valid;
        }
    end

    local main_target = data.main_target;
    is_valid = hits_amount > 0 and main_target;
    return
    {
        is_valid = is_valid,
        hits_amount = hits_amount,
        main_target = main_target,
        victim_list = data.victim_list,
        score = data.score
    }
end

local function is_valid_area_spell_static(area_table, min_hits)
    if not area_table.is_valid then
        return false;
    end
    
    return area_table.hits_amount >= min_hits;
end

local function is_valid_area_spell_smart(area_table, min_hits)
    if not area_table.is_valid then
        return false;
    end

    if is_valid_area_spell_static(area_table, min_hits) then
        return true;
    end

    if area_table.score >= min_hits then
        return true;
    end

    for _, victim in ipairs(area_table.victim_list) do
        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            return true;
        end
    end
    
    return false;
end

local function get_area_percentage(area_table, entity_list)
    if not area_table.is_valid then
        return 0.0
    end
    
    local entity_list_size = #entity_list;
    local hits_amount = area_table.hits_amount;
    local percentage = hits_amount / entity_list_size;
    return percentage
end

local function is_valid_area_spell_percentage(area_table, entity_list, min_percentage)
    if not area_table.is_valid then
        return false;
    end
    
    local percentage = get_area_percentage(area_table, entity_list)
    if percentage >= min_percentage then
        return true;
    end
end


local function is_valid_area_spell_aio(area_table, min_hits, entity_list, min_percentage)
    if not area_table.is_valid then
        return false;
    end
  
    if is_valid_area_spell_smart(area_table, min_hits) then
        return true;
    end

    if is_valid_area_spell_percentage(area_table, entity_list, min_percentage) then
        return true;
    end
    
    return false;
end

return
{
    get_target_list = get_target_list,
    get_target_selector_data = get_target_selector_data,

    get_most_hits_rectangle = get_most_hits_rectangle,
    get_most_hits_circular = get_most_hits_circular,

    is_valid_area_spell_static = is_valid_area_spell_static,
    is_valid_area_spell_smart = is_valid_area_spell_smart,
    is_valid_area_spell_percentage = is_valid_area_spell_percentage,
    is_valid_area_spell_aio = is_valid_area_spell_aio,
}
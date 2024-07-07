local my_utility = require("my_utility/my_utility")

local menu_elements_fire_bolt =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "test_fire_bolt_main_boolean")),
    jmr_logic        = checkbox:new(true, get_hash(my_utility.plugin_label .. "test_fire_bolt_jmr_logic_boolean")),
    only_elite_or_boss        = checkbox:new(true, get_hash(my_utility.plugin_label .. "test_fire_bolt_only_elite_or_boss_boolean")),
}

local function menu()
    
    if menu_elements_fire_bolt.tree_tab:push("Fire Bolt")then
        menu_elements_fire_bolt.main_boolean:render("Enable Spell", "")
        menu_elements_fire_bolt.jmr_logic:render("Enable JMR Logic", "")
        menu_elements_fire_bolt.only_elite_or_boss:render("Only Elite or Boss", "")
 
        menu_elements_fire_bolt.tree_tab:pop()
    end
end

local spell_id_fire_bolt = 153249;

local fire_bolt_spell_data = spell_data:new(
    0.7,                        -- radius
    20.0,                        -- range
    0.0,                        -- cast_delay
    4.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_fire_bolt,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_fire_bolt.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_fire_bolt);

    if not is_logic_allowed then
        return false;
    end;

    if  menu_elements_fire_bolt.only_elite_or_boss:get() then
        if not target:is_boss() and not target:is_elite() and not target:is_champion() then
            return false;
        end
    end
    
    local player_position = get_player_position();
    local target_position = target:get_position();
    local is_collision = prediction.is_wall_collision(player_position, target_position, 0.2)
    if is_collision then
        return false
    end

    if cast_spell.target(target, fire_bolt_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time;

        console.print("Sorcerer Plugin, Casted Fire Bolt");
        return true;
    end;
            
    return false;
end


return
{
    menu = menu,
    logics = logics,
    menu_elements_fire_bolt = menu_elements_fire_bolt,
}
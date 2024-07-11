local my_utility = require("my_utility/my_utility")

local fireball_menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "fire_ball_main_boolean")),
}

local function menu()
    
    if fireball_menu_elements.tree_tab:push("Fireball")then
        fireball_menu_elements.main_boolean:render("Enable Spell", "")
 
        fireball_menu_elements.tree_tab:pop()
    end
end

local spell_id_fireball = 165023;

local fireball_spell_data = spell_data:new(
    0.7,                        -- radius
    12.0,                        -- range
    1.6,                        -- cast_delay
    2.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_fireball,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = fireball_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_fireball);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();
    local current_mana = player_local:get_primary_resource_current()
    local max_mana = player_local:get_primary_resource_max()
    local mana_percentage = current_mana / max_mana

    if mana_percentage < 0.8 then
        --console.print(mana_percentage)
        return false
    end  

    -- if flameshield endtime is less than 4, return false
    local flameshield_id = 167341
    local buffs = player_local:get_buffs()
    local flameshieldbuff = nil

    local function flameshield()
        for _, buff in ipairs(buffs) do
            if buff.name_hash == flameshield_id then
                return buff:get_end_time()
            end
        end
        return nil
    end

    flameshieldbuff = flameshield()

    if flameshieldbuff then
        local end_time = flameshieldbuff
        local current_time = get_time_since_inject()
        if (end_time - current_time) > 4 then
            return true
        end
    end

    -- 153249 : Sorcerer_FireBolt
    -- if target does not have Sorcerer_FireBolt, return false
    local target_buffs = target:get_buffs()
    local function has_firebolt()
        for _, buff in ipairs(target_buffs) do
            if buff.name_hash == 153249 then
                return true
            end
        end
    end

    if has_firebolt and cast_spell.target(target, fireball_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time;

        console.print("Sorcerer Plugin, Casted Fireball");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
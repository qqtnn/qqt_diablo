local my_utility = require("my_utility/my_utility")

local storm_strike_base_menu =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "storm_strike_main")),
    use_as_filler_only  = checkbox:new(true, get_hash(my_utility.plugin_label .. "storm_strike_filler"))
}

local function menu()
    if storm_strike_base_menu.tree_tab:push("Storm Strike") then
        storm_strike_base_menu.main_boolean:render("Enable Spell", "")
 
         if storm_strike_base_menu.main_boolean:get() then
            storm_strike_base_menu.use_as_filler_only:render("Filler Only", "Prevent casting with a lot of spirit")
         end

         storm_strike_base_menu.tree_tab:pop()
        end
    end

local spell_id_storm_strike = 309320;

local storm_spell_data = spell_data:new(
    1.0,                        -- radius
    1.0,                       -- range
    0.7,                       -- cast_delay
    1.2,                       -- projectile_speed
    true,                      -- has_collision
    spell_id_storm_strike,        -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = storm_strike_base_menu.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_storm_strike);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local is_filler_enabled = storm_strike_base_menu.use_as_filler_only:get();  
    if is_filler_enabled then
        local current_resource_ws = player_local:get_primary_resource_current();
        local max_resource_ws = player_local:get_primary_resource_max();
        local spirit_perc = current_resource_ws / max_resource_ws 
        local low_in_spirit = spirit_perc < 0.4
        -- console.print("spirit % " .. spirit_perc)
    
        if not low_in_spirit then
            return false;
        end
    end;
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, storm_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.3;

        console.print("Druid Plugin, Casted Storm Strike");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
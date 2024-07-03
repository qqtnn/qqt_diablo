local my_utility = require("my_utility/my_utility")

local wind_shear_menu_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "_wind_shear_main_boolean_base")),
    use_as_filler_only  = checkbox:new(true, get_hash(my_utility.plugin_label .. "_wind_shear_use_as_filler_only_base"))
}

local function menu()
    if wind_shear_menu_base.tree_tab:push("Wind Shear") then
        wind_shear_menu_base.main_boolean:render("Enable Spell", "")
 
         if wind_shear_menu_base.main_boolean:get() then
            wind_shear_menu_base.use_as_filler_only:render("Filler Only", "Prevent casting with a lot of spirit")
         end

         wind_shear_menu_base.tree_tab:pop()
        end
    end

local spell_id_wind_shear = 356587;

local wind_shear_spell_data = spell_data:new(
    0.5,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    4.0,                       -- projectile_speed
    false,                      -- has_collision
    spell_id_wind_shear,        -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = wind_shear_menu_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_wind_shear);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local is_filler_enabled = wind_shear_menu_base.use_as_filler_only:get();  
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

    if cast_spell.target(target, wind_shear_spell_data, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;

        console.print("Druid Plugin, Casted Wind Shear");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
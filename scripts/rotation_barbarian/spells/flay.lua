local my_utility = require("my_utility/my_utility")

local menu_elements_flay_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "flay_base_main_bool")),
    use_as_filler_only  = checkbox:new(true, get_hash(my_utility.plugin_label .. "use_as_filler_only_flay")),
}

local function menu()
    
    if menu_elements_flay_base.tree_tab:push("Flay")then
        menu_elements_flay_base.main_boolean:render("Enable Spell", "")

        if menu_elements_flay_base.main_boolean:get() then
            menu_elements_flay_base.use_as_filler_only:render("Filler Only", "Prevent casting with a lot of fury")
         end
 
         menu_elements_flay_base.tree_tab:pop()
    end
end

local spell_id_frenzy = 210431;

local spell_data_flay = spell_data:new(
    0.2,                        -- radius
    0.2,                        -- range
    0.2,                        -- cast_delay
    0.4,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_frenzy,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_flay_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_frenzy);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();

    local is_filler_enabled = menu_elements_flay_base.use_as_filler_only:get();  
    if is_filler_enabled then
        local current_resource_ws = player_local:get_primary_resource_current();
        local max_resource_ws = player_local:get_primary_resource_max();
        local fury_perc = current_resource_ws / max_resource_ws 
        local low_in_fury = fury_perc < 0.5

        if not low_in_fury then
            return false;
        end
    end;
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_data_flay, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.9;

        console.print("Casted Flay");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}
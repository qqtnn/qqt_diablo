local my_utility = require("my_utility/my_utility");

local menu_elements_shield_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "test_main_boolean_flame_shield")),
    hp_usage_shield       = slider_float:new(0.0, 1.0, 1.0, get_hash(my_utility.plugin_label .. "test_%_in_which_shield_will_cast")),
    flameshield_duration  = slider_float:new(0.0, 10.0, 1.0, get_hash(my_utility.plugin_label .. "test_flameshield_duration"))
}

local function menu()
    
    if menu_elements_shield_base.tree_tab:push("Flame Shield") then
        menu_elements_shield_base.main_boolean:render("Enable Spell", "")

       if menu_elements_shield_base.main_boolean:get() then
        menu_elements_shield_base.hp_usage_shield:render("Min cast HP Percent", "", 2)
        menu_elements_shield_base.flameshield_duration:render("Flame Shield Duration", "", 2)
       end

       menu_elements_shield_base.tree_tab:pop()
    end 
end

local flameshield_duration_slider = menu_elements_shield_base.flameshield_duration:get();
local next_time_allowed_cast = 0.0;
local spell_id_flame_shield = 167341;
local function logics()

    local menu_boolean = menu_elements_shield_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_flame_shield);

    -- if not is_logic_allowed then
    --     return false;
    -- end;

    
    local local_player = get_local_player();
    local player_current_health = local_player:get_current_health();
    local player_max_health = local_player:get_max_health();
    local health_percentabe = player_current_health / player_max_health;
    local menu_min_percentage = menu_elements_shield_base.hp_usage_shield:get();
    local current_orb_mode = orbwalker.get_orb_mode()

    if menu_boolean == false then
        return false
    end

    if current_orb_mode == orb_mode.none then
        return true
    end

    if not local_player:is_spell_ready(spell_id_flame_shield) then
        return false;
    end;

    -- if health_percentabe > menu_min_percentage then
    --     return false;
    -- end;

    if cast_spell.self(spell_id_flame_shield, flameshield_duration_slider - 0.5) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + (flameshield_duration_slider - 0.5);
        
        console.print("Sorcerer Plugin, Casted Flame Shield");
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
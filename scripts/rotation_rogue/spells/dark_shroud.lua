local my_utility = require("my_utility/my_utility");

local menu_elements_dark_shroud_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_bool_dark_shroud_base")),
    hp_usage_shield       = slider_float:new(0.0, 1.0, 0.98, get_hash(my_utility.plugin_label .. "%_in_which_shield_will_cast_base_shroud_2"))
}

local function menu()
    
    if menu_elements_dark_shroud_base.tree_tab:push("Dark Shroud") then
        menu_elements_dark_shroud_base.main_boolean:render("Enable Spell", "")

       if menu_elements_dark_shroud_base.main_boolean:get() then
        menu_elements_dark_shroud_base.hp_usage_shield:render("Min cast HP Percent", "", 2)
       end

       menu_elements_dark_shroud_base.tree_tab:pop()
    end 
end

local debug_console = false
local next_time_allowed_cast = 0.0;
local spell_id_dark_shroud = 786381;
local function logics()

    local menu_boolean = menu_elements_dark_shroud_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_dark_shroud);

    if not is_logic_allowed then
        return false;
    end;
    
    local local_player = get_local_player();
    local player_current_health = local_player:get_current_health();
    local player_max_health = local_player:get_max_health();
    local health_percentage = player_current_health / player_max_health;
    local menu_min_percentage = menu_elements_dark_shroud_base.hp_usage_shield:get();

    if health_percentage > menu_min_percentage then
        if debug_console then
            console.print("dark shround leave 111")
            console.print("health_percentage " .. health_percentage)
            console.print("menu_min_percentage " .. menu_min_percentage)
        end
        return false;
    end;

    local has_shroud = false

    local buffs = local_player:get_buffs()
    if buffs then
        for i, buff in ipairs(buffs) do
            local buff_hash = buff.name_hash
            if buff_hash == 786383 then
                has_shroud = true
                break
            end
        end
    end

    if has_shroud then
        return false
    end

    if cast_spell.self(spell_id_dark_shroud, 0.0) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;
        
        console.print("Sorcerer Plugin, Casted Dark Shroud");
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
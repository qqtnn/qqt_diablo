local my_utility = require("my_utility/my_utility")

local hurricane_menu_elements_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "hurricane_boolean")),
    
}
local function menu()
    if hurricane_menu_elements_base.tree_tab:push("Hurricane")then
        hurricane_menu_elements_base.main_boolean:render("Enable Spell", "")
 
        hurricane_menu_elements_base.tree_tab:pop()
    end
end

local spell_id_hurricane = 258990;
local next_time_allowed_cast = 0.0;

local function logics(player_position)

    local menu_boolean = hurricane_menu_elements_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_hurricane);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.self(spell_id_hurricane, 0.2) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;

        console.print("Druid Plugin, Casted Hurricane");
        return true;
    end;
            
    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
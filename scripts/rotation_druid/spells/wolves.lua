local my_utility = require("my_utility/my_utility");

local menu_elements_wolves = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_earth_spike")),
}

local function menu()
    
    if menu_elements_wolves.tree_tab:push("Wolves")then
        menu_elements_wolves.main_boolean:render("Enable Spell", "")
 
        menu_elements_wolves.tree_tab:pop()
    end
end

local spell_id_wolves = 265663
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_wolves.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_wolves);

    if not is_logic_allowed then
    return false;
    end;

    local target_position = target:get_position();

    cast_spell.target(target, spell_id_wolves, 0.5, false) 
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 1.5;
        
    console.print("Druid Plugin, Casted Wolves");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
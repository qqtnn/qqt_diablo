local my_utility = require("my_utility/my_utility");

local menu_elements_meteor = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_meteor")),
}

local function menu()
    
    if menu_elements_meteor.tree_tab:push("Meteor")then
        menu_elements_meteor.main_boolean:render("Enable Spell", "")
 
        menu_elements_meteor.tree_tab:pop()
    end
end

local spell_id_meteor = 296998
local next_time_allowed_cast = 0.0;

local function logics(target)
    
    local menu_boolean = menu_elements_meteor.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_meteor);

    if not is_logic_allowed then
    return false;
    end;

    local target_position = target:get_position();

    cast_spell.position(spell_id_meteor, target_position, 0.35) 
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 1.0;
        
    console.print("Sorcerer Plugin, Meteor");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
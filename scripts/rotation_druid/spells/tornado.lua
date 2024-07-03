local my_utility = require("my_utility/my_utility")

local tornado_menu_base =
{
    tree_tab                = tree_node:new(1),
    main_boolean            = checkbox:new(true, get_hash(my_utility.plugin_label .. "_tornado_main_boolean")),
}

local function menu()
    if tornado_menu_base.tree_tab:push("Tornado")then
        tornado_menu_base.main_boolean:render("Enable Spell", "")
  
        tornado_menu_base.tree_tab:pop()
     end
end

local spell_id_tornado = 304065;
local next_time_allowed_cast = 0.0;

local function logics(target)

    local menu_boolean = tornado_menu_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_tornado);

    if not is_logic_allowed then
        return false;
    end;

    local target_position = target:get_position();

    cast_spell.position(spell_id_tornado, target_position, 0.3)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.5;
        
    console.print("Druid Plugin, Casted Tornado");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}

       
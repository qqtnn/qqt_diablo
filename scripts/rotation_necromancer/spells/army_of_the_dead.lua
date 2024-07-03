local my_utility = require("my_utility/my_utility");

local menu_elemenst_army_of_d_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_army_of_d_base")),
}

local function menu()
    
    if menu_elemenst_army_of_d_base.tree_tab:push("Army Of The Dead")then
        menu_elemenst_army_of_d_base.main_boolean:render("Enable Spell", "")
 
        menu_elemenst_army_of_d_base.tree_tab:pop()
    end
end

local army_of_d_id = 497193;
local next_time_allowed_cast = 0.0;
local function logics()
    
    local menu_boolean = menu_elemenst_army_of_d_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                army_of_d_id);

    if not is_logic_allowed then
    return false;
    end;

    cast_spell.self(army_of_d_id, 0.35) 
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.2;
        
    console.print("Necro Plugin, Casted Army Of The Dead");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}
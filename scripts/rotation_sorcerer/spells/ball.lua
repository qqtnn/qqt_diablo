local my_utility = require("my_utility/my_utility");

local menu_elements = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_ball_lightning")),
}

local function menu()
    
    if menu_elements.tree_tab:push("Lightning Ball") then
       menu_elements.main_boolean:render("Enable Spell", "")

       menu_elements.tree_tab:pop()
    end
end

local spell_id_ball = 514030
local next_time_allowed_cast = 0.0;
local function logics()
    
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_ball);

    if not is_logic_allowed then
        return false;
    end;

    
    if cast_spell.self(spell_id_ball, 0.3) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.4;
        
        console.print("Sorcerer Plugin, Casted Ball");
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
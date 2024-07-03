local my_utility = require("my_utility/my_utility")

local grizzly_rage_menu_elements_base = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_ability")),
}
local function menu()                                                                              
    if grizzly_rage_menu_elements_base.main_tab:push("Grizzly Rage")then
        grizzly_rage_menu_elements_base.main_boolean:render("Enable Spell", "")
 
        grizzly_rage_menu_elements_base.main_tab:pop()
    end
end

local spell_id_grizzly_rage = 267021;
local next_time_allowed_cast = 0.0;

local function logics()

    local menu_boolean = grizzly_rage_menu_elements_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_grizzly_rage);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.self(spell_id_grizzly_rage, 0.0) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;
        console.print("Druid Plugin, Casted Grizzly Rage");
            return true;
        end;
            
        return false;
    end

return 
{
    menu = menu,
    logics = logics,   
}
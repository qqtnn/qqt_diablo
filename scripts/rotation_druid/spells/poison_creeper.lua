local my_utility = require("my_utility/my_utility")

local menu_elements_pois_creep = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_ability")),
}
local function menu()                                                                              
    if menu_elements_pois_creep.main_tab:push("Poison Creeper")then
        menu_elements_pois_creep.main_boolean:render("Enable Spell", "")
 
        menu_elements_pois_creep.main_tab:pop()
    end
end

local spell_id_pois_creep = 314601;
local next_time_allowed_cast = 0.0;

local function logics()

    local menu_boolean = menu_elements_pois_creep.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_pois_creep);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.self(spell_id_pois_creep, 0.0) then
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
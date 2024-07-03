local my_utility = require("my_utility/my_utility")

local shadow_imbuement_menu_elements_base = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_shadow_base")),
}
local function menu()                                                                              
    if shadow_imbuement_menu_elements_base.main_tab:push("Shadow Imbuement")then
        shadow_imbuement_menu_elements_base.main_boolean:render("Enable Spell", "")
 
        shadow_imbuement_menu_elements_base.main_tab:pop()
    end
end

local spell_id_shadow_imb = 380288;
local next_time_allowed_cast = 0.0;

local function logics()

    local menu_boolean = shadow_imbuement_menu_elements_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shadow_imb);

    if not is_logic_allowed then
        return false;
    end;

    if cast_spell.self(spell_id_shadow_imb, 0.0) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;
        console.print("Rouge Plugin, Casted Shadow Imbuement");
            return true;
        end;
            
        return false;
    end

return 
{
    menu = menu,
    logics = logics,   
}
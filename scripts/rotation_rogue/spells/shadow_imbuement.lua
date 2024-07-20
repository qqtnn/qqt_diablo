local my_utility = require("my_utility/my_utility")
local poison_imbuement = require("spells/poison_imbuement")
local cold_imbuement = require("spells/cold_imbuement")

local shadow_imbuement_menu_elements_base = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_shadow_base")),
}

local function menu()                                                                              
    if shadow_imbuement_menu_elements_base.main_tab:push("Shadow Imbuement") then
        shadow_imbuement_menu_elements_base.main_boolean:render("Enable Spell", "")
        shadow_imbuement_menu_elements_base.main_tab:pop()
    end
end

local spell_id_shadow_imb = 380288
local next_time_allowed_cast = 0.0

local function is_active()
    local local_player = get_local_player()
    local buffs = local_player:get_buffs()
   
    for i, buff in ipairs(buffs) do
        if buff.name_hash == 380288 then
            -- console.print("Shadow Imbuement Active")
            return true
        end
    end

    return false
end

local function logics(target)
    local current_time = get_time_since_inject()
    local menu_boolean = shadow_imbuement_menu_elements_base.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean, 
        next_time_allowed_cast, 
        spell_id_shadow_imb)

    if not is_logic_allowed or is_active() or 
       poison_imbuement.is_active() or poison_imbuement.will_cast(target) or
       cold_imbuement.is_active() or cold_imbuement.will_cast(target) then
        return false
    end

    if cast_spell.self(spell_id_shadow_imb, 0.0) then
        next_time_allowed_cast = current_time + 0.2
        console.print("Rouge Plugin, Casted Shadow Imbuement")
        return true
    end
        
    return false
end

return 
{
    menu = menu,
    logics = logics,
    is_active = is_active,
}
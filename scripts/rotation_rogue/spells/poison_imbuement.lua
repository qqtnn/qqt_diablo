local my_utility = require("my_utility/my_utility")

local poison_imbuement_menu_elements_base = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "poison_emb_main_bool_base")),
    only_elite_or_boss = checkbox:new(true, get_hash(my_utility.plugin_label .. "poison_emb_only_elite_or_boss_boolean")),
}

local function menu()
    if poison_imbuement_menu_elements_base.main_tab:push("Poison Imbuement") then
        poison_imbuement_menu_elements_base.main_boolean:render("Enable Spell", "")
        poison_imbuement_menu_elements_base.only_elite_or_boss:render("Only Elite or Boss", "")
        poison_imbuement_menu_elements_base.main_tab:pop()
    end
end

local spell_id_poison_imb = 358508
local next_time_allowed_cast = 0.0

local function is_active()
    local local_player = get_local_player()
    local buffs = local_player:get_buffs()
   
    for i, buff in ipairs(buffs) do
        if buff.name_hash == 358508 then
            -- console.print("Poison Imbuement Active")
            return true
        end
    end

    return false
end

local function will_cast(target)
    local menu_boolean = poison_imbuement_menu_elements_base.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean,
        next_time_allowed_cast,
        spell_id_poison_imb
    )

    if not is_logic_allowed or is_active() then
        return false
    end

    if poison_imbuement_menu_elements_base.only_elite_or_boss:get() then
        local special_found = false
    
        local enemies = target_selector.get_near_target_list(get_player_position(), 12)
        for _, enemy in pairs(enemies) do
            local is_special = enemy:is_champion() or enemy:is_elite() or enemy:is_boss()
            if is_special then
                special_found = true
                break
            end
        end
    
        if not special_found then
            return false
        end
    end

    return true
end

local function logics(target)
    if will_cast(target) then
        local current_time = get_time_since_inject()
        if cast_spell.self(spell_id_poison_imb, 0.0) then
            next_time_allowed_cast = current_time + 0.2
            console.print("Rouge Plugin, Casted Poison Imb")
            return true
        end
    end

    return false
end

return {
    menu = menu,
    logics = logics,
    is_active = is_active,
    will_cast = will_cast,
}
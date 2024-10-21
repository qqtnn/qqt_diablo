local my_utility = require("my_utility/my_utility")

local stone_burst_menu_base =
{
    tree_tab                = tree_node:new(1),
    main_boolean            = checkbox:new(true, get_hash(my_utility.plugin_label .. "_stone_burst_main_boolean")),
}

local function menu()
    if stone_burst_menu_base.tree_tab:push("Stone Burst")then
        stone_burst_menu_base.main_boolean:render("Enable Spell", "")
  
        stone_burst_menu_base.tree_tab:pop()
     end
end

local spell_id_stone_burst = 1473878;
local next_time_allowed_cast = 0.0;

local function logics(target)

    local menu_boolean = stone_burst_menu_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_stone_burst);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    local current_resource_ws = player_local:get_primary_resource_current();

    if current_resource_ws < 30  then
        return false
    end

    local target_position = target:get_position();

    -- adding multiple channel spells just overrides the current one 
    cast_spell.add_channel_spell(spell_id_stone_burst, 0, 0, nil, target_position, 0.0, 0.0)

    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.5;

    console.print("Druid Plugin, Channeling Stone Burst");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}

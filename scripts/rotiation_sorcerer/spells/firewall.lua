local my_utility = require("my_utility/my_utility");

local menu_elements_firewall = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_firwall")),
}

local function menu()
    
    if menu_elements_firewall.tree_tab:push("Firewall")then
        menu_elements_firewall.main_boolean:render("Enable Spell", "")
 
        menu_elements_firewall.tree_tab:pop()
    end
end

local spell_id_firewall = 111422
local next_time_allowed_cast = 0.0;

local function logics(local_player, target)
    local menu_boolean = menu_elements_firewall.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_firewall)

    if not is_logic_allowed then
        return false
    end

    local player_position = local_player:get_position()  -- get the player's position
    local target_position = target:get_position()

    -- check if there is already a generic_firewall_proxy active and if the target is within the rectangle limit
    local actors = actors_manager.get_all_actors()
    for _, actor in ipairs(actors) do
        local actor_name = actor:get_skin_name()
        if actor_name == "Generic_Proxy_firewall" then
            local actor_position = actor:get_position()
            dx = math.abs(target_position:x() - actor_position:x())
            dy = math.abs(target_position:y() - actor_position:y())    
            if dx <= 2 and dy <= 8 then  -- rectangle width is 2 and height is 8
                return false
            end
        end
    end

    -- calculate the midpoint between the player and the target, favoring the target's position
    local cast_position = vec3:new(
        (player_position:x() + 2 * target_position:x()) / 3,
        (player_position:y() + 2 * target_position:y()) / 3,
        (player_position:z() + 2 * target_position:z()) / 3
    )

    local dx = math.abs(target_position:x() - cast_position:x())
    local dy = math.abs(target_position:y() - cast_position:y())
    if dx > 2 or dy > 8 then  -- bigger numbers more lenient
        return false
    end

    -- cast the spell at the calculated position and create a new actor named generic_firewall_proxy
    cast_spell.position(spell_id_firewall, cast_position, 3)
    local current_time = get_time_since_inject()
    next_time_allowed_cast = current_time + 3

    console.print("Sorcerer Plugin, Firewall")
    return true
end

return 
{
    menu = menu,
    logics = logics,   
}
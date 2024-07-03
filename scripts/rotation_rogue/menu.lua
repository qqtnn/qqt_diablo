local my_utility = require("my_utility/my_utility")
local menu_elements_bone =
{
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean")),
    mode                = combo_box:new(0, get_hash(my_utility.plugin_label .. "mode_melee_range")),
    dash_cooldown   = slider_int:new(0, 6, 6, get_hash(my_utility.plugin_label .. "dash_cooldown")),
    main_tree           = tree_node:new(0),
}

return menu_elements_bone;
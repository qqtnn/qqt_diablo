local my_utility = require("my_utility/my_utility")
local menu_elements_jmrz =
{
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean")),
    immortal_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "immortal_boolean")),
    immortal_drawings        = checkbox:new(false, get_hash(my_utility.plugin_label .. "immortal_drawings")),
    main_tree           = tree_node:new(0),
}

return menu_elements_jmrz;
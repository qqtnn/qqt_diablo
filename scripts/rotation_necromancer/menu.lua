local my_utility = require("my_utility/my_utility")
local menu_elements_bone =
{
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean")),
    main_tree           = tree_node:new(0),
}

return menu_elements_bone;
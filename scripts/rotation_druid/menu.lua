local my_utility = require("my_utility/my_utility")
local menu_elements =
{
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean")),
    -- first parameter is the default state, second one the menu element's ID. The ID must be unique,
    -- not only from within the plugin but also it needs to be unique between demo menu elements and
    -- other scripts menu elements. This is why we concatenate the plugin name ("LUA_EXAMPLE_NECROMANCER")
    -- with the menu element name itself.

    main_tree           = tree_node:new(0),
    -- trees are the menu tabs. The parameter that we pass is the depth of the node. (0 for main menu (bright red rectangle), 
    -- 1 for sub-menu of depth 1 (circular red rectangle with white background) and so on)
}

return menu_elements;
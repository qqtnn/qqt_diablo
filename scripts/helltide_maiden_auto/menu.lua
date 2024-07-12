local plugin_label = "HELLTIDE_MAIDEN_AUTO_PLUGIN_"
local menu_elements =
{
    main_helltide_maiden_auto_plugin_enabled = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_enabled")),
    main_helltide_maiden_auto_plugin_run_explorer = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_run_explorer")),
    main_helltide_maiden_auto_plugin_auto_revive = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_auto_revive")),
    main_helltide_maiden_auto_plugin_show_task = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_show_task")),
    main_helltide_maiden_auto_plugin_show_explorer_circle = checkbox:new(true, get_hash("main_helltide_maiden_auto_plugin_show_explorer_circle")),
    main_helltide_maiden_auto_plugin_run_explorer_close_first = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_run_explorer_close_first")),
    main_helltide_maiden_auto_plugin_explorer_threshold = slider_float:new(0.0, 20.0, 1.5, get_hash("main_helltide_maiden_auto_plugin_explorer_threshold")),
    main_helltide_maiden_auto_plugin_explorer_thresholdvar = slider_float:new(0.0, 10.0, 3.0, get_hash("main_helltide_maiden_auto_plugin_explorer_thresholdvar")),
    main_helltide_maiden_auto_plugin_explorer_circle_radius = slider_float:new(5.0, 30.0, 15.0, get_hash("main_helltide_maiden_auto_plugin_explorer_circle_radius")),
    main_helltide_maiden_auto_plugin_insert_hearts = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_insert_hearts")),
    main_helltide_maiden_auto_plugin_insert_hearts_interval_slider = slider_float:new(0.0, 600.0, 300.0, get_hash("main_helltide_maiden_auto_plugin_insert_hearts_interval_slider")),
    main_helltide_maiden_auto_plugin_insert_hearts_afterboss = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_insert_hearts_afterboss")),
    main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs")),
    main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies = checkbox:new(true, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies")),
    main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider = slider_float:new(2.0, 600.0, 10.0, get_hash("main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider")),
    main_helltide_maiden_auto_plugin_reset = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_reset")),
    main_helltide_maiden_auto_plugin_fake_maiden = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_fake_maiden")),
    main_helltide_maiden_auto_plugin_fake_circle = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_fake_circle")),
    main_helltide_maiden_auto_plugin_debug = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugin_debug")),
    main_helltide_maiden_auto_plugine_force_inhelltide = checkbox:new(false, get_hash(plugin_label .. "main_helltide_maiden_auto_plugine_force_inhelltide")),

    enable_loot_logic = checkbox:new(true, get_hash(plugin_label .. "enable_loot_logic")),
    only_loot_ga = checkbox:new(false, get_hash(plugin_label .. "only_loot_ga")),

    enable_sell_logic = checkbox:new(true, get_hash(plugin_label .. "enable_sell_logic")),
    salvage_instead = checkbox:new(false, get_hash(plugin_label .. "salvage_instead")),

    enable_repair_logic = checkbox:new(true, get_hash(plugin_label .. "enable_repair_logic")),

    main_tree = tree_node:new(0),
}
return menu_elements

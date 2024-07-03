---@diagnostic disable: missing-return

--- @class loot_manager
loot_manager = {}

--- Retrieves the identifier for a given item.
--- @param obj game.object
--- @return number
function loot_manager.get_item_identifier(obj) end

--- Checks if the given object is interactable.
--- @param obj game.object
--- @return boolean
function loot_manager.is_interactable_object(obj) end

--- Checks if the given item is lootable, with options to exclude potions and gold.
--- @param obj game.object
--- @param exclude_potions boolean
--- @param exclude_gold boolean
--- @return boolean
function loot_manager.is_lootable_item(obj, exclude_potions, exclude_gold) end

--- Determines if a potion is necessary.
--- @return boolean
function loot_manager.is_potion_necessary() end

--- Determines if a potion is lootable.
--- @return boolean
function loot_manager.is_potion_lootable() end

--- Checks if the given object is gold.
--- @param obj game.object
--- @return boolean
function loot_manager.is_gold(obj) end

--- Checks if the given object is a potion.
--- @param obj game.object
--- @return boolean
function loot_manager.is_potion(obj) end

--- Checks if the given object is a shrine.
--- @param obj game.object
--- @return boolean
function loot_manager.is_shrine(obj) end

--- Checks if the given object is obols.
--- @param obj game.object
--- @return boolean
function loot_manager.is_obols(obj) end

--- Checks if the given object is a locked chest.
--- @param obj game.object
--- @return boolean
function loot_manager.is_locked_chest(obj) end

--- Determines if the player has a whispering key.
--- @return boolean
function loot_manager.has_whispering_key() end

--- Retrieves the names of consumables.
--- @return string[]
function loot_manager.get_consumables_names() end

--- Checks if the given object is an ore exception.
--- @param obj game.object
--- @return boolean
function loot_manager.is_ore_exception(obj) end

--- Checks if the given object is a chest exception.
--- @param obj game.object
--- @return boolean
function loot_manager.is_chest_exception(obj) end

--- Checks if the given object is an event trigger exception.
--- @param obj game.object
--- @return boolean
function loot_manager.is_event_trigger_exception(obj) end

--- Retrieves all items and chests, sorted by distance.
--- @return game.object[]
function loot_manager.get_all_items_chest_sort_by_distance() end

--- Checks if there are any items around a given point within a threshold distance.
--- @param point vec3
--- @param threshold number
--- @param exclude_potions boolean
--- @param exclude_gold boolean
--- @return boolean
function loot_manager.any_item_around(point, threshold, exclude_potions, exclude_gold) end

--- Loots the given item.
--- @param obj game.object
--- @param exclude_potions boolean
--- @param exclude_gold boolean
--- @return boolean
function loot_manager.loot_item(obj, exclude_potions, exclude_gold) end

--- Loots the given item using orbwalker.
--- @param obj game.object
--- @return boolean
function loot_manager.loot_item_orbwalker(obj) end

--- Interacts with the given object.
--- @param obj game.object
--- @return boolean
function loot_manager.interact_with_object(obj) end

--- Interacts with the given vendor and sells all items.
--- @param obj game.object
--- @return boolean
function loot_manager.interact_with_vendor_and_sell_all(obj) end

--- Sells all items. Requires vendor to be open.
--- @return boolean
function loot_manager.sell_all_items() end

--- Salvages all items. Requires vendor to be open.
--- @return boolean
function loot_manager.salvage_all_items() end

--- Sells a specific item. Requires vendor to be open.
--- @param item game.item_data
--- @return boolean
function loot_manager.sell_specific_item(item) end

--- Salvages a specific item. Requires vendor to be open.
--- @param item game.item_data
--- @return boolean
function loot_manager.salvage_specific_item(item) end

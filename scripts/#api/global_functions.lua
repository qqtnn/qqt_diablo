---@diagnostic disable: lowercase-global, missing-return, undefined-global

--- Get the position of the local player.
--- @return vec3 @Player's position
function get_player_position() end

--- Retrieve the local player object.
--- @return game.object @Local player object
function get_local_player() end

--- Get a list of all actors.
--- @return table<number, game.object> @Table of actors
function get_actors_list() end

--- Get a list of all attachments.
--- @return table<number, game.object> @Table of attachments
function get_attachments_list() end

--- Log multiple values to the console.
--- @vararg any @Values to log
function log(...) end

--- Compute the hash of a string.
--- @param str string @String to hash
--- @return number @Hashed value
function get_hash(str) end

--- Get the cursor's position in the game world.
--- @return vec3 @Cursor position
function get_cursor_position() end

--- Render a header in the menu.
--- @param str string @Header text
--- @param color ImVec4 @Color of the header
function render_menu_header(str, color) end

--- Get the current game time.
--- @return number @Game time
function get_gametime() end

--- Get time elapsed since injection.
--- @return number @Time since injection
function get_time_since_inject() end

--- Leave the current dungeon.
function leave_dungeon() end

--- Revive at the last checkpoint.
function revive_at_checkpoint() end

--- Start the game.
function start_game() end

--- Leave the game.
function leave_game() end

--- Use a health potion.
function use_health_potion() end

--- Get equipped spell IDs.
--- @return table<number, number> @Table of spell IDs
function get_equipped_spell_ids() end

--- Get the name for a spell by its ID.
--- @param spell_id number @ID of the spell
--- @return string @Name of the spell
function get_name_for_spell(spell_id) end

--- Check if the inventory is open.
--- @return boolean @True if inventory is open
function is_inventory_open() end

--- Get the ID of the currently open inventory bag.
--- @return number @ID of the open bag
function get_open_inventory_bag() end

--- Get the state of a key.
--- @param key number @Key code
--- @return boolean @True if the key is down
function get_key_state(key) end

---@class game.quest
game.quest = {}

--- Get the list of quests.
--- @return table<number, game.quest> @Table of quests
function get_quests() end

--- Get the ID of the quest
--- @param self game.quest
--- @return number
function game.quest:get_id() end

--- Get the name of the quest
--- @param self game.quest
--- @return string
function game.quest:get_name() end

-- Example usage:
-- local quests = get_quests()
-- for _, quest in pairs(quests) do
--     local quest_id = quest:get_id()
--     local quest_name = quest:get_name()
-- end

--- Get the currently hovered item.
--- @return game.item_data @Hovered item
function get_hovered_item() end

--- Interact with an object.
--- @param object game.object @Object to interact with
--- @return boolean @True if interaction was successful
function interact_object(object) end

--- Interact with a vendor.
--- @param object game.object @Vendor to interact with
--- @return boolean @True if interaction was successful
function interact_vendor(object) end

--- Get the screen width.
--- @return number @Screen width
function get_screen_width() end

--- Get the screen height.
--- @return number @Screen height
function get_screen_height() end

--- Teleport to a waypoint.
--- @param id number @Waypoint ID
--- @return boolean @True if teleportation was successful
function teleport_to_waypoint(id) end

--- Reset all dungeons.
function reset_all_dungeons() end

--- Get the name of the local player.
--- @return string @Local player's name
function get_local_player_name() end

--- Get the current world object.
--- @return game.world|nil @Current world object or nil if not available
function get_current_world() end

--- @return number
function get_helltide_coin_cinders() end

--- @return number
function get_helltide_coin_hearts() end

--- @return boolean
function is_chat_open() end

--- @return boolean
function is_in_helltide() end

--- @return string
function get_local_player_name() end

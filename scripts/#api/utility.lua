---@diagnostic disable: missing-return

--- @class utility.raycast_data
--- @field public is_hit boolean
--- @field public hit_point vec3

-- Creating a global table to simulate the namespace and class in Lua
_G.raycast_table = {}

-- note: no constructor
--- Constructor for raycast_data
-- - @return utility.raycast_data
-- function raycast_table.new()
--     local self = setmetatable({}, { __index = raycast_table })
--     self.is_hit = false -- default value
--     self.hit_point = { x = 0, y = 0, z = 0 } -- assuming vec3 is a simple table with x, y, z
--     return self
-- end

--- Simulates the is_hit method
--- @param self utility.raycast_data
--- @return boolean
function raycast_table.is_hit(self)
    return self.is_hit
end

--- Simulates the hit_point method
--- @param self utility.raycast_data
--- @return vec3
function raycast_table.hit_point(self)
    return self.hit_point
end

--- @class utility
utility = {}

--- Checks if a spell is ready to be cast based on its ID.
--- @param spell_id number The ID of the spell.
--- @return boolean Returns true if the spell is ready, false otherwise.
utility.is_spell_ready = function(spell_id) end

--- Checks if the player can afford to cast a spell based on its ID.
--- @param spell_id number The ID of the spell.
--- @return boolean Returns true if the spell can be afforded, false otherwise.
utility.is_spell_affordable = function(spell_id) end

--- Checks if a spell can be cast based on its ID.
--- @param spell_id number The ID of the spell.
--- @return boolean Returns true if the spell can be cast, false otherwise.
utility.can_cast_spell = function(spell_id) end

--- Retrieves a list of units within a circular area.
--- @param center vec3 The center of the circle.
--- @param radius number The radius of the circle.
--- @return table<game.object> Returns a table of units (gameobject) within the circle.
utility.get_units_inside_circle_list = function(center, radius) end

--- Retrieves a list of units within a rectangular area.
--- @param origin vec3 The starting point of the rectangle.
--- @param destination vec3 The ending point of the rectangle.
--- @param width number The width of the rectangle.
--- @return table<game.object> Returns a table of units (gameobject)  within the rectangle.
utility.get_units_inside_rectangle_list = function(origin, destination, width) end

--- Counts the number of units within a circular area.
--- @param center vec3 The center of the circle.
--- @param radius number The radius of the circle.
--- @return number Returns the count of units within the circle.
utility.get_amount_of_units_inside_circle = function(center, radius) end

--- Counts the number of units within a rectangular area.
--- @param origin vec3 The starting point of the rectangle.
--- @param destination vec3 The ending point of the rectangle.
--- @param width number The width of the rectangle.
--- @return number Returns the count of units within the rectangle.
utility.get_amount_of_units_rectangle_circle = function(origin, destination, width) end

--- Checks if a point on the map is walkable.
--- @param point vec3 The point to check.
--- @return boolean Returns true if the point is walkable, false otherwise.
utility.is_point_walkeable = function(point) end

--- Checks if a point on the map is walkable, with exceptions.
--- @param point vec3 The point to check.
--- @return boolean Returns true if the point is walkable, false otherwise.
utility.is_point_walkeable_exception = function(point) end

--- Performs a heavy check to see if a point on the map is walkable.
--- @param point vec3 The point to check.
--- @return boolean Returns true if the point is walkable, false otherwise.
utility.is_point_walkeable_heavy = function(point) end

--- Checks if a ray cast between two points is walkable.
--- @param origin vec3 The starting point of the ray.
--- @param destination vec3 The ending point of the ray.
--- @param width number The width of the ray.
--- @param steps_distance number The distance between steps in the ray.
--- @return boolean Returns true if the ray is walkable, false otherwise.
utility.is_ray_cast_walkeable = function(origin, destination, width, steps_distance) end

--- Retrieves raycast data between two points.
--- @param origin vec3 The starting point of the ray.
--- @param destination vec3 The ending point of the ray.
--- @param width number The width of the ray.
--- @param steps_distance number The distance between steps in the ray.
--- @return table<utility.raycast_data> Returns a table with raycast data.
utility.get_raycast_table = function(origin, destination, width, steps_distance) end

--- Adjusts a point's height to a valid position on the current world's terrain.
--- @param point vec3 The point to adjust.
--- @return vec3 The adjusted point with valid height.
utility.set_height_of_valid_position = function(point) end

--- Sets a map pin at a specific point.
--- @param point vec3 The location to set the pin.
--- @return boolean Returns true if the pin was set successfully, false otherwise.
utility.set_map_pin = function(point) end

utility.toggle_mount = function() end

-- Pit Levels
-- 51 = 0x1C3554
-- 75 = 0x1C3586
-- 100 = 0x1C35C1
-- 61 = 0x1C3568
-- 121 = 0x1D6D21
-- 81 = 0x1C3595 
-- 98 = 0x1C35BC
-- 31 = 0x1C352B
-- 119 = 0x1D6D1D
-- 129 = 0x1D6D36
-- 141 = 0x1D6D4E
-- 101 = 0x1D6CEF
utility.open_pit_portal = function(level) end

--- Reveals the minimap.
--- @return boolean
utility.reveal_minimap = function() end

utility.summon_boss = function() end
utility.summon_boss_next_recipe = function() end
utility.summon_boss_previous_recipe = function() end

utility.confirm_sigil_notification = function() end

-- ----------------------------------------------------------------
-- Keyboard
-- ----------------------------------------------------------------

--- Sends a single key press (key down + key up).
--- @param vk_code number Virtual-Key code.
--- @return nil
utility.send_key_press = function(vk_code) end

--- Sends a key down event.
--- Useful for held keys such as movement or modifiers.
--- @param vk_code number Virtual-Key code.
--- @return nil
utility.send_key_down = function(vk_code) end

--- Sends a key up event.
--- @param vk_code number Virtual-Key code.
--- @return nil
utility.send_key_up = function(vk_code) end

--- Sends a key combination.
--- Keys are held in order, the last key is pressed, then released in reverse order.
--- Example: Ctrl+A, Ctrl+Shift+S
--- @param ... number Virtual-Key codes.
--- @return nil
utility.send_key_combo = function(...) end

--- Sends a full string as character input.
--- @param text string
--- @return nil
utility.send_string = function(text) end

--- Sends a single WM_CHAR character.
--- @param char_code number Character code, usually from string.byte().
--- @return nil
utility.send_char = function(char_code) end

-- Common VK examples:
-- Enter   = 0x0D
-- Escape  = 0x1B
-- Tab     = 0x09
-- Space   = 0x20
-- Shift   = 0x10
-- Ctrl    = 0x11
-- Alt     = 0x12
-- Left    = 0x25
-- Up      = 0x26
-- Right   = 0x27
-- Down    = 0x28
-- F1-F12  = 0x70 - 0x7B
-- A-Z     = 0x41 - 0x5A
-- 0-9     = 0x30 - 0x39

-- Examples:
-- utility.send_key_press(0x0D) -- Enter
-- utility.send_key_press(0x1B) -- Escape
-- utility.send_key_press(string.byte('I')) -- Inventory
-- utility.send_key_down(0x11) -- Hold Ctrl
-- utility.send_key_up(0x11) -- Release Ctrl
-- utility.send_key_combo(0x11, string.byte('A')) -- Ctrl+A
-- utility.send_key_combo(0x11, 0x10, string.byte('S')) -- Ctrl+Shift+S
-- utility.send_string("hello world")
-- utility.send_char(string.byte('x'))

-- ----------------------------------------------------------------
-- Mouse
-- ----------------------------------------------------------------

--- Sends a left mouse click at client coordinates.
--- @param x number
--- @param y number
--- @return nil
utility.send_mouse_click = function(x, y) end

--- Sends a right mouse click at client coordinates.
--- @param x number
--- @param y number
--- @return nil
utility.send_mouse_right_click = function(x, y) end

--- Sends a middle mouse click at client coordinates.
--- @param x number
--- @param y number
--- @return nil
utility.send_mouse_middle_click = function(x, y) end

--- Sends a left mouse double click at client coordinates.
--- @param x number
--- @param y number
--- @return nil
utility.send_mouse_double_click = function(x, y) end

--- Sends a mouse button down event.
--- button: 0 = left, 1 = right, 2 = middle
--- @param x number
--- @param y number
--- @param button number
--- @return nil
utility.send_mouse_down = function(x, y, button) end

--- Sends a mouse button up event.
--- button: 0 = left, 1 = right, 2 = middle
--- @param x number
--- @param y number
--- @param button number
--- @return nil
utility.send_mouse_up = function(x, y, button) end

--- Moves the mouse to client coordinates without clicking.
--- @param x number
--- @param y number
--- @return nil
utility.send_mouse_move = function(x, y) end

--- Sends a vertical mouse wheel event.
--- delta: +120 = up, -120 = down
--- @param x number
--- @param y number
--- @param delta number
--- @return nil
utility.send_mouse_wheel = function(x, y, delta) end

--- Sends a horizontal mouse wheel event.
--- @param x number
--- @param y number
--- @param delta number
--- @return nil
utility.send_mouse_hwheel = function(x, y, delta) end

--- Drags the mouse from one point to another.
--- button: 0 = left, 1 = right, 2 = middle
--- If omitted, button is usually left.
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @param button? number
--- @return nil
utility.send_mouse_drag = function(x1, y1, x2, y2, button) end

--- Gets the cursor position in game-window client coordinates.
--- @return number x
--- @return number y
utility.get_cursor_screen_position = function() end

-- ----------------------------------------------------------------
-- Small practical examples
-- Tip: prefer screen-relative coordinates instead of hardcoded pixels.
-- This keeps clicks more consistent across different resolutions.
-- ----------------------------------------------------------------

-- local function accept_dialog()
--     utility.send_key_press(0x0D) -- Enter
-- end

-- local function close_menu()
--     utility.send_key_press(0x1B) -- Escape
-- end

-- local function toggle_map()
--     utility.send_key_press(string.byte('M'))
-- end

-- Example: click near the center of the screen, then confirm with Enter.
-- local function join_realm()
--     local w = get_screen_width()
--     local h = get_screen_height()
--     local x = w * 0.5
--     local y = h * 0.5
--
--     utility.send_mouse_click(x, y)
--     utility.send_key_press(0x0D)
-- end

-- Example: hold W for a short duration.
-- local hold_start = nil
-- local hold_duration = 2.0
--
-- local function start_move_forward()
--     utility.send_key_down(string.byte('W'))
--     hold_start = get_time_since_inject()
-- end
--
-- local function update_move_forward()
--     if hold_start and get_time_since_inject() - hold_start >= hold_duration then
--         utility.send_key_up(string.byte('W'))
--         hold_start = nil
--     end
-- end

-- Example: scroll using the center of the screen as a safe generic anchor.
-- local function scroll_vendor_down(ticks)
--     ticks = ticks or 3
--     local w = get_screen_width()
--     local h = get_screen_height()
--     local cx = w * 0.5
--     local cy = h * 0.5
--
--     for i = 1, ticks do
--         utility.send_mouse_wheel(cx, cy, -120)
--     end
-- end

-- Example: click a position using relative coordinates.
-- local function click_bottom_right_area()
--     local w = get_screen_width()
--     local h = get_screen_height()
--     local x = w * 0.85
--     local y = h * 0.85
--
--     utility.send_mouse_click(x, y)
-- end

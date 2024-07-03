---@diagnostic disable: lowercase-global

--- Registers a function to be called on update.
--- @param on_update_f function The function to call on update.
function on_update(on_update_f) end

--- Registers a function to be called on render.
--- @param on_render_f function The function to call on render.
function on_render(on_render_f) end

--- Registers a function to be called before each tick.
--- @param on_pre_tick_f function The function to call before each tick.
function on_pre_tick(on_pre_tick_f) end

--- Registers a function to be called when rendering the menu.
--- @param on_render_menu_f function The function to call when rendering the menu.
function on_render_menu(on_render_menu_f) end

--- Registers a function to be called when a key is pressed.
--- @param on_key_press_f function The function to call when a key is pressed.
function on_key_press(on_key_press_f) end

--- Registers a function to be called when a key is released.
--- @param on_key_release_f function The function to call when a key is released.
function on_key_release(on_key_release_f) end

local gui = require "gui"
local settings = {
    enabled = false,
    elites_only = false,
    pit_level = 1
}

function settings:update_settings()
    settings.enabled = gui.elements.main_toggle:get()
    settings.elites_only = gui.elements.elite_only_toggle:get()
    settings.pit_level = gui.elements.pit_level_slider:get()
    settings.loot_modes = gui.elements.loot_modes:get()
end

return settings

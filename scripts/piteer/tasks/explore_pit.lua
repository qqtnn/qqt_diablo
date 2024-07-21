local utils = require "core.utils"
local enums   = require "data.enums"
local explorer= require "core.explorer"

local task  = {
    name = "Explore Pit",
    shouldExecute = function()
        return utils.player_on_quest(enums.quests.pit_ongoing) and not utils.get_closest_enemy()
    end,
    Execute = function()
        explorer.enabled = true
    end
}

return task

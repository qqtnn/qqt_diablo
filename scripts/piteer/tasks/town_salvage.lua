local utils = require "core.utils"
local enums   = require "data.enums"

local task  = {
    name = "Town Salvage",
    shouldExecute = function()
        return utils.player_in_zone("Scos_Cerrigar") and get_local_player():get_item_count() >= 20
    end,
    Execute = function()
        auto_play.repair_routine = function() end
    end
}

return task

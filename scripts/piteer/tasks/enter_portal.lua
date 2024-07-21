local utils = require "core.utils"
local enums = require "data.enums"
local explorer = require "core.explorer"

local task  = {
    name = "Enter Portal",
    shouldExecute = function()
        return utils.get_pit_portal()
    end,
    Execute = function()
        local portal = utils.get_pit_portal()
        if portal then
            if utils.player_on_quest(enums.quests.pit_ongoing) then
                explorer:clear_path_and_target()
                explorer:set_custom_target(portal:get_position())
                explorer:move_to_target()

                -- Check if the player is close enough to interact with the portal
                if utils.distance_to(portal) < 2 then
                    interact_object(portal)
                end
            else
                -- interact_object(portal) -- qqt note: fix stuck
				loot_manager.interact_with_object(portal)
            end
        end
    end
}

return task
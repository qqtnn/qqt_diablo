local utils      = require "core.utils"
local enums      = require "data.enums"
local navigation = require "core.navigation"
local settings   = require "core.settings"
local tracker    = require "core.tracker"

local last_open  = 0

local task       = {
    name = "Open Pit",
    shouldExecute = function()
        return utils.player_in_zone("Scos_Cerrigar") and not utils.get_pit_portal()
    end,
    Execute = function()
        if tracker.finished_time ~= 0 then
            tracker.finished_time = 0
        end

        local obelisk = utils.get_obelisk()
        if obelisk then
            -- interact_object(obelisk) -- qqt note: fix stuck
			loot_manager.interact_with_object(obelisk)

            if utils.distance_to(obelisk) < 2 and get_time_since_inject() - last_open > 2 then

                local pit_level = settings.pit_level
                local actual_address = 0x1C34EB

                if pit_level <= 16 then
                    if math.abs(pit_level - 1) <= math.abs(pit_level - 31) then
                        actual_address = 0x1C34EB
                    else
                        actual_address = 0x1C352B
                    end
                elseif pit_level <= 61 then
                    if math.abs(pit_level - 31) <= math.abs(pit_level - 51) then
                        actual_address = 0x1C352B
                    elseif math.abs(pit_level - 51) <= math.abs(pit_level - 61) then
                        actual_address = 0x1C3554
                    else
                        actual_address = 0x1C3568
                    end
                elseif pit_level <= 81 then
                    if math.abs(pit_level - 61) <= math.abs(pit_level - 75) then
                        actual_address = 0x1C3568
                    elseif math.abs(pit_level - 75) <= math.abs(pit_level - 81) then
                        actual_address = 0x1C3586
                    else
                        actual_address = 0x1C3595
                    end
                elseif pit_level <= 101 then
                    if math.abs(pit_level - 81) <= math.abs(pit_level - 98) then
                        actual_address = 0x1C3595
                    elseif math.abs(pit_level - 98) <= math.abs(pit_level - 100) then
                        actual_address = 0x1C35BC
                    else
                        actual_address = 0x1C35C1
                    end
                elseif pit_level <= 121 then
                    if math.abs(pit_level - 101) <= math.abs(pit_level - 119) then
                        actual_address = 0x1D6CEF
                    elseif math.abs(pit_level - 119) <= math.abs(pit_level - 121) then
                        actual_address = 0x1D6D1D
                    else
                        actual_address = 0x1D6D21
                    end
                elseif pit_level <= 129 then
                    if math.abs(pit_level - 121) <= math.abs(pit_level - 129) then
                        actual_address = 0x1D6D21
                    else
                        actual_address = 0x1D6D36
                    end
                else
                    if math.abs(pit_level - 129) <= math.abs(pit_level - 141) then
                        actual_address = 0x1D6D36
                    else
                        actual_address = 0x1D6D4E
                    end
                end

                utility.open_pit_portal(actual_address)
                last_open = get_time_since_inject()
            end
        else
            navigation:pathfind_to(enums.positions.obelisk_position)
        end
    end
}

return task

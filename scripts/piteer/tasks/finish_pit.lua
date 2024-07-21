local utils = require "core.utils"

local enums = require "data.enums"


local explorer = require "core.explorer"


local start_time = 0


local task = {

    name = "Finish Pit",

    shouldExecute = function()

        return utils.player_on_quest(enums.quests.pit_started) and 

               not utils.player_on_quest(enums.quests.pit_ongoing) and

               utils.loot_on_floor()

    end,

    Execute = function()

        if start_time == 0 then

            start_time = get_time_since_inject()

        end

        local items = loot_manager.get_all_items_chest_sort_by_distance()

        if #items > 0 then

            for _, item in pairs(items) do

                if loot_manager.is_lootable_item(item, true, false) then

                    explorer:set_custom_target(item)

                    -- interact_object(item) -- qqt note: fix stuck
					loot_manager.interact_with_object(item)

                end

            end

        end


        -- Check if 5 seconds have passed

        if get_time_since_inject() - start_time > 5 then

            start_time = 0  -- Reset the start time for the next execution

            return task

        end


        return task

    end

}


return task
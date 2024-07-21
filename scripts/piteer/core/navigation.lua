local utils = require "core.utils"
local explorer = require "core.explorer"
local navigation = {}

function navigation:move_to(target)
    target = target.get_position and target:get_position() or target
    local local_player = get_local_player()
    local destination = local_player:get_move_destination()

    if not local_player:is_moving() or utils.distance_to(destination) < 1 then
        pathfinder.request_move(target)
    end
end

function navigation:pathfind_to(target)
    target = target.get_position and target:get_position() or target

    explorer.set_custom_target(target)
end

return navigation

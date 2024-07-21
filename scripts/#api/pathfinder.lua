---@diagnostic disable: missing-return

--- @class pathfinder
pathfinder = {}

--- Moves to a specified position using custom pathfinder.
--- @param pos vec3
--- @return boolean
function pathfinder.move_to_cpathfinder(pos) end

--- Calculates and retrieves path points between start and goal.
--- @param start vec3
--- @param goal vec3
--- @return vec3[]
function pathfinder.calculate_and_get_path_points(start, goal) end

--- Moves to a specified position using custom pathfinder with full custom parameters.
--- @param pos vec3
--- @param algo_type number
--- @param batch_length number
--- @param circle_rad number
--- @param circular_precision number
--- @param max_algo_steps number
--- @param anti_stuck_rad number
--- @param anti_stuck_time number
--- @return boolean
function pathfinder.move_to_cpathfinder_custom_full(pos, algo_type, batch_length, circle_rad, circular_precision, max_algo_steps, anti_stuck_rad, anti_stuck_time) end

--- Moves to a specified position using custom pathfinder with A1 parameters.
--- @overload fun(pos:vec3, batch_length:number, circle_rad:number, max_algo_steps:number, anti_stuck_rad:number, anti_stuck_time:number):boolean
--- @param pos vec3
--- @param batch_length number
--- @param circle_rad number
--- @param max_algo_steps number
--- @return boolean
function pathfinder.move_to_cpathfinder_custom_a1(pos, batch_length, circle_rad, max_algo_steps) end

--- Moves to a specified position using custom pathfinder with A2 parameters.
--- @overload fun(pos:vec3, circular_precision:number, max_algo_steps:number, anti_stuck_rad:number, anti_stuck_time:number):boolean
--- @param pos vec3
--- @param circular_precision number
--- @param max_algo_steps number
--- @return boolean
function pathfinder.move_to_cpathfinder_custom_a2(pos, circular_precision, max_algo_steps) end

--- Clears the stored path in custom pathfinder.
--- @return nil
function pathfinder.clear_stored_path() end

--- Creates a path using the game engine to a specified position.
--- @param pos vec3
--- @return vec3[]
function pathfinder.create_path_game_engine(pos) end
--- Forces a move to a specified position.
--- @param pos vec3
--- @return boolean
function pathfinder.force_move(pos) end

--- Forces a raw move to a specified position.
--- @param pos vec3
--- @return boolean
function pathfinder.force_move_raw(pos) end

--- Requests a move to a specified position, only if the player is not already moving.
--- @param pos vec3
--- @return nil
function pathfinder.request_move(pos) end

--- Gets the next waypoint from the waypoint list based on current position and threshold.
--- @param pos vec3
--- @param waypoint_list vec3[]
--- @param threshold number
--- @return vec3
function pathfinder.get_next_waypoint(pos, waypoint_list, threshold) end
-- note: changed on july 20, 2024

--- @param point vec3
--- @param waypoint_list vec3[]
--- list of waypoints for example those you get from get_engine_waypoints
--- and then 2nd parameter for example player_position
function pathfinder.sort_waypoints(waypoint_list, point) end

--- @param value integer
-- this is the index used by pathfinder.get_next_waypoint as reference
-- useful to reset to 1, can be used for other things aswell
function pathfinder.set_last_waypoint_index(value) end

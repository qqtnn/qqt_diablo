---@diagnostic disable: missing-return

---@class warplan_node
---@field id number
---@field selected boolean
---@field neighbors table<number, number>

---@class warplan
warplan = {}

--- Check whether warplan data is ready.
--- @return boolean
function warplan.is_ready() end

--- Check whether the current warplan selection is complete.
--- @return boolean
function warplan.is_complete() end

--- Get the number of required picks.
--- @return number
function warplan.required_picks() end

--- Get the number of selected nodes.
--- @return number
function warplan.selected_count() end

--- Get the selected node path.
--- @return table<number, number>
function warplan.selected_path() end

--- Enumerate all available warplan nodes.
--- @return table<number, warplan_node>
function warplan.enumerate_nodes() end

--- Get a warplan node by ID.
--- @param id number
--- @return warplan_node|nil
function warplan.get_node(id) end

--- Get the display name of a warplan node.
--- @param id number
--- @return string
function warplan.node_name(id) end

--- Get the reward name of a warplan node.
--- @param id number
--- @return string
function warplan.node_reward_name(id) end

--- Get root node IDs.
--- @return table<number, number>
function warplan.get_root_node_ids() end

--- Get nodes that can be selected now.
--- @return table<number, number>
function warplan.get_selectable_now() end

--- Select a warplan node.
--- @param id number
--- @return boolean
function warplan.select_node(id) end

--- Deselect the last selected node.
--- @return boolean
function warplan.deselect_last() end

--- Confirm the current warplan selection.
function warplan.confirm() end

--- Teleport to the consumed or started warplan activity.
function warplan.teleport_to_activity() end

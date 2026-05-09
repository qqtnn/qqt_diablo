---@diagnostic disable: missing-return

---@class quest_reward_entry
---@field sno number
---@field internal_name string
---@field valid boolean

---@class quest_reward
quest_reward = {}

--- Check whether the quest reward selection UI is open.
--- @return boolean
function quest_reward.is_open() end

--- Get the currently selected quest reward index.
--- @return number
function quest_reward.selected_index() end

--- Enumerate available quest reward entries.
--- @return table<number, quest_reward_entry>
function quest_reward.enumerate() end

--- Select a quest reward by index.
--- @param index number
--- @return boolean
function quest_reward.select(index) end

--- Accept the currently selected quest reward.
--- @return boolean
function quest_reward.accept() end

--- Select and accept a quest reward by index.
--- @param index number
--- @return boolean
function quest_reward.pick_and_accept(index) end

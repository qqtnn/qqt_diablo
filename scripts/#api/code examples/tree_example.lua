-- =============================================================================
-- Quest Multi-Reward ("Choose Your Reward") - Lua API reference script
-- =============================================================================
-- The reward picker UI must be open in-game (e.g. after opening a reliquary or
-- bounty cache) for the API to return real data.
--
-- Open the cheat menu and use the "Quest Reward Example" tree:
--
--   Index slider     - which reward slot to act on (1..4 in the UI; the API is 0-indexed
--                      so this script subtracts 1 before calling)
--   Dump State       - prints the reward UI state to the console
--   Highlight        - calls select(index)         (highlight only, no commit)
--   Accept           - calls accept()              (commit the highlighted entry)
--   Pick And Accept  - calls pick_and_accept(idx)  (highlight + commit in one go)
--
-- Each action is a momentary checkbox: tick it once, the action fires, the box
-- clears itself. Same pattern as warplan_example.
--
-- All API entry points live on the global `quest_reward` table.
-- See #api/quest_reward.lua for full type signatures.
-- =============================================================================

local plugin_label = 'quest_reward_example'

local menu_elements = {
    main_tree = tree_node:new(0),

    -- 1..4 in the UI; we subtract 1 before calling the (0-indexed) API.
    index_slider = slider_int:new(1, 4, 1, get_hash(plugin_label .. '_index_slider')),

    trig_dump      = checkbox:new(false, get_hash(plugin_label .. '_trig_dump')),
    trig_highlight = checkbox:new(false, get_hash(plugin_label .. '_trig_highlight')),
    trig_accept    = checkbox:new(false, get_hash(plugin_label .. '_trig_accept')),
    trig_pick      = checkbox:new(false, get_hash(plugin_label .. '_trig_pick')),
}

-- ---------------------------------------------------------------------------
-- Actions
-- ---------------------------------------------------------------------------

local function dump_state()
    console.print("---- QUEST REWARD DUMP ----")

    if not quest_reward.is_open() then
        console.print("[qreward] closed - open a reward picker UI first.")
        return
    end

    local sel = quest_reward.selected_index()
    local entries = quest_reward.enumerate()
    console.print(string.format("[qreward] open. selected:%d  count:%d", sel, #entries))

    for i, e in ipairs(entries) do
        -- ipairs is 1-indexed; the API's selected_index is 0-indexed.
        local marker = (sel == i - 1) and "  <-- selected" or ""
        local name   = (e.internal_name ~= "") and e.internal_name or "<no name>"
        local valid  = e.valid and "valid" or "empty"
        console.print(string.format("  [%d] sno:%d  %s  (%s)%s",
            i - 1, e.sno, name, valid, marker))
    end
end

local function ui_index_to_api()
    -- slider is 1..4 for human eyes; API expects 0..3.
    return menu_elements.index_slider:get() - 1
end

local function highlight()
    if not quest_reward.is_open() then
        console.print("[qreward] closed - nothing to highlight.")
        return
    end
    local idx = ui_index_to_api()
    local ok = quest_reward.select(idx)
    console.print(string.format("[qreward] select(%d) -> %s", idx, tostring(ok)))
end

local function accept()
    if not quest_reward.is_open() then
        console.print("[qreward] closed - nothing to accept.")
        return
    end
    local ok = quest_reward.accept()
    console.print(string.format("[qreward] accept() -> %s", tostring(ok)))
end

local function pick_and_accept()
    if not quest_reward.is_open() then
        console.print("[qreward] closed - nothing to pick.")
        return
    end
    local idx = ui_index_to_api()
    local ok = quest_reward.pick_and_accept(idx)
    console.print(string.format("[qreward] pick_and_accept(%d) -> %s", idx, tostring(ok)))
end

-- ---------------------------------------------------------------------------
-- Menu
-- ---------------------------------------------------------------------------

on_render_menu(function()
    if not menu_elements.main_tree:push("Quest Reward Example") then
        return
    end

    menu_elements.index_slider:render("Index (1-4)",
        "Reward slot to act on. UI is 1-indexed; the API gets index - 1.")

    menu_elements.trig_dump:render("Dump State",
        "Tick to print the reward UI state to the console")
    menu_elements.trig_highlight:render("Highlight",
        "Tick to highlight the selected slot (no commit)")
    menu_elements.trig_accept:render("Accept",
        "Tick to commit the currently highlighted reward")
    menu_elements.trig_pick:render("Pick And Accept",
        "Tick to highlight the selected slot and commit it in one step")

    menu_elements.main_tree:pop()
end)

local function fire_if_set(cb, action)
    if cb:get() then
        cb:set(false)
        action()
    end
end

on_update(function()
    fire_if_set(menu_elements.trig_dump,      dump_state)
    fire_if_set(menu_elements.trig_highlight, highlight)
    fire_if_set(menu_elements.trig_accept,    accept)
    fire_if_set(menu_elements.trig_pick,      pick_and_accept)
end)

console.print("[quest_reward_example] loaded - see the 'Quest Reward Example' tree in the menu")

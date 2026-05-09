-- =============================================================================
-- War Plans (APS) - Lua API reference script
-- =============================================================================
-- Open the War Plans panel in-game first so the engine builds the data, then
-- open the cheat menu and use the "War Plans Example" tree:
--
--   Dump State       - prints the full war plan state to the console
--   Pick One         - selects the first legal option (one step)
--   Deselect Last    - pops the most-recently-picked node
--   Confirm          - sends the confirm packet (rejected if path incomplete)
--   Auto Walk        - clears the path and takes the required number of picks
--   Teleport         - teleports to a consumed/started war-plan activity
--
-- Each action is a momentary checkbox: tick it once, the action fires, and the
-- box clears itself. (We use checkboxes instead of `button` because the
-- button widget calls SetCursorScreenPos internally and stacking several of
-- them in a row corrupts the menu layout.)
--
-- All API entry points live on the global `warplan` table. See #api/warplan.lua
-- for the full type signatures.
-- =============================================================================

local plugin_label = 'warplan_example'

-- tree_node takes a DEPTH integer (0 = top-level, 1 = nested under a top-level, ...).
-- It is NOT a hash. Every other plugin uses small ints here.
local menu_elements = {
    main_tree     = tree_node:new(0),

    trig_dump      = checkbox:new(false, get_hash(plugin_label .. '_trig_dump')),
    trig_pick_one  = checkbox:new(false, get_hash(plugin_label .. '_trig_pick_one')),
    trig_pop_last  = checkbox:new(false, get_hash(plugin_label .. '_trig_pop_last')),
    trig_confirm   = checkbox:new(false, get_hash(plugin_label .. '_trig_confirm')),
    trig_auto_walk = checkbox:new(false, get_hash(plugin_label .. '_trig_auto_walk')),
    trig_teleport  = checkbox:new(false, get_hash(plugin_label .. '_trig_teleport')),
}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function ids_to_string(ids)
    if #ids == 0 then return "(none)" end
    local parts = {}
    for _, id in ipairs(ids) do
        local name = warplan.node_name(id)
        if name == "" then name = "?" end
        table.insert(parts, string.format("%d(%s)", id, name))
    end
    return table.concat(parts, ", ")
end

local function neighbor_to_string(n)
    -- engine uses values > 0x18 to mean "no edge"
    if n > 0x18 then return "--" end
    return tostring(n)
end

-- ---------------------------------------------------------------------------
-- Actions
-- ---------------------------------------------------------------------------

local function dump_state()
    console.print("---- WARPLAN DUMP ----")

    if not warplan.is_ready() then
        console.print("not ready - open the War Plans panel first.")
        return
    end

    local required = warplan.required_picks()
    local picked   = warplan.selected_count()
    console.print(string.format("picks: %d/%d  complete: %s",
        picked, required, tostring(warplan.is_complete())))

    console.print("selected path: " .. ids_to_string(warplan.selected_path()))
    console.print("roots:         " .. ids_to_string(warplan.get_root_node_ids()))
    console.print("legal next:    " .. ids_to_string(warplan.get_selectable_now()))

    console.print("nodes:")
    for _, n in ipairs(warplan.enumerate_nodes()) do
        local act = warplan.node_name(n.id)
        local rew = warplan.node_reward_name(n.id)
        console.print(string.format(
            "  id:%2d sel:%s  -> [%s, %s, %s]  act:%s  rew:%s",
            n.id, tostring(n.selected),
            neighbor_to_string(n.neighbors[1]),
            neighbor_to_string(n.neighbors[2]),
            neighbor_to_string(n.neighbors[3]),
            act ~= "" and act or "?",
            rew ~= "" and rew or "?"))
    end
end

local function pick_one()
    if not warplan.is_ready() then
        console.print("[warplan] not ready - open the panel first.")
        return
    end

    local legal = warplan.get_selectable_now()
    if #legal == 0 then
        console.print("[warplan] no legal picks available.")
        return
    end

    local pick = legal[1]
    if warplan.select_node(pick) then
        console.print(string.format("[warplan] picked id:%d (%s). path now: %s",
            pick, warplan.node_name(pick), ids_to_string(warplan.selected_path())))
    else
        console.print(string.format("[warplan] select_node(%d) refused.", pick))
    end
end

local function pop_last()
    if warplan.deselect_last() then
        console.print("[warplan] popped. path now: " .. ids_to_string(warplan.selected_path()))
    else
        console.print("[warplan] nothing to pop.")
    end
end

local function confirm()
    if not warplan.is_complete() then
        console.print(string.format(
            "[warplan] path is not complete (%d/%d) - server would reject. Aborting.",
            warplan.selected_count(), warplan.required_picks()))
        return
    end

    console.print("[warplan] confirming path: " .. ids_to_string(warplan.selected_path()))
    warplan.confirm()
end

local function teleport_to_activity()
    console.print("[warplan] teleporting to active war-plan activity")
    warplan.teleport_to_activity()
end

local function auto_walk()
    if not warplan.is_ready() then
        console.print("[warplan] not ready - open the panel first.")
        return
    end

    -- Clear the current path. The engine only allows last-out, so this naturally
    -- unwinds in reverse pick order.
    while warplan.selected_count() > 0 do
        if not warplan.deselect_last() then break end
    end

    local required = warplan.required_picks()
    for step = 1, required do
        local legal = warplan.get_selectable_now()
        if #legal == 0 then
            console.print(string.format("[warplan] step %d: no legal picks left, stopping.", step))
            break
        end

        local pick = legal[1]
        if not warplan.select_node(pick) then
            console.print(string.format("[warplan] step %d: select_node(%d) refused.", step, pick))
            return
        end
        console.print(string.format("[warplan] step %d: picked id:%d (%s)",
            step, pick, warplan.node_name(pick)))
    end

    console.print(string.format("[warplan] auto-walk done. complete:%s  path:%s",
        tostring(warplan.is_complete()),
        ids_to_string(warplan.selected_path())))
end

-- ---------------------------------------------------------------------------
-- Menu
-- ---------------------------------------------------------------------------

-- Render only -- never run actions in here. on_update fires the actions so
-- console.print spam never happens mid-render.
on_render_menu(function()
    if not menu_elements.main_tree:push("War Plans Example") then
        return
    end

    menu_elements.trig_dump:render("Dump State",
        "Tick to print the full war plan state to the console")
    menu_elements.trig_pick_one:render("Pick One",
        "Tick to select the first legal option (one step)")
    menu_elements.trig_pop_last:render("Deselect Last",
        "Tick to pop the most-recently-selected node")
    menu_elements.trig_confirm:render("Confirm",
        "Tick to send the confirm packet (rejected if path incomplete)")
    menu_elements.trig_auto_walk:render("Auto Walk",
        "Tick to clear the path and take the required number of picks")
    menu_elements.trig_teleport:render("Teleport To Activity",
        "Tick to teleport to a consumed/started war-plan activity")

    menu_elements.main_tree:pop()
end)

-- Trigger dispatch -- runs OUTSIDE the render pass.
local function fire_if_set(cb, action)
    if cb:get() then
        cb:set(false)   -- consume the click immediately so the action fires once
        action()
    end
end

on_update(function()
    fire_if_set(menu_elements.trig_dump,      dump_state)
    fire_if_set(menu_elements.trig_pick_one,  pick_one)
    fire_if_set(menu_elements.trig_pop_last,  pop_last)
    fire_if_set(menu_elements.trig_confirm,   confirm)
    fire_if_set(menu_elements.trig_auto_walk, auto_walk)
    fire_if_set(menu_elements.trig_teleport,  teleport_to_activity)
end)

console.print("[warplan_example] loaded - see the 'War Plans Example' tree in the menu")

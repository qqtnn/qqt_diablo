-- =============================================================================
-- Fishing example plugin
-- =============================================================================
-- Stand at a fishing spot in-game, then enable "Auto Fish" in the menu.
--
-- State machine (one cycle):
--   1. cast fishing rod  (spell 2123306)
--   2. each frame, check if a buff with type == REEL_BUFF_TYPE exists on the
--      local player. when it does, a fish bit -> reel.
--   3. reel back  (cast spell 2111034 once)
--   4. brief settle delay, then back to step 1
-- =============================================================================

console.print("[fishing_example] script loading...")

local plugin_label = 'fishing_example'

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------

local FISHING_CAST_SPELL = 2123306
local FISHING_REEL_SPELL = 2111034

-- The presence of any buff with this `type` value means the line was bitten
-- and the player should reel.
local REEL_BUFF_TYPE     = 1248780927

local POST_CAST_LOCKOUT  = 1.0   -- min seconds in 'polling' before we trust the bite check
local REEL_SETTLE_TIME   = 1.5   -- seconds after reel before next cycle

-- ---------------------------------------------------------------------------
-- Menu
-- ---------------------------------------------------------------------------

local menu_elements = {
    main_tree      = tree_node:new(0),
    enable_toggle  = checkbox:new(false, get_hash(plugin_label .. '_enable')),
    verbose_toggle = checkbox:new(false, get_hash(plugin_label .. '_verbose')),
}

on_render_menu(function()
    if not menu_elements.main_tree:push("Fishing Example") then
        return
    end
    menu_elements.enable_toggle:render("Auto Fish",
        "Cycle: cast rod -> watch for reel-buff -> reel -> repeat")
    menu_elements.verbose_toggle:render("Verbose",
        "Print heartbeat + cast/poll diagnostics to the console (noisy)")
    menu_elements.main_tree:pop()
end)

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function has_reel_buff(local_player)
    if not local_player then return false end
    local buffs = local_player:get_buffs()
    if not buffs then return false end
    for _, b in ipairs(buffs) do
        if b.type == REEL_BUFF_TYPE then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- State machine
-- ---------------------------------------------------------------------------
local state = {
    name    = 'idle',
    started = 0,
}

local function transition(new_name)
    state.name    = new_name
    state.started = get_time_since_inject()
    console.print("[fishing] -> " .. new_name)
end

local last_heartbeat = 0

on_update(function()
    local local_player = get_local_player()
    if not local_player then return end

    local now      = get_time_since_inject()
    local enabled  = menu_elements.enable_toggle:get()
    local verbose  = menu_elements.verbose_toggle:get()

    if verbose and now - last_heartbeat >= 1.0 then
        last_heartbeat = now
        console.print(string.format(
            "[fishing] heartbeat: enabled=%s state=%s",
            tostring(enabled), state.name))
    end

    if not enabled then
        if state.name ~= 'idle' then transition('idle') end
        return
    end

    local elapsed = now - state.started

    if state.name == 'idle' then
        local ok = cast_spell.self(FISHING_CAST_SPELL, 0)
        if verbose then
            console.print("[fishing] cast_spell.self(rod) -> " .. tostring(ok))
        end
        if ok then
            transition('polling')
        end

    elseif state.name == 'polling' then
        -- short lockout so we don't act on stale state from the previous cycle
        if elapsed < POST_CAST_LOCKOUT then return end

        if has_reel_buff(local_player) then
            console.print("[fishing] BITE! reel-buff detected. reeling.")
            local ok = cast_spell.self(FISHING_REEL_SPELL, 0)
            if verbose then
                console.print("[fishing] cast_spell.self(reel) -> " .. tostring(ok))
            end
            transition('reeling')
        end

    elseif state.name == 'reeling' then
        if elapsed >= REEL_SETTLE_TIME then
            transition('idle')
        end
    end
end)

console.print("[fishing_example] loaded - tick 'Auto Fish' in the 'Fishing Example' tree")

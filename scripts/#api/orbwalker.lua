---@diagnostic disable: missing-return

--- @class orb_mode
orb_mode = {
    none = 1,
    pvp = 2,
    clear = 3,
    flee = 4
}

--- @class orbwalker
orbwalker = {}

--- Gets the current orbwalker mode.
--- @return orb_mode The current orbwalker mode.
function orbwalker.get_orb_mode() end

--- @return nil
--- @param mode orb_mode | number
function orbwalker.set_orbwalker_mode(mode) end

--- @return nil
--- @param value boolean
function orbwalker.set_block_movement(value) end

--- @return nil
--- @param value boolean
function orbwalker.set_auto_loot_toggle(value) end

--- @return nil
--- @param value boolean
function orbwalker.set_clear_toggle(value) end

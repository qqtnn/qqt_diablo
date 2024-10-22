---@diagnostic disable: missing-return, duplicate-set-field

--- @class cast_spell
cast_spell = {}

--- Casts a spell on the player themselves.
--- @param spell_id number The ID of the spell.
--- @param animation_time number The time it takes for the spell to animate.
--- @return boolean Returns true if the spell was cast successfully, false otherwise.
cast_spell.self = function(spell_id, animation_time) end

--- Casts a spell on a target object.
--- @overload fun(target:game.object, spell_id:number, animation_time:number, is_debug_mode:boolean):boolean
--- @param target game.object The target object to cast the spell on.
--- @param spell_id number The ID of the spell.
--- @param animation_time number The time it takes for the spell to animate.
--- @param is_debug_mode boolean Whether to run in debug mode.
--- @return boolean Returns true if the spell was cast successfully, false otherwise.
cast_spell.target = function(target, spell_id, animation_time, is_debug_mode) end

--- Casts a spell on a target object using spell data.
--- @param target game.object The target object to cast the spell on.
--- @param spell_data prediction.spell_data The data of the spell.
--- @param is_debug_mode boolean Whether to run in debug mode.
--- @return boolean Returns true if the spell was cast successfully, false otherwise.
cast_spell.target = function(target, spell_data, is_debug_mode) end

--- Casts a spell at a specific position.
--- @param spell_id number The ID of the spell.
--- @param position vec3 The position to cast the spell at.
--- @param animation_time ?number The time it takes for the spell to animate.
--- @return boolean Returns true if the spell was cast successfully, false otherwise.
cast_spell.position = function(spell_id, position, animation_time) end

--- Adds a channel spell with optional parameters.
--- @param spell_id number The ID of the spell.
--- @param start_time ?number Optional start time. If not provided, starts immediately.
--- @param finish_time ?number Optional finish time. If not provided, set as undefined (0).
--- @param cast_target ?game.object Optional target object.
--- @param cast_position ?vec3 Optional position to cast the spell at.
--- @param animation_time ?number Optional animation time.
--- @param interval ?number Optional interval between casts.
cast_spell.add_channel_spell = function(spell_id, start_time, finish_time, cast_target, cast_position, animation_time, interval) end

--- Pauses all channel spells.
--- @param pause_duration number The duration of the pause in seconds.
cast_spell.pause_all_channel_spells = function(pause_duration) end

--- Pauses a specific channel spell by ID.
--- @param spell_id number The ID of the spell to pause.
--- @param pause_duration number The duration of the pause in seconds.
cast_spell.pause_specific_channel_spell = function(spell_id, pause_duration) end

--- Checks if a specific channel spell is currently active.
--- @param spell_id number The ID of the spell to check.
--- @return boolean Returns true if the spell is active, false otherwise.
cast_spell.is_channel_spell_active = function(spell_id) end

--- Updates the target of a specific channel spell by ID.
--- @param spell_id number The ID of the spell to update.
--- @param new_target game.object The new target object.
cast_spell.update_channel_spell_target = function(spell_id, new_target) end

--- Updates the position of a specific channel spell by ID.
--- @param spell_id number The ID of the spell to update.
--- @param new_position vec3 The new position to cast the spell at.
cast_spell.update_channel_spell_position = function(spell_id, new_position) end

--- Updates the finish time of a specific channel spell by ID.
--- @param spell_id number The ID of the spell to update.
--- @param new_finish_time number The new finish time.
cast_spell.update_channel_spell_finish_time = function(spell_id, new_finish_time) end

--- Updates the start time of a specific channel spell by ID.
--- @param spell_id number The ID of the spell to update.
--- @param new_start_time number The new start time.
cast_spell.update_channel_spell_start_time = function(spell_id, new_start_time) end

--- Updates the animation time of a specific channel spell by ID.
--- @param spell_id number The ID of the spell to update.
--- @param new_animation_time number The new animation time.
cast_spell.update_channel_spell_animation_time = function(spell_id, new_animation_time) end

--- Updates the interval of a specific channel spell by ID.
--- @param spell_id number The ID of the spell to update.
--- @param new_interval number The new interval time.
cast_spell.update_channel_spell_interval = function(spell_id, new_interval) end

--- Removes a specific channel spell by ID.
--- @param spell_id number The ID of the spell to remove.
cast_spell.remove_channel_spell = function(spell_id) end

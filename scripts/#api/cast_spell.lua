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

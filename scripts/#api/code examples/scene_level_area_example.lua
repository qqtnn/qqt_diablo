local w = get_current_world()
if w then
    local scene = w:get_scene_for_position(player_pos)
    if scene then
        print(scene:get_name(), scene:get_scene_id())

        local la = scene:get_level_area_for_position(cursor_pos)
        if la then
            print(la:get_name(), la:get_id())
        end
    end
end

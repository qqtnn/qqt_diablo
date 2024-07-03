---@diagnostic disable: missing-return
---@class graphics
graphics = {}

--- Draws a filled circle in 2D space.
--- @param pos vec2 Position of the center of the circle.
--- @param rad number Radius of the circle.
--- @param col ImColor Color of the circle.
graphics.circle_filled_2d = function(pos, rad, col) end

--- Draws a circle in 2D space.
--- @overload fun(position:vec3, radius:number, color:ImColor):nil
--- @param position vec2 Position of the center of the circle.
--- @param radius number Radius of the circle.
--- @param color ImColor Color of the circle.
--- @param thickness number? Thickness of the circle's line.
graphics.circle_2d = function(position, radius, color, thickness) end

--- Draws 3D text at a specified position.
--- @param text string Text to be displayed.
--- @param pos vec3 Position for the text.
--- @param size number Font size of the text.
--- @param col ImColor Color of the text.
graphics.text_3d = function(text, pos, size, col) end

--- Draws 2D text at a specified point.
--- @param text string Text to be displayed.
--- @param point vec2 2D coordinates for the text.
--- @param size number Font size of the text.
--- @param color ImColor Color of the text.
graphics.text_2d = function(text, point, size, color) end

--- Draws a 3D circle.
--- @overload fun(position:vec3, radius:number, color:ImColor, thickness:number):nil
--- @param position vec3 Center position of the circle.
--- @param radius number Radius of the circle.
--- @param color ImColor Color of the circle.
--- @param thickness number? Thickness of the circle's line.
--- @param segments number? Number of segments to draw the circle. Optional.
graphics.circle_3d = function(position, radius, color, thickness, segments) end

--- Draws a line between two points.
--- @param from vec2|vec3 Starting point of the line.
--- @param to vec2|vec3 Ending point of the line.
--- @param col ImColor Color of the line.
--- @param thickness number Thickness of the line.
graphics.line = function(from, to, col, thickness) end

--- Draws a rectangle.
--- @param from vec2 Starting point of the rectangle.
--- @param to vec2 Ending point of the rectangle.
--- @param col ImColor Color of the rectangle.
--- @param rounding number Rounding of the rectangle corners.
--- @param thickness number Thickness of the rectangle's line.
graphics.rect = function(from, to, col, rounding, thickness) end

--- Draws a filled rectangle.
--- @param from vec2 Starting point of the rectangle.
--- @param to vec2 Ending point of the rectangle.
--- @param col ImColor Color of the rectangle.
graphics.rect_filled = function(from, to, col) end

-- --- Loads an image from a specified path.
-- --- @param img_path string Path to the image file.
-- --- @return dx12.loaded_image Loaded image object.
-- graphics.load_image = function(img_path) end

-- --- Draws an image at a specified position.
-- --- @param img dx12.loaded_image Image to draw.
-- --- @param pos vec2 Position to draw the image.
-- graphics.draw_image = function(img, pos) end

--- Converts world coordinates to screen coordinates.
--- @param from vec3 World coordinates to convert.
--- @return vec2 Converted screen coordinates.
graphics.w2s = function(from) end

--- Draws a 3D rectangle.
--- @param from vec3 Starting point of the rectangle.
--- @param to vec3 Ending point of the rectangle.
--- @param width number Width of the rectangle.
--- @param color ImColor Color of the rectangle.
--- @param thickness number Thickness of the rectangle's line.
graphics.rect_3d = function(from, to, width, color, thickness) end

--- Sets special constraints for the menu size.
--- @param max vec2 Maximum size constraints.
--- @param min vec2 Minimum size constraints.
graphics.set_menu_constraints_special_fnc = function(max, min) end

---@diagnostic disable: undefined-global, missing-return, duplicate-set-field

--- Define the global classes
_G.button = {}
_G.colorpicker = {}
_G.checkbox = {}
_G.keybind = {}
_G.combo_box = {}
_G.input_text = {}
_G.slider_int = {}
_G.slider_float = {}
_G.tree_node = {}

--- @class button
--- @field render fun(self:button, msg:string, tooltip:string, button_activation_delay:number):nil Renders the button
--- @field get fun(self:button):boolean Returns the button state
--- @field set_id fun(self:button, id:number):nil Sets the button ID
--- @field get_full fun(self:button):string Returns full button info
--- @field new fun(id:number):button Creates a new button

--- Creates a new button
--- @param id number
--- @return button
function button:new(id) end

--- Renders the button
--- @param self button
--- @param msg string
--- @param tooltip string
--- @param button_activation_delay number
function button:render(msg, tooltip, button_activation_delay) end

--- Returns the button state
--- @param self button
--- @return boolean
function button:get() end

--- Sets the button ID
--- @param self button
--- @param id number
function button:set_id(id) end

--- Returns full button info
--- @param self button
--- @return string
function button:get_full() end

--- @class colorpicker
--- @field render fun(self:colorpicker, label:string, tooltip:string, show_on_button_press:boolean, button_label:string, button_tooltip:string):nil Renders the color picker
--- @field get fun(self:colorpicker):ImVec4 Returns the selected color
--- @field set fun(self:colorpicker, color:ImVec4):nil Sets the color
--- @field new fun(id:number):colorpicker, fun(id:number, color:ImVec4):colorpicker, fun(id:number, r:number, g:number, b:number, a:number):colorpicker Creates a new color picker

--- Creates a new color picker
--- @param id number
--- @return colorpicker
function colorpicker:new(id) end

--- Creates a new color picker with color
--- @param id number
--- @param color ImVec4
--- @return colorpicker
function colorpicker:new(id, color) end

--- Creates a new color picker with RGBA values
--- @param id number
--- @param r number
--- @param g number
--- @param b number
--- @param a number
--- @return colorpicker
function colorpicker:new(id, r, g, b, a) end

--- Renders the color picker
--- @param self colorpicker
--- @param label string
--- @param tooltip string
--- @param show_on_button_press boolean
--- @param button_label string
--- @param button_tooltip string
function colorpicker:render(label, tooltip, show_on_button_press, button_label, button_tooltip) end

--- Returns the selected color
--- @param self colorpicker
--- @return ImVec4
function colorpicker:get() end

--- Sets the color
--- @param self colorpicker
--- @param color ImVec4
function colorpicker:set(color) end

--- @class checkbox
--- @field render fun(self:checkbox, label:string, tooltip:string):nil Renders the checkbox
--- @field get fun(self:checkbox):boolean Returns the checkbox state
--- @field set fun(self:checkbox, state:boolean):nil Sets the checkbox state
--- @field new fun(state:boolean, id:number):checkbox Creates a new checkbox

--- Creates a new checkbox
--- @param state boolean
--- @param id number
--- @return checkbox
function checkbox:new(state, id) end

--- Renders the checkbox
--- @param self checkbox
--- @param label string
--- @param tooltip string
function checkbox:render(label, tooltip) end

--- Returns the checkbox state
--- @param self checkbox
--- @return boolean
function checkbox:get() end

--- Sets the checkbox state
--- @param self checkbox
--- @param state boolean
function checkbox:set(state) end

--- @class keybind
--- @field render fun(self:keybind, label:string, tooltip:string):nil Renders the keybind
--- @field get_state fun(self:keybind):boolean Returns if the key is pressed
--- @field get_key fun(self:keybind):number Returns the key code
--- @field set fun(self:keybind, state:boolean):nil Sets the keybind state
--- @field new fun(key:number, state:boolean, id:number):keybind Creates a new keybind

--- Creates a new keybind
--- @param key number
--- @param state boolean
--- @param id number
--- @return keybind
function keybind:new(key, state, id) end

--- Renders the keybind
--- @param self keybind
--- @param label string
--- @param tooltip string
function keybind:render(label, tooltip) end

--- Returns if the key is pressed
--- Note: Keep in mind it does return 0 or 1, instead of false or true
--- @param self keybind
--- @return integer
function keybind:get_state() end

--- Returns the key code
--- @param self keybind
--- @return number
function keybind:get_key() end

--- Sets the keybind state
--- @param self keybind
--- @param state boolean
function keybind:set(state) end

--- @class combo_box
--- @field render fun(self:combo_box, msg:string, items_table:table, tooltip:string):nil Renders the combo box
--- @field get fun(self:combo_box):number Returns the selected index
--- @field set fun(self:combo_box, index:number):nil Sets the selected index
--- @field new fun(index:number, id:number):combo_box Creates a new combo box

--- Creates a new combo box
--- @param index number
--- @param id number
--- @return combo_box
function combo_box:new(index, id) end

--- Renders the combo box
--- @param self combo_box
--- @param msg string
--- @param items_table table
--- @param tooltip string
function combo_box:render(msg, items_table, tooltip) end

--- Returns the selected index
--- @param self combo_box
--- @return number
function combo_box:get() end

--- Sets the selected index
--- @param self combo_box
--- @param index number
function combo_box:set(index) end

--- @class input_text
--- @field render fun(self:input_text, label:string, tooltip:string, require_button:boolean, button_label:string, button_tooltip:string):nil Renders the input text
--- @field is_open fun(self:input_text):boolean Returns if the input is open
--- @field get fun(self:input_text):string Returns the input text
--- @field get_in_vec3 fun(self:input_text):vec3 Returns the input as a vec3
--- @field new fun(id:number):input_text Creates a new input text

--- Creates a new input text
--- @param id number
--- @return input_text
function input_text:new(id) end

--- Renders the input text
--- @param self input_text
--- @param label string
--- @param tooltip string
--- @param require_button boolean
--- @param button_label string
--- @param button_tooltip string
function input_text:render(label, tooltip, require_button, button_label, button_tooltip) end

--- Returns if the input is open
--- @param self input_text
--- @return boolean
function input_text:is_open() end

--- Returns the input text
--- @param self input_text
--- @return string
function input_text:get() end

--- Returns the input as a vec3
--- @param self input_text
--- @return vec3
function input_text:get_in_vec3() end

--- @class slider_int
--- @field render fun(self:slider_int, label:string, tooltip:string):nil Renders the integer slider
--- @field get fun(self:slider_int):number Returns the slider value
--- @field new fun(min:number, max:number, value:number, id:number):slider_int Creates a new integer slider

--- Creates a new integer slider
--- @param min number
--- @param max number
--- @param value number
--- @param id number
--- @return slider_int
function slider_int:new(min, max, value, id) end

--- Renders the integer slider
--- @param self slider_int
--- @param label string
--- @param tooltip string
function slider_int:render(label, tooltip) end

--- Returns the slider value
--- @param self slider_int
--- @return number
function slider_int:get() end

--- @class slider_float
--- @field render fun(self:slider_float, label:string, tooltip:string, rounding:number):nil Renders the float slider
--- @field get fun(self:slider_float):number Returns the slider value
--- @field new fun(min:number, max:number, value:number, id:number):slider_float Creates a new float slider

--- Creates a new float slider
--- @param min number
--- @param max number
--- @param value number
--- @param id number
--- @return slider_float
function slider_float:new(min, max, value, id) end

--- Renders the float slider
--- @param self slider_float
--- @param label string
--- @param tooltip string
--- @param rounding number
function slider_float:render(label, tooltip, rounding) end

--- Returns the slider value
--- @param self slider_float
--- @return number
function slider_float:get() end

--- @class tree_node
--- @field push fun(self:tree_node, name:string):boolean Opens a tree node
--- @field pop fun(self:tree_node):nil Closes a tree node
--- @field is_open fun(self:tree_node):boolean Returns if the node is open
--- @field new fun(id:number):tree_node Creates a new tree node

--- Creates a new tree node
--- @param id number
--- @return tree_node
function tree_node:new(id) end

--- Opens a tree node
--- @param self tree_node
--- @param name string
--- @return boolean
function tree_node:push(name) end

--- Closes a tree node
--- @param self tree_node
function tree_node:pop() end

--- Returns if the node is open
--- @param self tree_node
--- @return boolean
function tree_node:is_open() end

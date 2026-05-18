-- =============================================================================
-- curl example plugin (async)
-- =============================================================================
-- Demonstrates the curl bindings exposed by the host:
--   ok = curl.http_get(url, callback, headers?, timeout_sec?)
--   ok = curl.http_post(url, body, callback, headers?, timeout_sec?)
--
--   callback signature: function(body, status, err)
--     body   string  - response body (empty on transport error)
--     status number  - HTTP status code (0 on transport error)
--     err    string  - curl error string ("" on success)
--
-- headers is a lua table of { ["Header-Name"] = "Value", ... } (optional)
-- timeout_sec is a number, default 30 (optional)
--
-- Requests are queued and processed by the host every frame. The callback is
-- invoked on the game thread once the transfer completes - the call itself
-- never blocks.
-- =============================================================================

console.print("[curl_example] script loading...")

local plugin_label = 'curl_example'

local menu_elements = {
    main_tree   = tree_node:new(0),
    get_button  = button:new(get_hash(plugin_label .. '_get')),
    post_button = button:new(get_hash(plugin_label .. '_post')),
}

local function clip(s, n)
    if not s then return "<nil>" end
    if #s <= n then return s end
    return s:sub(1, n) .. "...(+" .. (#s - n) .. " bytes)"
end

local function on_response(label)
    return function(body, status, err)
        if err ~= "" then
            console.print(string.format("[curl_example] %s error: %s", label, err))
            return
        end
        console.print(string.format("[curl_example] %s status=%d bytes=%d",
            label, status, #body))
        console.print("[curl_example] body: " .. clip(body, 300))
    end
end

local function do_get()
    local url = "https://httpbin.org/get?from=curl_example"
    console.print("[curl_example] GET " .. url)

    local queued = curl.http_get(url, on_response("GET"), {
        ["Accept"]   = "application/json",
        ["X-Plugin"] = plugin_label,
    }, 10.0)

    if not queued then
        console.print("[curl_example] failed to queue GET request")
    end
end

local function do_post()
    local url     = "https://httpbin.org/post"
    local payload = '{"plugin":"curl_example","time":' .. tostring(get_time_since_inject()) .. '}'

    console.print("[curl_example] POST " .. url .. " body=" .. payload)

    local queued = curl.http_post(url, payload, on_response("POST"), {
        ["Content-Type"] = "application/json",
        ["Accept"]       = "application/json",
    }, 10.0)

    if not queued then
        console.print("[curl_example] failed to queue POST request")
    end
end

on_render_menu(function()
    if not menu_elements.main_tree:push("Curl Example") then
        return
    end

    menu_elements.get_button:render("HTTP GET httpbin.org",
        "Async GET. Queues the request; callback prints status + body when done.", 0.0)
    if menu_elements.get_button:get() then
        do_get()
    end

    menu_elements.post_button:render("HTTP POST httpbin.org",
        "Async POST with JSON body. Callback prints status + body when done.", 0.0)
    if menu_elements.post_button:get() then
        do_post()
    end

    menu_elements.main_tree:pop()
end)

console.print("[curl_example] loaded - open the 'Curl Example' tree and click a button")

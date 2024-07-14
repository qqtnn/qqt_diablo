-- failsafe to not run script early or during loading screens
local local_player = get_local_player()
if local_player == nil then 
    return
end

-- used to create ingame menu via LUA scripting engine, merges with menu.lua
local menu = require("menu")
-- tick rate for on_update() logic (does not affect on_render())
local last_update_time = 0
-- used to check if current zone is running active helltide
local player_in_helltide_zone = 0
-- used to check if player is already mounted
local did_mount_player = 0
-- iterator for helltide_tps
local helltide_tps_iter = 1
-- current helltide zone name
local helltide_zone_name = "Unknown"
-- if is target waypoint maiden location is pinned on map already
local helltide_zone_pin = 0
-- stored final maidenpos for map pin
local helltide_final_maidenpos = nil
local helltide_tps_next_zone_name = ""
-- internal app finish state
local helltide_maiden_arrivalstate = 0
-- custom waypoint list to walk to helltide maiden boss for EACH helltide_tps
-- running with custom waypoint list to hopefully not get stuck and it is way faster then dynamically going there
-- will be filled dynamically based on helltide_zone_name
local maidenpos = {}
-- vec3 next position
local pathfinder_nextpos = nil
-- vec3 previous position
local pathfinder_prevpos = nil
-- vec3 last position to allow checking for being stuck
local distance_check_distance = 0
local distance_check_last_player_position = nil
local distance_check_last_time = 0
local distance_check_is_stuck = 0
local distance_check_is_stuck_counter = 0
local distance_check_is_stuck_first_time = 0
-- available app tasks
local helltide_maiden_auto_tasks = {
    FIND_ZONE = "Trying to find helltide zone using teleporter",
    IN_TELEPORT = "Waiting for teleporter to finish",
    FOUND_ZONE = "Found helltide zone, walking to maiden",
    FOUND_ZONE_STUCK = "Found helltide zone, walking to maiden - WARNING: Pathfinder stuck detected, running alternative",
    ARRIVED = "Arrived at helltide maiden",
    INSERT = "Inserting heart to spawn helltide maiden",
    LOOT = "Looting items",
    REPAIR = "Auto-Play REPAIR",
    SELLSALVAGE = "Auto-Play SELL OR SALVAGE"
}
-- current running app task
local helltide_maiden_auto_task = helltide_maiden_auto_tasks.FIND_ZONE
-- helper text window at arival
local show_helper_text_time_up = nil
-- enable or disable explorer at helltide maiden
local run_explorer = 0
local run_explorer_is_close = 0
local run_explorer_modes = {
    OFF = "Disabled",
    CLOSERANDOM = "Enabled - Run to close/distance enemies then use random position",
    RANDOM = "Enabled - Run to random positions and ignore enemies"
}
-- current running explorer mode
local run_explorer_mode = run_explorer_modes.OFF
local explorer_points = nil
local explorer_point = nil
local explorer_go_next = 1
local explorer_threshold = 0.0
local explorer_thresholdvar = 0.0
local last_explorer_threshold_check = 0
local explorer_circle_radius = 1.0
local explorer_circle_radius_prev = 0.0
-- tick rate to insert hearts to spawn helltide Maiden
local insert_hearts = 0
local insert_hearts_afterboss = 0
local insert_hearts_time = 0
-- tick rate after put hearts 10seconds to give chance to insert before restarting explorer logic
local insert_hearts_waiter = 0
local insert_hearts_waiter_interval = 10.0
local insert_hearts_waiter_elapsed = 0
local old_currenthearts = 0
local last_insert_hearts_waiter_time = 0
local seen_boss_dead = 0
local seen_boss_dead_time = 0
local seen_enemies = 0
local last_seen_enemies_elapsed = 0
local insert_only_with_npcs_playercount = 0

-- helper function to reset app variables, try to find next closes point and re-start app logic e.g. being at helltide maiden boss
local function reset_helltide_maiden()
    player_in_helltide_zone = 0
    helltide_zone_pin = 0
    -- helltide_tps_iter = 1
    -- helltide_tps_next_zone_name = ""
    helltide_zone_name = "Unknown"
    helltide_maiden_auto_task = helltide_maiden_auto_tasks.FIND_ZONE
    helltide_maiden_arrivalstate = 0
    pathfinder_nextpos = nil
    pathfinder_prevpos = nil
    distance_check_distance = 0
    distance_check_last_player_position = nil
    distance_check_last_time = 0
    distance_check_is_stuck = 0
    distance_check_is_stuck_counter = 0
    distance_check_is_stuck_first_time = 0
    helltide_final_maidenpos = nil
    show_helper_text_time_up = nil
    maidenpos = {}
    pathfinder.clear_stored_path()
    run_explorer_mode = run_explorer_modes.OFF
    explorer_points = nil
    explorer_go_next = 1
    run_explorer_is_close = 0
    explorer_point = nil
    last_explorer_threshold_check = 0
    insert_hearts_time = 0
    insert_hearts_waiter = 0
    insert_hearts_waiter_elapsed = 0
    last_insert_hearts_waiter_time = 0
    seen_boss_dead = 0
    seen_boss_dead_time = 0
    seen_enemies = 0
    last_seen_enemies_elapsed = 0
    insert_only_with_npcs_playercount = 0
    -- current_mount_state = 0
    -- do_a_mount_or_unmount_once = 0
    -- do_a_mount_last_time = 0
    -- do_repair_next = 0
    -- is_repair_next = 0
    -- is_sellsalv_next = 0
end

-- helper function to count enum sizes / lengthes of tables
local function table_length(table_in)
    local count = 0
    for _ in pairs(table_in) do
        count = count + 1
    end
    return count
end

-- helper function to math.round with decimal support, LUA does not have the most basics ;-)
local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- helper function to receive random element from table
function random_element(tb)
    local keys = {}
    for k in pairs(tb) do
        table.insert(keys, k)
    end
    return tb[keys[math.random(#keys)]]
end

-- helper function to find positions within circle (Credits: QQT)
local function get_positions_in_radius(center_point, radius)
    local positions = {}
    local radius_squared = radius * radius
    local insert = {}
    insert = table.insert
    local center_x = center_point:x()
    local center_y = center_point:y()
    local center_z = center_point:z()

    for x = -radius, radius do
        local x_pos = center_x + x
        local x_squared = x * x
        for y = -radius, radius do
            local y_pos = center_y + y
            local y_squared = y * y
            local z_max_squared = radius_squared - x_squared - y_squared
            if z_max_squared >= 0 then
                local z_max = math.floor(math.sqrt(z_max_squared))
                for z = -z_max, z_max do
                    insert(positions, vec3:new(x_pos, y_pos, center_z + z))
                end
            end
        end
    end

    return positions
end

-- helltide TP locations
-- only with supported waypoints (TP target must directly lead to helltide zones, sometimes that is not the case and you have to walk, these tp waypoints are not supported, it doesnt matter since you will still hit all helltide zones any time with atleast one valid teleporter - but you will never seen some particular maiden using this logic)
local helltide_tps = {
    {name = "Menestad (internal name: Frac_Tundra_S)", id = 0xACE9B},
    {name = "Marowen (internal name: Scos_Coast)", id = 0x27E01},
    {name = "Iron Wolves Encampment (internal name: Kehj_Oasis/Kehj_HighDesert)", id = 0xDEAFC},
    {name = "Wejinhani (internal name: Hawe_Verge)", id = 0x9346B},
    {name = "Ruins of Rakhat Keep Inner Court (internal name: Hawe_ZakFort)", id = 0xF77C2},
    {name = "Jirandai (internal name: Step_South)", id = 0x462E2}
}

local loading_start_time = nil
-- helper function to teleport to next waypoint looping all hellpoint_tps
local function tp_to_next()
    -- console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - called")
    
    -- do not jump when already jumping
    local current_time = os.clock()
    local current_world = world.get_current_world()
    if not current_world then
        return
    end

    -- we are in limbo loading screen
    if current_world:get_name():find("Limbo") then
        -- If we are in limbo, set the loading start time
        if not loading_start_time then
            loading_start_time = current_time
        end
        return
    else
        -- If we were in limbo, but now we are not, check if 4 seconds have passed since loading started
        if loading_start_time and (current_time - loading_start_time) < 4 then
            return
        end
        -- Reset loading start time after waiting
        loading_start_time = nil
    end

    -- teleport to next waypoint from helltide_tps
    for i in pairs(helltide_tps) do
        if i == helltide_tps_iter then
            console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - teleporting to helltide_tps_iter = " .. helltide_tps_iter .. " Zone Name = " .. helltide_tps[i].name .. " ID = " .. helltide_tps[i].id)
            helltide_tps_next_zone_name = helltide_tps[i].name
            -- teleport to waypoint
            teleport_to_waypoint(helltide_tps[i].id)
            -- make sure we increment to next waypoint for next run, we dont want to jump again here
            helltide_tps_iter = helltide_tps_iter + 1
            -- when found we are done
            break
        end
    end

    -- check if we reached the end of available waypoint TPs, then we start over from the beginning
    local length_helltide_tps = table_length(helltide_tps)
    if helltide_tps_iter > length_helltide_tps then
        -- reset current tp iterator will loop back to start
        helltide_tps_iter = 1
    end
end


-- load fixed waypoint list for each helltide zone maiden boss depending on current helltide zone
local function maidenpos_load()
    -- failsafe to not run script early or during loading screens
    local local_player = get_local_player()
    if not local_player then
        return
    end
    -- get current player position vec3 x,y,z
    local player_position = local_player:get_position()
    if not player_position then
        return
    end

    -- console.print("[HELLTIDE-MAIDEN-AUTO] maidenpos_load() - LOADING maidenpos for helltide zone = " .. helltide_zone_name)
    local maidenpos_length = 0

    -- waypoints recorded with 1.75 distance
    maidenpos_length = table_length(maidenpos)
    if maidenpos_length == 0 then
        -- maidenpos empty, fill depending on current helltide zone
        -- Helltide Zone: Marowen (Scos_Coast)
        if helltide_zone_name == "Scos_Coast" then
            maidenpos = {
                vec3:new(-1733.853882, -1196.353027, 11.425717),
                vec3:new(-1733.140381, -1194.735718, 11.446535),
                vec3:new(-1732.577271, -1193.044800, 11.482092),
                vec3:new(-1731.988281, -1191.363159, 11.480963),
                vec3:new(-1731.003662, -1189.880493, 11.454583),
                vec3:new(-1730.189087, -1188.307373, 11.439787),
                vec3:new(-1729.400513, -1186.712158, 11.494039),
                vec3:new(-1728.649902, -1185.098633, 11.595195),
                vec3:new(-1727.975464, -1183.461182, 11.692283),
                vec3:new(-1727.434814, -1181.779785, 11.839867),
                vec3:new(-1727.196533, -1180.025879, 11.881786),
                vec3:new(-1727.756714, -1178.356689, 11.958417),
                vec3:new(-1728.507080, -1176.746094, 12.009420),
                vec3:new(-1729.566162, -1175.343140, 12.008756),
                vec3:new(-1730.990723, -1174.313843, 12.004212),
                vec3:new(-1732.452271, -1173.321777, 11.913486),
                vec3:new(-1733.949097, -1172.392822, 11.907233),
                vec3:new(-1735.584961, -1171.688843, 11.904310),
                vec3:new(-1737.273193, -1171.191528, 11.906125),
                vec3:new(-1738.978760, -1170.727661, 11.894422),
                vec3:new(-1740.677856, -1170.303101, 11.876059),
                vec3:new(-1742.387451, -1169.815186, 11.827003),
                vec3:new(-1743.974609, -1169.073853, 11.755139),
                vec3:new(-1745.384399, -1168.021973, 11.654760),
                vec3:new(-1746.569946, -1166.710938, 11.441330),
                vec3:new(-1747.598022, -1165.271118, 11.151113),
                vec3:new(-1748.484985, -1163.737183, 10.834669),
                vec3:new(-1749.254395, -1162.126099, 10.755924),
                vec3:new(-1750.001831, -1160.537109, 10.775783),
                vec3:new(-1750.770142, -1158.949463, 10.794531),
                vec3:new(-1751.645874, -1157.401001, 10.857831),
                vec3:new(-1752.657349, -1155.971436, 10.937794),
                vec3:new(-1753.890625, -1154.728271, 10.981298),
                vec3:new(-1755.435059, -1153.860229, 11.032386),
                vec3:new(-1757.081421, -1153.202637, 10.992462),
                vec3:new(-1758.717285, -1152.536865, 10.675206),
                vec3:new(-1760.296631, -1151.758545, 10.306875),
                vec3:new(-1761.874878, -1150.927490, 9.797995),
                vec3:new(-1763.378052, -1150.031372, 9.220347),
                vec3:new(-1764.763916, -1148.935547, 8.658319),
                vec3:new(-1766.021606, -1147.690918, 8.069059),
                vec3:new(-1767.183960, -1146.352295, 7.582171),
                vec3:new(-1768.269775, -1144.938965, 7.563184),
                vec3:new(-1769.392700, -1143.557495, 7.589098),
                vec3:new(-1770.543457, -1142.206787, 7.549156),
                vec3:new(-1771.732788, -1140.912598, 7.564873),
                vec3:new(-1773.122803, -1139.831299, 7.442362),
                vec3:new(-1774.745239, -1139.160400, 7.414558),
                vec3:new(-1776.497192, -1138.930908, 7.413162),
                vec3:new(-1778.285645, -1138.930664, 7.584691),
                vec3:new(-1780.065186, -1138.916016, 7.754940),
                vec3:new(-1781.828003, -1138.919434, 7.840755),
                vec3:new(-1783.612427, -1138.991333, 7.919012),
                vec3:new(-1785.376831, -1139.137451, 7.996843),
                vec3:new(-1787.157593, -1139.171265, 7.898765),
                vec3:new(-1788.842773, -1138.631104, 7.669294),
                vec3:new(-1790.608887, -1138.533325, 7.409111),
                vec3:new(-1792.386963, -1138.514771, 7.353064),
                vec3:new(-1794.156616, -1138.260620, 7.402735),
                vec3:new(-1795.968750, -1138.126221, 7.480088),
                vec3:new(-1797.748535, -1138.121948, 7.578667),
                vec3:new(-1799.502563, -1138.189209, 7.687479),
                vec3:new(-1801.258911, -1138.199219, 7.810829),
                vec3:new(-1803.029663, -1138.190552, 7.983270),
                vec3:new(-1804.767456, -1137.825684, 8.198669),
                vec3:new(-1806.527832, -1137.137573, 8.405964),
                vec3:new(-1808.153320, -1136.399414, 8.745322),
                vec3:new(-1809.825317, -1135.828857, 9.282611),
                vec3:new(-1811.553223, -1135.408813, 9.671305),
                vec3:new(-1813.268555, -1135.040894, 10.016899),
                vec3:new(-1814.998169, -1134.660034, 10.320882),
                vec3:new(-1816.733276, -1134.328247, 10.556284),
                vec3:new(-1818.437866, -1133.778809, 10.817352),
                vec3:new(-1820.040649, -1133.013916, 11.047509),
                vec3:new(-1821.393555, -1131.879517, 11.197092),
                vec3:new(-1822.238525, -1130.308960, 11.217980),
                vec3:new(-1822.324097, -1128.556274, 11.331634),
                vec3:new(-1822.364746, -1126.786987, 11.443852),
                vec3:new(-1822.391479, -1124.999756, 11.554694),
                vec3:new(-1822.601074, -1123.221069, 11.690442),
                vec3:new(-1823.046387, -1121.505737, 11.848731),
                vec3:new(-1823.854736, -1119.934082, 12.038258),
                vec3:new(-1825.335693, -1118.998657, 12.184616),
                vec3:new(-1827.076660, -1119.244995, 12.469728),
                vec3:new(-1828.765137, -1119.747314, 12.768376),
                vec3:new(-1830.188599, -1120.796387, 12.968380),
                vec3:new(-1831.922241, -1121.198242, 13.207383),
                vec3:new(-1833.655518, -1121.537720, 13.468143),
                vec3:new(-1835.387817, -1121.232422, 14.042418),
                vec3:new(-1837.087524, -1120.745361, 14.333743),
                vec3:new(-1838.807251, -1120.285522, 14.233169),
                vec3:new(-1840.517212, -1119.828369, 14.296994),
                vec3:new(-1842.203735, -1119.344727, 14.344867),
                vec3:new(-1843.849243, -1118.718384, 14.258062),
                vec3:new(-1845.570801, -1118.248413, 14.071353),
                vec3:new(-1847.320068, -1117.866699, 14.051445),
                vec3:new(-1847.777222, -1119.556763, 14.178780),
                vec3:new(-1849.337646, -1118.661133, 14.191158),
                vec3:new(-1850.737305, -1117.606323, 14.251069),
                vec3:new(-1851.743774, -1116.116455, 13.643024),
                vec3:new(-1852.655151, -1114.615479, 13.290549),
                vec3:new(-1853.872070, -1113.274170, 13.263993),
                vec3:new(-1855.476685, -1112.529541, 13.295408),
                vec3:new(-1856.979248, -1113.503784, 13.275480),
                vec3:new(-1858.395996, -1114.603394, 13.273559),
                vec3:new(-1859.802979, -1115.727051, 13.360929),
                vec3:new(-1861.177979, -1116.818970, 13.656588),
                vec3:new(-1862.571167, -1117.909546, 13.922075),
                vec3:new(-1863.973267, -1118.961670, 14.181380),
                vec3:new(-1865.388672, -1120.000244, 14.437484),
                vec3:new(-1866.847168, -1121.074097, 14.676043),
                vec3:new(-1868.519165, -1121.776123, 15.122373),
                vec3:new(-1870.267212, -1121.626465, 15.364519),
                vec3:new(-1872.017090, -1121.512817, 15.379883),
                vec3:new(-1873.784180, -1121.775024, 15.387953),
                vec3:new(-1875.514038, -1122.040527, 15.233361),
                vec3:new(-1877.279053, -1122.325562, 15.267058),
                vec3:new(-1879.040771, -1122.609741, 15.327695),
                vec3:new(-1880.840088, -1122.645996, 15.358539),
                vec3:new(-1882.589844, -1122.713623, 15.335526),
                vec3:new(-1884.353516, -1122.799194, 15.201715),
                vec3:new(-1886.104248, -1122.591187, 14.883629),
                vec3:new(-1887.885864, -1122.333984, 14.505401),
                vec3:new(-1889.647339, -1122.128418, 13.939257),
                vec3:new(-1891.541992, -1122.421875, 13.525920),
                vec3:new(-1893.275024, -1122.687988, 13.112979),
                vec3:new(-1895.082520, -1122.539185, 12.582310),
                vec3:new(-1896.774414, -1123.294922, 12.346858),
                vec3:new(-1898.440430, -1124.028320, 12.093966),
                vec3:new(-1900.025635, -1124.848755, 11.957258),
                vec3:new(-1901.562256, -1125.737793, 11.531864),
                vec3:new(-1903.134277, -1126.554932, 11.234179),
                vec3:new(-1904.883545, -1126.847656, 10.936529),
                vec3:new(-1906.771362, -1126.936523, 11.071079),
                vec3:new(-1908.547729, -1127.062012, 11.427193),
                vec3:new(-1909.787354, -1128.337158, 11.605882),
                vec3:new(-1910.310425, -1130.027100, 11.489632),
                vec3:new(-1910.891846, -1131.756592, 11.163924),
                vec3:new(-1911.505615, -1133.424316, 11.081477),
                vec3:new(-1912.165405, -1135.057129, 10.981905),
                vec3:new(-1912.925171, -1136.655762, 10.968034),
                vec3:new(-1913.750122, -1138.248657, 10.860435),
                vec3:new(-1914.819824, -1139.655762, 10.973666),
                vec3:new(-1916.229980, -1140.791504, 11.262663),
                vec3:new(-1917.693970, -1141.806641, 11.719693),
                vec3:new(-1919.461182, -1142.119141, 12.514303),
                vec3:new(-1921.178711, -1142.523926, 12.816521),
                vec3:new(-1922.983765, -1142.890747, 12.981864),
                vec3:new(-1924.710571, -1143.359863, 13.112133),
                vec3:new(-1926.508789, -1143.815430, 13.213223),
                vec3:new(-1928.212036, -1144.246460, 13.299664),
                vec3:new(-1929.967651, -1144.392090, 13.299805),
                vec3:new(-1931.695923, -1144.855225, 13.299805),
                vec3:new(-1933.274170, -1145.688721, 13.299805),
                vec3:new(-1934.905762, -1146.687012, 13.304900),
                vec3:new(-1936.504272, -1147.536865, 13.524225),
                vec3:new(-1938.251953, -1147.853394, 13.454422),
                vec3:new(-1940.005859, -1147.752197, 13.449384),
                vec3:new(-1941.620117, -1147.022461, 13.468207),
                vec3:new(-1943.286255, -1146.389404, 13.560301),
                vec3:new(-1944.991821, -1145.773926, 13.569274),
                vec3:new(-1946.736816, -1145.339478, 13.376025),
                vec3:new(-1948.497192, -1145.458740, 13.051009),
                vec3:new(-1950.263184, -1145.725708, 12.847472),
                vec3:new(-1952.005127, -1145.961792, 12.732241),
                vec3:new(-1953.769775, -1146.277954, 12.642750),
                vec3:new(-1955.409546, -1146.931030, 12.618545),
                vec3:new(-1957.193604, -1147.053345, 12.599609),
                vec3:new(-1958.974243, -1146.862305, 12.599609),
                vec3:new(-1960.488159, -1145.925415, 12.599609),
                vec3:new(-1961.837646, -1144.794189, 12.599609),
                vec3:new(-1963.083862, -1143.538330, 12.599609),
                vec3:new(-1964.329468, -1142.233643, 12.621827),
                vec3:new(-1965.584229, -1141.012085, 12.661399),
                vec3:new(-1967.161377, -1140.135620, 12.759434),
                vec3:new(-1968.916870, -1140.409302, 12.761876),
                vec3:new(-1970.479614, -1141.260376, 12.599791),
                vec3:new(-1971.999268, -1142.184570, 12.599609),
                vec3:new(-1973.506348, -1143.180908, 12.599609),
                vec3:new(-1974.886475, -1144.274902, 12.599609),
                vec3:new(-1976.175781, -1145.487427, 12.607443),
                vec3:new(-1977.792969, -1146.279541, 12.599609),
                vec3:new(-1979.275757, -1145.251709, 12.599609),
                vec3:new(-1980.862793, -1144.390503, 12.609367),
                vec3:new(-1982.549438, -1143.823364, 12.758240)
            }
        -- Menestad (Frac_Tundra_S)
        elseif helltide_zone_name == "Frac_Tundra_S" then
            maidenpos = {
                vec3:new(-1425.584229, -127.706841, 90.736923),
                vec3:new(-1427.596680, -126.158356, 90.809593),
                vec3:new(-1429.720703, -124.829269, 91.112350),
                vec3:new(-1431.868652, -123.537102, 91.688583),
                vec3:new(-1433.792603, -121.913223, 92.700928),
                vec3:new(-1436.070435, -120.850449, 93.766754),
                vec3:new(-1438.457520, -120.004257, 94.530800),
                vec3:new(-1440.853760, -119.244255, 94.731880),
                vec3:new(-1443.369141, -118.933540, 94.978958),
                vec3:new(-1445.771484, -119.716263, 95.225716),
                vec3:new(-1448.141602, -120.556038, 95.475693),
                vec3:new(-1450.575439, -119.981544, 95.621284),
                vec3:new(-1452.657959, -118.581856, 95.631241),
                vec3:new(-1454.762817, -117.167885, 95.659531),
                vec3:new(-1456.890625, -115.816521, 95.727325),
                vec3:new(-1458.917480, -114.339600, 95.691124),
                vec3:new(-1460.938721, -112.832550, 95.620834),
                vec3:new(-1462.940552, -111.319618, 95.676483),
                vec3:new(-1465.098877, -110.020714, 95.728867),
                vec3:new(-1467.275879, -108.769493, 95.707047),
                vec3:new(-1469.467285, -107.478455, 95.649933),
                vec3:new(-1471.532959, -106.046730, 95.621956),
                vec3:new(-1473.505249, -104.464012, 95.657349),
                vec3:new(-1475.360229, -102.758781, 95.780296),
                vec3:new(-1477.134399, -100.967636, 96.001762),
                vec3:new(-1478.842773, -99.126060, 96.293991),
                vec3:new(-1480.457642, -97.196663, 96.623680),
                vec3:new(-1481.991455, -95.202377, 97.050117),
                vec3:new(-1483.502563, -93.162056, 97.644402),
                vec3:new(-1484.856323, -91.041519, 98.227150),
                vec3:new(-1485.941895, -88.788979, 98.784340),
                vec3:new(-1486.663818, -86.368149, 99.354759),
                vec3:new(-1487.614502, -83.917900, 99.880898),
                vec3:new(-1488.187500, -81.102539, 100.477539),
                vec3:new(-1489.067871, -78.746246, 100.955498),
                vec3:new(-1489.811401, -76.358521, 101.065659),
                vec3:new(-1490.678467, -74.013580, 101.210426),
                vec3:new(-1491.638428, -71.688004, 101.140694),
                vec3:new(-1492.231812, -69.242104, 100.981216),
                vec3:new(-1492.660889, -66.775398, 101.028755),
                vec3:new(-1494.711426, -65.313843, 101.436317),
                vec3:new(-1497.080933, -64.456841, 101.319633),
                vec3:new(-1498.965332, -62.803673, 101.234245),
                vec3:new(-1499.835938, -60.433300, 101.585709),
                vec3:new(-1501.222534, -58.340809, 101.941750),
                vec3:new(-1503.266479, -56.597897, 101.888924),
                vec3:new(-1505.267700, -55.081650, 102.569717),
                vec3:new(-1507.553589, -56.339310, 102.095192),
                vec3:new(-1510.066040, -56.203777, 102.392105),
                vec3:new(-1512.598511, -56.243362, 102.672951),
                vec3:new(-1514.945068, -55.304405, 102.553307),
                vec3:new(-1517.003662, -53.879082, 102.605309),
                vec3:new(-1518.584961, -51.907501, 102.578125),
                vec3:new(-1519.703369, -49.656754, 102.556084),
                vec3:new(-1520.856934, -47.401745, 102.522675),
                vec3:new(-1522.433350, -45.433628, 102.591995),
                vec3:new(-1523.994995, -43.452393, 102.451630),
                vec3:new(-1526.149902, -42.156776, 102.780670),
                vec3:new(-1528.350342, -40.918415, 103.691071),
                vec3:new(-1530.756958, -40.215176, 104.873657),
                vec3:new(-1533.205322, -39.641411, 105.904091),
                vec3:new(-1535.537842, -38.695061, 106.856789),
                vec3:new(-1535.643921, -36.187683, 107.377594),
                vec3:new(-1533.622681, -34.704277, 107.714325),
                vec3:new(-1531.602905, -33.201744, 107.562103),
                vec3:new(-1530.280518, -31.071438, 107.380211),
                vec3:new(-1529.136841, -28.811800, 107.083199),
                vec3:new(-1528.024048, -26.540400, 106.573784),
                vec3:new(-1526.859985, -24.272938, 106.024826),
                vec3:new(-1524.975220, -22.629196, 105.497444),
                vec3:new(-1522.546265, -21.992458, 105.309868),
                vec3:new(-1520.293579, -20.872478, 105.299805),
                vec3:new(-1517.776733, -20.840151, 105.299805)
            }
        -- Iron Wolves Encampment starts at: (Kehj_Oasis) but ends in: (Kehj_HighDesert)
        elseif helltide_zone_name == "Kehj_Oasis" or helltide_zone_name == "Kehj_HighDesert" then
            maidenpos = {
                vec3:new(216.652969, -604.208618, 7.017759),
                vec3:new(216.089203, -606.651672, 7.091797),
                vec3:new(215.637665, -609.143921, 7.091797),
                vec3:new(215.279388, -611.619263, 7.061430),
                vec3:new(215.117218, -614.126892, 7.137652),
                vec3:new(215.354141, -616.640442, 7.137695),
                vec3:new(215.725922, -619.143433, 7.091797),
                vec3:new(215.274734, -621.605408, 7.118515),
                vec3:new(214.504227, -624.006653, 7.081841),
                vec3:new(213.492386, -626.307068, 7.071878),
                vec3:new(212.475388, -628.594482, 7.059570),
                vec3:new(211.358963, -630.851929, 7.087931),
                vec3:new(209.683960, -632.745850, 7.164665),
                vec3:new(207.395844, -633.827942, 7.180541),
                vec3:new(205.031891, -634.822083, 7.118772),
                vec3:new(202.943039, -636.219299, 7.147820),
                vec3:new(201.027512, -637.868347, 7.223553),
                vec3:new(199.175308, -639.575806, 7.334243),
                vec3:new(197.258469, -641.182922, 7.455162),
                vec3:new(195.166183, -642.585510, 7.617836),
                vec3:new(193.027817, -643.936951, 7.889241),
                vec3:new(190.820023, -645.183289, 8.141918),
                vec3:new(188.613708, -646.361145, 8.464275),
                vec3:new(186.405243, -647.537048, 8.932059),
                vec3:new(184.202911, -648.762573, 9.388937),
                vec3:new(182.224899, -650.313232, 9.886385),
                vec3:new(180.655655, -652.302673, 10.565573),
                vec3:new(179.495682, -654.543640, 11.380956),
                vec3:new(179.034592, -657.004395, 12.016582),
                vec3:new(178.613831, -659.483093, 12.025225),
                vec3:new(177.956497, -661.913391, 12.029297),
                vec3:new(176.873123, -664.187439, 12.038877),
                vec3:new(175.678070, -666.393250, 12.029529),
                vec3:new(174.245636, -668.473511, 12.083364),
                vec3:new(172.733368, -670.491272, 11.969455),
                vec3:new(171.115875, -672.440552, 11.995118),
                vec3:new(169.655273, -674.469727, 11.816024),
                vec3:new(168.974640, -676.891174, 11.102398),
                vec3:new(168.090714, -679.296509, 9.698860),
                vec3:new(167.657120, -681.826233, 8.802664),
                vec3:new(167.415802, -684.341064, 7.581744),
                vec3:new(167.381592, -686.866333, 6.600248),
                vec3:new(167.348312, -689.399231, 5.782186),
                vec3:new(166.419632, -691.735657, 5.224112),
                vec3:new(164.850601, -693.717407, 5.089946),
                vec3:new(162.684509, -695.027283, 5.133019),
                vec3:new(160.146698, -695.593018, 5.175540),
                vec3:new(158.428802, -697.427307, 5.407512),
                vec3:new(157.160095, -699.619446, 5.533040),
                vec3:new(155.416763, -701.411560, 5.477710),
                vec3:new(153.430954, -702.932556, 5.466105),
                vec3:new(151.500473, -704.524658, 5.312034),
                vec3:new(149.613449, -706.340820, 5.163350),
                vec3:new(147.794006, -708.099976, 5.154017),
                vec3:new(145.269669, -708.174683, 5.364219),
                vec3:new(143.422134, -709.905029, 5.544849),
                vec3:new(141.943100, -711.925171, 5.621508),
                vec3:new(140.839798, -714.206482, 5.662209),
                vec3:new(140.764648, -716.708984, 5.499856),
                vec3:new(141.119644, -719.829773, 5.485236),
                vec3:new(141.044128, -722.341064, 5.769369),
                vec3:new(141.228012, -724.868408, 5.919075),
                vec3:new(141.110764, -728.378601, 5.965736),
                vec3:new(139.591019, -730.367371, 5.989273),
                vec3:new(137.447800, -731.725708, 6.023360),
                vec3:new(135.623642, -733.461670, 6.077476),
                vec3:new(133.982803, -735.356567, 6.090135),
                vec3:new(132.414810, -737.340210, 6.174208),
                vec3:new(130.993164, -739.397522, 6.282589),
                vec3:new(128.960617, -740.879822, 6.294904),
                vec3:new(126.752655, -742.137695, 6.484891),
                vec3:new(124.713531, -743.668335, 6.677797),
                vec3:new(122.838860, -745.353516, 6.886272),
                vec3:new(120.874367, -746.962341, 7.089052)
            }
        -- Ruins of Rakhat Keep Inner Court (Hawe_ZakFort)
        elseif helltide_zone_name == "Hawe_ZakFort" then
            maidenpos = {
                vec3:new(-756.597656, 629.956055, 2.031250),
                vec3:new(-756.960083, 631.685913, 1.791466),
                vec3:new(-757.065979, 633.457458, 1.530639),
                vec3:new(-756.760803, 635.180664, 1.310125),
                vec3:new(-755.539978, 636.488403, 1.222397),
                vec3:new(-754.194702, 637.685059, 1.172659),
                vec3:new(-753.418945, 639.333862, 0.980009),
                vec3:new(-753.131470, 641.069458, 0.678213),
                vec3:new(-753.025146, 642.824829, 0.312598),
                vec3:new(-752.761230, 644.572449, -0.003472),
                vec3:new(-752.402344, 646.289001, -0.098207),
                vec3:new(-752.032837, 648.058350, -0.134123),
                vec3:new(-751.694458, 649.793091, -0.172895),
                vec3:new(-751.290894, 651.536804, -0.186649),
                vec3:new(-750.916809, 653.273132, -0.076539),
                vec3:new(-750.553833, 655.029724, -0.071092),
                vec3:new(-750.343750, 656.799194, -0.064139),
                vec3:new(-750.163696, 658.551270, -0.035949),
                vec3:new(-749.879517, 660.343750, -0.002544),
                vec3:new(-749.455566, 662.345398, 0.019205),
                vec3:new(-749.124878, 664.104431, 0.022275),
                vec3:new(-748.863831, 665.850098, 0.072474),
                vec3:new(-748.579712, 667.596436, 0.095359),
                vec3:new(-748.181030, 669.324646, 0.113899),
                vec3:new(-747.464600, 670.983704, 0.036506),
                vec3:new(-746.432678, 672.437012, 0.242201),
                vec3:new(-745.414856, 673.937927, 0.568988),
                vec3:new(-744.473206, 675.438843, 0.762728),
                vec3:new(-743.601562, 676.973633, 0.750755),
                vec3:new(-742.822510, 678.627014, 0.668125),
                vec3:new(-742.458130, 680.344727, 0.524490),
                vec3:new(-742.290894, 682.127258, 0.353452),
                vec3:new(-742.273560, 683.919983, 0.331034),
                vec3:new(-742.269287, 685.703308, 0.403549),
                vec3:new(-742.181213, 687.500488, 0.382185),
                vec3:new(-742.003845, 689.345520, 0.400234),
                vec3:new(-741.367554, 690.998047, 0.466375),
                vec3:new(-740.216003, 692.327820, 0.572686),
                vec3:new(-739.314270, 693.877625, 0.602384),
                vec3:new(-738.493408, 695.533081, 1.167916),
                vec3:new(-737.927124, 697.240967, 1.550434),
                vec3:new(-737.447815, 698.945557, 1.822561),
                vec3:new(-737.036011, 700.648865, 1.962603),
                vec3:new(-736.638428, 702.418152, 1.967169),
                vec3:new(-736.112732, 704.177612, 1.935011),
                vec3:new(-735.494385, 705.827759, 1.817812),
                vec3:new(-734.844910, 707.572327, 1.731309),
                vec3:new(-734.277649, 709.274292, 1.560442),
                vec3:new(-733.729980, 711.000854, 1.218583),
                vec3:new(-733.101807, 712.747681, 0.854871),
                vec3:new(-732.389648, 714.382812, 0.715273),
                vec3:new(-731.627808, 716.030457, 0.630241),
                vec3:new(-730.839478, 717.627808, 0.630254),
                vec3:new(-730.013855, 719.171204, 0.656581),
                vec3:new(-729.089172, 720.740417, 0.736762),
                vec3:new(-728.135071, 722.231384, 0.799911),
                vec3:new(-726.945007, 723.590271, 0.536675),
                vec3:new(-725.689636, 724.846802, 0.200108),
                vec3:new(-724.415710, 726.132385, 0.074831),
                vec3:new(-723.109802, 727.390625, 0.000233),
                vec3:new(-721.767151, 728.514038, -0.020854),
                vec3:new(-720.262451, 729.500061, -0.039372),
                vec3:new(-718.613647, 730.280762, -0.116035),
                vec3:new(-716.850769, 730.370056, -0.130971),
                vec3:new(-715.147888, 729.961182, -0.128827),
                vec3:new(-713.508484, 729.250610, -0.139658),
                vec3:new(-711.860046, 728.516846, -0.150801),
                vec3:new(-710.270935, 727.772583, -0.152775),
                vec3:new(-708.683411, 727.030579, -0.141389),
                vec3:new(-707.040405, 726.281860, -0.114396),
                vec3:new(-705.417114, 725.559937, -0.105388),
                vec3:new(-703.736389, 724.857361, -0.058412),
                vec3:new(-702.060486, 724.272827, 0.009758),
                vec3:new(-700.321167, 723.886841, 0.105630),
                vec3:new(-698.550171, 723.562134, 0.214593),
                vec3:new(-696.807251, 723.316528, 0.354673),
                vec3:new(-695.031616, 723.148010, 0.389605),
                vec3:new(-693.242249, 723.082031, 0.389648),
                vec3:new(-691.486877, 723.152222, 0.389648),
                vec3:new(-689.689819, 723.401001, 0.389648),
                vec3:new(-687.945190, 723.740173, 0.389648),
                vec3:new(-686.211121, 724.082947, 0.389648),
                vec3:new(-684.439209, 724.379272, 0.389648),
                vec3:new(-682.689026, 724.777039, 0.389648),
                vec3:new(-680.988770, 725.340576, 0.389648)
            }
        -- Wejinhani (Hawe_Verge)
        elseif helltide_zone_name == "Hawe_Verge" then
            maidenpos = {
                vec3:new(-840.172180, 361.590393, 10.681550),
                vec3:new(-840.222046, 363.369110, 11.057541),
                vec3:new(-840.397705, 365.112701, 11.646476),
                vec3:new(-840.710022, 366.852478, 11.853608),
                vec3:new(-840.936462, 368.587952, 11.675640),
                vec3:new(-841.140076, 370.337372, 11.582926),
                vec3:new(-841.603455, 372.031219, 11.881040),
                vec3:new(-842.122559, 373.704437, 12.080173),
                vec3:new(-842.655579, 375.386505, 12.281515),
                vec3:new(-843.320801, 377.040009, 12.481913),
                vec3:new(-844.619507, 378.243835, 12.729403),
                vec3:new(-846.086487, 379.202606, 12.878560),
                vec3:new(-847.589661, 380.101227, 13.010759),
                vec3:new(-849.089783, 381.013489, 13.124556),
                vec3:new(-850.600098, 381.927032, 13.212137),
                vec3:new(-852.156006, 382.747742, 13.327769),
                vec3:new(-853.875000, 383.106812, 13.557974),
                vec3:new(-855.633301, 383.316284, 13.803091),
                vec3:new(-857.391846, 383.500214, 14.035412),
                vec3:new(-859.152100, 383.663483, 14.093689),
                vec3:new(-860.910339, 383.724213, 14.277301),
                vec3:new(-862.624695, 383.328644, 14.480463),
                vec3:new(-864.159546, 382.449432, 14.736146),
                vec3:new(-865.688477, 381.569031, 14.910695),
                vec3:new(-867.327332, 380.905365, 15.175307),
                vec3:new(-868.993164, 380.301056, 15.491703),
                vec3:new(-870.667419, 379.766815, 15.753744),
                vec3:new(-872.373779, 379.356415, 16.100111),
                vec3:new(-874.157593, 379.342316, 16.534176),
                vec3:new(-875.926270, 379.471558, 16.936754),
                vec3:new(-877.685425, 379.742035, 17.279625),
                vec3:new(-879.363525, 380.246460, 17.416714),
                vec3:new(-880.995361, 380.966064, 17.316776),
                vec3:new(-882.517639, 381.889923, 17.483488),
                vec3:new(-883.916443, 382.955750, 17.539387),
                vec3:new(-885.239258, 384.130066, 17.616339),
                vec3:new(-886.323486, 385.509186, 17.521431),
                vec3:new(-887.234802, 387.019073, 17.407803),
                vec3:new(-888.065247, 388.634399, 17.439905),
                vec3:new(-888.846741, 390.344604, 17.562698),
                vec3:new(-889.642151, 391.909607, 17.610687),
                vec3:new(-890.600586, 393.396454, 17.797323),
                vec3:new(-891.603333, 394.838593, 17.879862),
                vec3:new(-892.695312, 396.249359, 17.906054),
                vec3:new(-894.000488, 397.457489, 17.944330),
                vec3:new(-895.669495, 398.023804, 17.926559),
                vec3:new(-897.356934, 398.519714, 17.889652),
                vec3:new(-899.047058, 398.996796, 17.889648),
                vec3:new(-900.735657, 399.488678, 17.889648),
                vec3:new(-902.431213, 400.098969, 17.889648),
                vec3:new(-904.074463, 400.729004, 17.889648),
                vec3:new(-905.635864, 401.560974, 17.889648),
                vec3:new(-907.120728, 402.606476, 17.889648),
                vec3:new(-908.554565, 403.635254, 17.889648),
                vec3:new(-910.016235, 404.668579, 17.889648),
                vec3:new(-911.480652, 405.636383, 17.888601),
                vec3:new(-913.021912, 406.571259, 17.855858),
                vec3:new(-914.557922, 407.416962, 17.754335),
                vec3:new(-916.128906, 408.206482, 17.552454),
                vec3:new(-917.781250, 408.927185, 17.314941),
                vec3:new(-919.481201, 409.485565, 17.074888),
                vec3:new(-921.182312, 409.920502, 16.918747),
                vec3:new(-922.923950, 410.276245, 16.571909),
                vec3:new(-924.703491, 410.459106, 16.676262),
                vec3:new(-926.474304, 410.540314, 16.727386),
                vec3:new(-928.257080, 410.624451, 16.567083),
                vec3:new(-930.044556, 410.621521, 16.627474),
                vec3:new(-931.839233, 410.429871, 16.418859),
                vec3:new(-933.576904, 410.210358, 16.341434),
                vec3:new(-935.319519, 410.513794, 16.290087),
                vec3:new(-936.732361, 411.653107, 16.289062),
                vec3:new(-937.943481, 413.019196, 16.289062),
                vec3:new(-939.144287, 414.344849, 16.582022),
                vec3:new(-940.376465, 415.623901, 16.485109),
                vec3:new(-941.976196, 416.417419, 16.402258),
                vec3:new(-943.738220, 417.145081, 16.351723),
                vec3:new(-945.260193, 418.180939, 16.302605),
                vec3:new(-946.421875, 419.495972, 16.299805),
                vec3:new(-948.095886, 420.025757, 16.299805),
                vec3:new(-949.865845, 419.977234, 16.303205),
                vec3:new(-951.641296, 419.896301, 16.770441),
                vec3:new(-953.399841, 419.837708, 16.560108),
                vec3:new(-955.175537, 419.829102, 16.774618),
                vec3:new(-956.930786, 419.829102, 16.995144),
                vec3:new(-958.684021, 419.811554, 17.231380),
                vec3:new(-960.438354, 419.809204, 17.459444),
                vec3:new(-961.960327, 420.727417, 17.739712),
                vec3:new(-963.121948, 422.086029, 17.887056),
                vec3:new(-963.806458, 423.725555, 17.889648),
                vec3:new(-964.360596, 425.421021, 17.889648),
                vec3:new(-965.246582, 427.158997, 17.889648),
                vec3:new(-966.034973, 428.742035, 17.889648),
                vec3:new(-966.934326, 430.252380, 17.889648),
                vec3:new(-967.479919, 431.933594, 17.889648),
                vec3:new(-967.487244, 433.703888, 17.889648),
                vec3:new(-967.385803, 435.457489, 17.889648),
                vec3:new(-967.275391, 437.244568, 17.901474),
                vec3:new(-967.780029, 438.952271, 18.048344),
                vec3:new(-968.789429, 440.442535, 17.985245),
                vec3:new(-969.797424, 441.888000, 17.986580),
                vec3:new(-970.790466, 443.402527, 17.868340),
                vec3:new(-971.797852, 444.944336, 17.915918),
                vec3:new(-972.680420, 446.491699, 17.963362),
                vec3:new(-973.578979, 448.066711, 17.737722),
                vec3:new(-974.495605, 449.571777, 17.545135),
                vec3:new(-975.606873, 450.959625, 17.419121),
                vec3:new(-976.923462, 452.158630, 17.451988),
                vec3:new(-978.626587, 452.669342, 17.640869),
                vec3:new(-980.390625, 453.296875, 17.708511),
                vec3:new(-982.091797, 453.931641, 17.456305),
                vec3:new(-983.853394, 454.246002, 17.351376),
                vec3:new(-985.353882, 455.201141, 17.374327),
                vec3:new(-985.922485, 456.975281, 17.365734),
                vec3:new(-986.469482, 458.793304, 17.328827),
                vec3:new(-987.048340, 460.480774, 17.380856),
                vec3:new(-987.964478, 462.005768, 17.591492),
                vec3:new(-989.171448, 463.319794, 17.721434),
                vec3:new(-990.399292, 464.646912, 17.879627),
                vec3:new(-991.898376, 465.582672, 17.889648),
                vec3:new(-993.565125, 466.217377, 17.889648),
                vec3:new(-995.262512, 466.689819, 17.889648),
                vec3:new(-997.041809, 466.937897, 17.889648),
                vec3:new(-998.798767, 467.112122, 17.946779),
                vec3:new(-1000.592590, 467.194214, 17.926558),
                vec3:new(-1002.366272, 467.333374, 17.413054),
                vec3:new(-1004.144470, 467.558929, 17.309177),
                vec3:new(-1005.880005, 467.908966, 17.565344),
                vec3:new(-1007.643127, 468.196472, 17.783730),
                vec3:new(-1009.392822, 468.433716, 17.890472),
                vec3:new(-1011.130005, 468.824097, 17.874321),
                vec3:new(-1012.880676, 469.142090, 17.796675),
                vec3:new(-1014.661133, 468.742188, 17.752859),
                vec3:new(-1016.515869, 468.625702, 17.796467),
                vec3:new(-1018.261475, 468.480530, 17.855816),
                vec3:new(-1020.161438, 468.094299, 17.703568),
                vec3:new(-1021.886719, 467.773438, 17.530336),
                vec3:new(-1023.590515, 467.365967, 17.180746),
                vec3:new(-1025.294556, 466.808960, 16.901299),
                vec3:new(-1027.054810, 466.877777, 16.657413),
                vec3:new(-1028.808472, 466.840881, 16.410740),
                vec3:new(-1030.590576, 466.804932, 16.336334),
                vec3:new(-1032.350586, 466.680359, 16.363071),
                vec3:new(-1034.074951, 466.345947, 16.358027),
                vec3:new(-1035.758057, 465.758698, 16.426891),
                vec3:new(-1037.410645, 465.070129, 16.351765),
                vec3:new(-1038.952148, 464.184906, 16.331182),
                vec3:new(-1040.347168, 463.049805, 16.329102),
                vec3:new(-1041.770142, 461.982666, 16.329102),
                vec3:new(-1043.250122, 460.873383, 16.351181),
                vec3:new(-1044.963501, 460.452698, 16.567690),
                vec3:new(-1045.889038, 458.942535, 16.446266),
                vec3:new(-1046.770752, 457.404510, 16.329109),
                vec3:new(-1047.641724, 455.885529, 16.329102),
                vec3:new(-1048.667358, 454.459900, 16.329102),
                vec3:new(-1049.915405, 453.198120, 16.329102),
                vec3:new(-1051.348022, 452.092346, 16.329102),
                vec3:new(-1052.888916, 451.202179, 16.329102),
                vec3:new(-1054.530273, 450.578918, 16.330065),
                vec3:new(-1056.251343, 450.150299, 16.349482),
                vec3:new(-1057.996338, 449.890137, 16.355835),
                vec3:new(-1059.770020, 450.000183, 16.549843),
                vec3:new(-1061.418335, 450.661224, 16.395664),
                vec3:new(-1063.187256, 450.438995, 16.489546),
                vec3:new(-1064.900879, 450.069702, 16.413191),
                vec3:new(-1066.627075, 449.701782, 16.329102),
                vec3:new(-1068.417969, 449.359283, 16.359011),
                vec3:new(-1070.214600, 449.095276, 16.321373)
            }
        -- Jirandai (Step_South)
        elseif helltide_zone_name == "Step_South" then
            maidenpos = {
                vec3:new(-323.693359, -441.055664, 39.889648),
                vec3:new(-322.105499, -441.837433, 39.889648),
                vec3:new(-320.699005, -442.883362, 39.889648),
                vec3:new(-319.716034, -444.364014, 39.889648),
                vec3:new(-319.577759, -446.133026, 39.889648),
                vec3:new(-320.194824, -447.773621, 39.889648),
                vec3:new(-321.182404, -449.221466, 39.889648),
                vec3:new(-322.558380, -450.357666, 39.889648),
                vec3:new(-324.206726, -450.956177, 39.889648),
                vec3:new(-325.908325, -451.390289, 39.889648),
                vec3:new(-327.618713, -451.781860, 39.963486),
                vec3:new(-329.333954, -452.150238, 39.385303),
                vec3:new(-331.104706, -452.346680, 38.545803),
                vec3:new(-332.855438, -452.434265, 37.764481),
                vec3:new(-334.605560, -452.422791, 36.930382),
                vec3:new(-336.384064, -452.573456, 36.032269),
                vec3:new(-337.878052, -453.539001, 35.480728),
                vec3:new(-339.123657, -454.772522, 35.479492),
                vec3:new(-340.184692, -456.168213, 35.538918),
                vec3:new(-341.262146, -457.588440, 35.879845),
                vec3:new(-342.563629, -458.785156, 36.130447),
                vec3:new(-344.109344, -459.612427, 36.300842),
                vec3:new(-345.866272, -459.690613, 36.171242),
                vec3:new(-347.618103, -459.388031, 35.880074),
                vec3:new(-349.234375, -458.670837, 35.424698),
                vec3:new(-350.826569, -457.900055, 34.887970),
                vec3:new(-352.401703, -457.087128, 34.342659),
                vec3:new(-353.921234, -456.215668, 33.852436),
                vec3:new(-355.422791, -455.302917, 33.465107),
                vec3:new(-356.926361, -454.385864, 33.035561),
                vec3:new(-358.480927, -453.489105, 32.851688),
                vec3:new(-360.041260, -452.650085, 32.803047),
                vec3:new(-361.562469, -451.767975, 32.649559),
                vec3:new(-362.981506, -450.742981, 32.534386),
                vec3:new(-364.314941, -449.583496, 32.245598),
                vec3:new(-365.620087, -448.400421, 31.833611),
                vec3:new(-366.923676, -447.231140, 31.494085),
                vec3:new(-368.239471, -446.071411, 31.243000),
                vec3:new(-369.407471, -444.729736, 30.914255),
                vec3:new(-370.123627, -443.114197, 30.480719),
                vec3:new(-370.611328, -441.406677, 29.966631),
                vec3:new(-372.040466, -440.361877, 29.803492),
                vec3:new(-373.748474, -439.865540, 29.836248),
                vec3:new(-375.491089, -439.637909, 29.592548),
                vec3:new(-377.241150, -439.496490, 29.785761),
                vec3:new(-379.009583, -439.490570, 29.894857),
                vec3:new(-380.773621, -439.541107, 30.005005),
                vec3:new(-382.535431, -439.702118, 30.060833),
                vec3:new(-384.290558, -439.934174, 29.926914),
                vec3:new(-386.026855, -440.250305, 29.842596),
                vec3:new(-387.740387, -440.652435, 29.705685),
                vec3:new(-389.465393, -441.088898, 29.588989),
                vec3:new(-391.197327, -441.367798, 29.511557),
                vec3:new(-392.945557, -441.465912, 29.438644),
                vec3:new(-394.702423, -441.536499, 29.399107),
                vec3:new(-396.475525, -441.555664, 29.340727),
                vec3:new(-398.257111, -441.544434, 29.275131),
                vec3:new(-400.017456, -441.465912, 29.148083),
                vec3:new(-401.777588, -441.390320, 28.985149),
                vec3:new(-403.552521, -441.380981, 28.781317),
                vec3:new(-405.325989, -441.440491, 28.626911),
                vec3:new(-407.101746, -441.396210, 28.428234),
                vec3:new(-408.854309, -441.073975, 28.206007),
                vec3:new(-410.532715, -440.483795, 27.903276),
                vec3:new(-412.048706, -439.568756, 27.624598),
                vec3:new(-413.534515, -438.612457, 27.559904),
                vec3:new(-415.039398, -437.674652, 27.623035),
                vec3:new(-416.558807, -436.754303, 27.913525),
                vec3:new(-418.148010, -435.932404, 28.354488),
                vec3:new(-419.834564, -435.380463, 28.929878),
                vec3:new(-421.547272, -434.975494, 29.473516),
                vec3:new(-423.252686, -434.504944, 29.999689),
                vec3:new(-424.959351, -434.009216, 30.661079),
                vec3:new(-426.689209, -433.724976, 31.365213),
                vec3:new(-428.436676, -433.574310, 31.837057),
                vec3:new(-430.210236, -433.552765, 32.152615),
                vec3:new(-431.983368, -433.684296, 32.418686),
                vec3:new(-433.714691, -434.095703, 32.661995),
                vec3:new(-435.336426, -434.837311, 32.768097),
                vec3:new(-436.728149, -435.934784, 32.878159),
                vec3:new(-438.480438, -436.679749, 33.275719),
                vec3:new(-440.149231, -437.288422, 33.495872),
                vec3:new(-441.783112, -437.989777, 33.882729),
                vec3:new(-443.509979, -438.470032, 33.919640),
                vec3:new(-445.247162, -438.821136, 33.743298),
                vec3:new(-447.356537, -439.064056, 33.669956),
                vec3:new(-449.139709, -439.230103, 33.573395),
                vec3:new(-450.902649, -439.454926, 33.520821),
                vec3:new(-452.671906, -439.672028, 33.451073),
                vec3:new(-454.474609, -439.674377, 33.447788),
                vec3:new(-456.235352, -439.647766, 33.460960),
                vec3:new(-457.987701, -439.714661, 33.598347),
                vec3:new(-459.649811, -438.942841, 33.769562),
                vec3:new(-461.285492, -438.018616, 33.930542),
                vec3:new(-462.616547, -436.879883, 34.262665),
                vec3:new(-462.382568, -435.136658, 34.190285),
                vec3:new(-461.802399, -433.485443, 34.412228),
                vec3:new(-461.275787, -431.774475, 34.550060),
                vec3:new(-460.828583, -430.066040, 34.618816),
                vec3:new(-460.329651, -428.357574, 34.612549),
                vec3:new(-459.743439, -426.703735, 34.760899),
                vec3:new(-459.121429, -425.044769, 35.126469),
                vec3:new(-458.540100, -423.393494, 35.542263),
                vec3:new(-458.333069, -421.649384, 35.889507),
                vec3:new(-458.278839, -419.874023, 36.433460),
                vec3:new(-458.136566, -418.129150, 37.027538),
                vec3:new(-457.737091, -416.382416, 37.726036),
                vec3:new(-457.268097, -414.632141, 38.431274),
                vec3:new(-456.862000, -412.850616, 38.887539),
                vec3:new(-456.405487, -411.078613, 39.392853),
                vec3:new(-455.790100, -409.304077, 40.092785),
                vec3:new(-455.290344, -407.509674, 40.565372),
                vec3:new(-454.765472, -405.801270, 41.364281),
                vec3:new(-454.280914, -404.103607, 41.976265),
                vec3:new(-454.184784, -402.333710, 42.500484),
                vec3:new(-453.091492, -400.949036, 42.953930),
                vec3:new(-451.988739, -399.588684, 43.411877),
                vec3:new(-450.873627, -398.227844, 44.013451),
                vec3:new(-449.795258, -396.792114, 44.884701),
                vec3:new(-448.799744, -395.318115, 45.610493),
                vec3:new(-447.722473, -393.936127, 46.200520),
                vec3:new(-447.023468, -392.292297, 46.600178),
                vec3:new(-445.596161, -391.254059, 46.845707),
                vec3:new(-444.140869, -390.270020, 47.036541),
                vec3:new(-442.717590, -389.215179, 47.110008),
                vec3:new(-441.480408, -387.977142, 47.312603),
                vec3:new(-440.360504, -386.586487, 47.465553),
                vec3:new(-439.637848, -384.988007, 47.582050),
                vec3:new(-440.295441, -383.301453, 47.549500),
                vec3:new(-441.207916, -381.735504, 47.756058),
                vec3:new(-442.224457, -380.296112, 47.864613),
                vec3:new(-443.408752, -378.958649, 47.858368),
                vec3:new(-444.829498, -377.876678, 47.914520),
                vec3:new(-446.332794, -376.934723, 47.770554),
                vec3:new(-447.856445, -375.931946, 47.517067),
                vec3:new(-449.232697, -374.799438, 47.145504),
                vec3:new(-450.439026, -373.465240, 46.936119),
                vec3:new(-451.588593, -372.096252, 47.190025),
                vec3:new(-452.489349, -370.579620, 47.383183),
                vec3:new(-453.010101, -368.893341, 47.444557),
                vec3:new(-452.888092, -367.093903, 47.170845),
                vec3:new(-452.252167, -365.441650, 46.697426),
                vec3:new(-451.294891, -363.932587, 46.117485),
                vec3:new(-450.416809, -362.408051, 45.547901),
                vec3:new(-449.571014, -360.818970, 45.044945),
                vec3:new(-448.751038, -359.242493, 44.313301),
                vec3:new(-447.863159, -357.718048, 43.726231),
                vec3:new(-448.242859, -356.001251, 43.431919),
                vec3:new(-448.902985, -354.353882, 43.087029),
                vec3:new(-449.427429, -352.656403, 42.484814),
                vec3:new(-449.897614, -350.967041, 41.865559),
                vec3:new(-450.154419, -349.216614, 41.295921),
                vec3:new(-450.525238, -347.467773, 40.647980),
                vec3:new(-450.369141, -345.696625, 39.932873),
                vec3:new(-449.974396, -343.928772, 39.595703),
                vec3:new(-449.597443, -342.177155, 39.507339),
                vec3:new(-450.277191, -340.522949, 39.185375),
                vec3:new(-451.497772, -339.201843, 38.919399),
                vec3:new(-452.834747, -338.045013, 38.717094),
                vec3:new(-454.223114, -336.962708, 38.495407),
                vec3:new(-455.694580, -335.885620, 38.235313),
                vec3:new(-457.131561, -334.838684, 37.942768),
                vec3:new(-458.598541, -333.851318, 37.657619),
                vec3:new(-460.108124, -332.875366, 37.378506),
                vec3:new(-461.633118, -331.939911, 37.098751),
                vec3:new(-462.541565, -330.399200, 36.831936),
                vec3:new(-463.682953, -329.013214, 36.508850),
                vec3:new(-464.924530, -327.773132, 36.178608)
            }
        else
            -- unsupported helltide zone yet, requires manual waypoint, landing here means developer missed something
            console.print("[HELLTIDE-MAIDEN-AUTO] maidenpos_load() - ERROR no waypoints for helltide zone = " .. helltide_zone_name)
        end
    end

    -- set final waypoint for utility pin based on last waypoint in array
    maidenpos_length = table_length(maidenpos)
    if maidenpos_length > 0 then
        helltide_final_maidenpos = maidenpos[maidenpos_length]
    end
end

-- configure ingame menu
on_render_menu(function()

    if not menu.main_tree:push("Mera-Helltide Maiden Auto v1.3") then
        return
    end

    -- checkbox to enable/disable plugin
    menu.main_helltide_maiden_auto_plugin_enabled:render("Enable Plugin", "Enable or disable this plugin, starting it will start teleporting")

    -- checkbox to enable/disable run_explorer after arriving at helltide maiden
    menu.main_helltide_maiden_auto_plugin_run_explorer:render("Run Explorer At Maiden", "Walks to enemies first around at helltide maiden boss within the Limit Explore circle radius, if no enemies found, uses random positions.")
    if menu.main_helltide_maiden_auto_plugin_run_explorer:get() then
        menu.main_helltide_maiden_auto_plugin_run_explorer_close_first:render("Explorer Run To Enemies First", "Focus on close and distance enemies and then try random positions")
        menu.main_helltide_maiden_auto_plugin_explorer_threshold:render("Mov. Threshold", "Slows down selecting of new positions for anti-bot behaviour", 2)
        menu.main_helltide_maiden_auto_plugin_explorer_thresholdvar:render("Randomizer", "Adds random threshold on top of movement threshold for more randomness", 2)
        -- checkbox to enable/disable rendering circle around final helltide maiden position
        menu.main_helltide_maiden_auto_plugin_show_explorer_circle:render("Explorer Draw Circle", "Show Exploring Circle to verify walking range (white) and target walkpoints (blue)")
        menu.main_helltide_maiden_auto_plugin_explorer_circle_radius:render("Limit Explore", "Limit exploring location", 2)
    end

    -- checkbox to enable/disable auto revive on death
    menu.main_helltide_maiden_auto_plugin_auto_revive:render("Auto Revive", "Automatically revive on death")

    -- checkbox to enable/disable helltide zone printing
    menu.main_helltide_maiden_auto_plugin_show_task:render("Show Task", "Show current task at top left screen location")

    -- checkbox to insert hearts after desired time to spawn helltide maiden boss
    menu.main_helltide_maiden_auto_plugin_insert_hearts:render("Insert hearts", "Will try to insert hearts after reaching heart timer, requires hearts available")
    if menu.main_helltide_maiden_auto_plugin_insert_hearts:get() then
        menu.main_helltide_maiden_auto_plugin_insert_hearts_afterboss:render("Insert heart after maiden death", "Directly put in heart after helltide maiden boss was seen dead")
        menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:render("Insert heart after seen no enemies", "Put in heart after no enemies are seen for a particular time in the circle")
        if menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:get() then
            menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider:render("Timer No enemies", "Time in seconds after trying to insert heart when no enemies are seen", 2)
        end
        menu.main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs:render("Insert Only If Players In Range", "Inserts hearts only if players are in range, may disable all other features if no players seen at altar")
    end

    -- Loot Logic Configuration
    menu.enable_loot_logic:render("Enable Auto-Loot Logic", "Enable or disable the loot logic feature")
    if menu.enable_loot_logic:get() then
        menu.only_loot_ga:render("Only Loot GA Items", "Only loot items containing greater affixes")
    end

    menu.enable_sell_logic:render("Enable Auto-Sell Logic", "Enable or disable the sell logic feature")
    if menu.enable_sell_logic:get() then
        menu.salvage_instead:render("Salvage Instead", "Salvage items instead of selling them")
    end

    menu.enable_repair_logic:render("Enable Auto-Repair Logic", "Enable or disable the repair logic feature")
    
    -- checkbox to reset any time after arriving at helltide maiden or being in weired states / perma-stuck
    menu.main_helltide_maiden_auto_plugin_reset:render("Reset (dont keep on)", "Temporary enable reset mode to reset plugin")

end)

-- variables for autoreset script
local last_reset_time = 0
-- variables to track the last active spell time
local last_active_spell_time = 0
-- variables for auto-mounting, which needs time to get the buff up
local current_mount_state = 0
local do_a_mount_or_unmount_once = 0
local do_a_mount_last_time = 0
local do_repair_next = 0
local is_repair_next = 0
local is_sellsalv_next = 0
local item_attempt_counter = {}
local item_blacklist = {}

-- Utility function to get time in milliseconds
local function get_time_ms()
    return os.clock() * 1000
end

-- Function to check if the time since the last active spell is less than 2000 ms
local function can_run_loot_logic()
   
    return get_time_ms() - last_active_spell_time >= 2000
end

-- Function to run the loot logic
function is_running_loot_logic(objective_id)
    if not can_run_loot_logic() then
        -- console.print("aborting runing loot logic")
        return false
    end

    if objective_id ~= objective.loot then
        return
    end

    if not menu.enable_loot_logic:get() then
        -- console.print("aborting runing loot logic - menu")
        return false
    end

    -- Fetch all items
    local items = actors_manager.get_all_items()

    -- Sort items by distance
    table.sort(items, function(a, b)
        return a:get_position():squared_dist_to(local_player:get_position()) < b:get_position():squared_dist_to(local_player:get_position())
    end)

    -- Pick up items based on configuration
    for _, item in ipairs(items) do
        local item_id = item:get_id()

        -- Skip blacklisted items
        if item_blacklist[item_id] then
            -- console.print("Item " .. item_id .. " is blacklisted")
            goto continue
        end

        -- Initialize attempt counter for this item if not already set
        if not item_attempt_counter[item_id] then
            item_attempt_counter[item_id] = 0
        end

        -- Check if the item meets the criteria
        if not menu.only_loot_ga:get() then
           -- console.print("runing loot logic")
            helltide_maiden_auto_task = helltide_maiden_auto_tasks.LOOT
            local success = loot_manager.loot_item(item, true, true)
            if success then
                -- Reset attempt counter on success
                item_attempt_counter[item_id] = 0
                return
            else
                -- Increment attempt counter on failure
                item_attempt_counter[item_id] = item_attempt_counter[item_id] + 1
                if item_attempt_counter[item_id] >= 200 then
                    -- Blacklist item after 200 attempts
                    item_blacklist[item_id] = true
                    -- console.print("Blacklisting item " .. item_id)
                end
            end
        else
            local item_data = item:get_item_info()
            if item_data and item_data:is_valid() then -- prevent accesing invalid ptr
                if string.find(item_data:get_display_name(), "GreaterAffix") then
                    -- console.print("runing loot logic")
                    helltide_maiden_auto_task = helltide_maiden_auto_tasks.LOOT
                    local success = loot_manager.loot_item(item, true, true)
                    if success then
                        -- Reset attempt counter on success
                        item_attempt_counter[item_id] = 0
                        return true
                    else
                        -- Increment attempt counter on failure
                        item_attempt_counter[item_id] = item_attempt_counter[item_id] + 1
                        if item_attempt_counter[item_id] >= 200 then
                            -- Blacklist item after 200 attempts
                            item_blacklist[item_id] = true
                            -- console.print("Blacklisting item " .. item_id)
                        end
                    end
                end
            end
        end -- end of only_loot_ga

        ::continue::
    end

    return false
end

local dorepair_after_being_full = 0
function run_sell_logic(objective_id)
    -- console.print("objective_id " .. objective_id)
    if objective_id ~= objective.sell then
        return
    end

    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return false
    end

    if not menu.enable_sell_logic:get() then
        return false
    end
    
    local local_player = get_local_player()
    if not local_player then
        return false
    end
    -- local inventory_items = local_player:get_inventory_items()
    -- local amount_of_items_in_inventory = table_length(inventory_items)
    -- if amount_of_items_in_inventory > 3 then
    -- --if amount_of_items_in_inventory == 33 then -- 33 is full inventory
    --     console.print("[HELLTIDE-MAIDEN-AUTO] run_sell_logic() - Starting Auto_Play Salvage or Sell")
    --     helltide_maiden_auto_task = helltide_maiden_auto_tasks.SELLSALVAGE
    --     dorepair_after_being_full = 1 -- trigger auto_play.repair_routine() after salvage or sell

    
    -- inventory full start salvage or sell
    if menu.salvage_instead:get() then
        auto_play.salvage_routine()
        return true
    else
        auto_play.sell_routine()
        return true
    end

    return false
end

function run_repair_logic(objective_id)

    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return false
    end

    -- console.print("objective_id " .. objective_id)
    if objective_id ~= objective.repair then
        return
    end
    
    if not menu.enable_repair_logic:get() then
        return false
    end

    auto_play.repair_routine()
    return true
end
  
-- use for core logic
on_update(function()

    -- failsafe to not run script early or during loading screens
    local local_player = get_local_player()
    if not local_player then
        return
    end
    
    -- check if plugin is enabled/disabled via ingame menu
    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return
    end
    
    local active_spell = local_player:get_active_spell_id();
    if active_spell == 197833 then
        return
    end

    if active_spell > 0 then
        last_active_spell_time = get_time_ms()
    end
    
    local is_in_helltides = 0
    local buffs = local_player:get_buffs()
    if buffs then
        for i, buff in ipairs(buffs) do
            -- player buff name during helltide zone equals to "UberSubzone_TrackingPower"
            if buff.name_hash == 1066539 then 
                is_in_helltides = 1
            end
        end
    end

    if get_time_ms() - last_active_spell_time >= 10000 and helltide_maiden_arrivalstate > 0 
    and found_player_in_helltide_zone == 0 then
       if get_time_ms() - last_reset_time >= 200000 then -- 200 seconds
           console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Resetting Helltide")
           reset_helltide_maiden()
           last_reset_time = get_time_ms()
       end
    end

    local objective_id = auto_play.get_objective()
    
    if run_sell_logic(objective_id) then
        return
    end

    if run_repair_logic(objective_id) then
       return
    end

     -- we are inside helltides and in maiden, we loot around anytime idk
    -- good place
    if is_running_loot_logic(objective_id) then
        return
    end

    -- console.print("objective_id " .. objective_id)
    if objective_id == objective.fight then
        auto_play.set_tmp_override(get_time_since_inject())
    end

    -- tick rate logic
    local current_time = os.clock()
    if current_time - last_update_time < 0.1 then
        return
    end
    last_update_time = current_time

    -- get current player position vec3 x,y,z
    local player_position = local_player:get_position()
    if not player_position then
        return
    end

    -- configure run_explorer and run_explorer_is_close / run_explorer_mode depending on UI menu
    if menu.main_helltide_maiden_auto_plugin_run_explorer:get() then
        run_explorer = 1
        if menu.main_helltide_maiden_auto_plugin_run_explorer_close_first:get() then
            run_explorer_is_close = 1
            run_explorer_mode = run_explorer_modes.CLOSERANDOM
        else
            run_explorer_is_close = 0
            run_explorer_mode = run_explorer_modes.RANDOM
        end
        explorer_circle_radius = menu.main_helltide_maiden_auto_plugin_explorer_circle_radius:get()
    else
        run_explorer = 0
        run_explorer_mode = run_explorer_modes.OFF
    end

    -- configure inserts_hearts depending on UI menu
    if menu.main_helltide_maiden_auto_plugin_insert_hearts:get() then
        insert_hearts = 1
        if menu.main_helltide_maiden_auto_plugin_insert_hearts_afterboss:get() then
            insert_hearts_afterboss = 1
        else
            insert_hearts_afterboss = 0
        end
    else
        insert_hearts = 0
        insert_hearts_afterboss = 0
        insert_only_with_npcs_playercount = 0
    end

    -- check if reset is enabled/disabled via ingame menu
    if menu.main_helltide_maiden_auto_plugin_reset:get() then
        console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Resetting")
        reset_helltide_maiden()
        return
    end

    -- always try to revive in case we are dead
    if menu.main_helltide_maiden_auto_plugin_auto_revive:get() then
        revive_at_checkpoint()
    end
  
    -- give mount animation time
    if do_a_mount_or_unmount_once == 1 then
        if current_time - do_a_mount_last_time < 2.0 then -- give 2 seconds animation time
            return
        else 
            -- waited enough time
            do_a_mount_or_unmount_once = 0
            -- force being in helltide even if buff is gone while being mounted, if we called to be mounted we are in a helltide zone
            player_in_helltide_zone = 1
        end
    end     

    -- get all current player buffs to identify if player is being in helltide zone
    local buffs = local_player:get_buffs()
    if buffs then
        -- allow to return to 0 state when nothing is found
        local found_player_in_helltide_zone = 0
        local found_player_is_mounted = 0
        -- check if being mounted to allow some accidentally mounting clicks
        for i, buff in ipairs(buffs) do
            if buff.name_hash == 1066539 then          -- player buff name during helltide zone equals to "UberSubzone_TrackingPower"
                found_player_in_helltide_zone = 1
            end
            if buff.name_hash == 1924 then             -- player buff name during mount state, this really takes time to get up after the mount
                found_player_is_mounted = 1
            end
        end
  
        -- if player was in helltide before and is_mounted now, dont reset
        if found_player_is_mounted == 1 and player_in_helltide_zone == 1 and found_player_in_helltide_zone == 0 then
            -- force being in helltide even if buff is gone while being mounted
            player_in_helltide_zone = 1
            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player probably accidentally mounted in helltide zone, forcing active helltide zone")
        else
            if found_player_in_helltide_zone == 1 then
                player_in_helltide_zone = 1
            else
                -- buff/unmount arrival timing issue
                if helltide_maiden_arrivalstate == 1 and found_player_in_helltide_zone == 1 then
                    player_in_helltide_zone = 1
                else
                    player_in_helltide_zone = 0
                end
            end
        end
        
         -- always reset current value depending on buff found in loop
        current_mount_state = found_player_is_mounted       
    end

    -- check if being stuck via distance_check
    -- dont do this while waiting for teleport
    if helltide_maiden_auto_task ~= helltide_maiden_auto_tasks.IN_TELEPORT then
        -- calculate distance moved based on 4 seconds old previous player_position
        if not distance_check_last_player_position or current_time - distance_check_last_time > 4.0 then
            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Distance-Check - 4s passed saving current player_position")
            distance_check_last_player_position = player_position
            distance_check_last_time = current_time
        end
        -- calculate distance moved (executed more frames, but uses old data then)
        distance_check_distance = player_position:dist_to(distance_check_last_player_position)
        if distance_check_distance < 1.0 then
            distance_check_is_stuck_counter = distance_check_is_stuck_counter + 1
            if distance_check_is_stuck_counter == 1 then
                distance_check_is_stuck_first_time = current_time
                -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Distance-Check - Possible stuck, first time detected")
            end
        else
            distance_check_is_stuck_counter = 0
            distance_check_is_stuck = 0
        end
        -- try to wait 5 seconds based on update_interval calling this thread (give 0.5 extra because distance_check triggers FP for the first time on reset)
        if distance_check_is_stuck_counter >= 55 then
            distance_check_is_stuck = 1
            distance_check_is_stuck_counter = 0
            local elapsed = current_time - distance_check_is_stuck_first_time
            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Distance-Check - WARNING - Stuck threshold reached, enabling Is_Stuck - took: " .. elapsed .. " seconds to detect")
        end
    end

    -- check if player is in helltide
    if player_in_helltide_zone == 1 then
    
        -- player is IN helltide
        -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player IN helltide detected")
        helltide_maiden_auto_task = helltide_maiden_auto_tasks.FOUND_ZONE

        local world_instance = world.get_current_world()
        if world_instance then
            helltide_zone_name = world_instance:get_current_zone_name()
        end

        -- load the required waypoints into maidenpos based on the current helltide_zone_name and helltide_final_maidenpos
        maidenpos_load()

        -- load waypoints for helltide_final_maidenpos after maidenpos_load()
        -- check if run_explorer is enabled/disabled via ingame menu
        if not explorer_points or explorer_circle_radius_prev ~= explorer_circle_radius then
            explorer_circle_radius_prev = explorer_circle_radius
            explorer_points = get_positions_in_radius(helltide_final_maidenpos, explorer_circle_radius)
            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - LOADED positions in helltide_final_maidenpos circle")
        end

        -- check if player arrived at helltide maiden boss
        if helltide_maiden_arrivalstate == 0 then
        
            -- mount if we are not mounted and not yet arrived at maiden  
            if current_mount_state == 0 then
                do_a_mount_or_unmount_once = 1
                do_a_mount_last_time = current_time
                -- this might get called twice because it was called to early after TP and game doesnt accept the call, next run will catch it
                utility.toggle_mount()
                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - (Re)-Mounting player in next game tick as this requires animation time and takes time to get the buffs up")
                return
            end
            
            -- proceed moving
            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Using pathfinder to walk to maiden")
            -- add final walking as pin on map for convenience
            -- set pin for final vec3 waypoint on map
            if helltide_final_maidenpos and helltide_zone_pin == 0 then
                utility.set_map_pin(helltide_final_maidenpos)
                helltide_zone_pin = 1
            end

            -- use pathfinder from core engine find closed position within vec3 table maidenpos using 1.1 threshold
            -- run only if not currently stuck
            if distance_check_is_stuck == 0 then
                -- run if NOT being stuck
                pathfinder_nextpos = pathfinder.get_next_waypoint(player_position, maidenpos, 1.1)
                if not pathfinder_nextpos then
                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - ERROR - Pathfinder cannot find next position from maidenpos")
                    return
                end
                pathfinder_nextpos = utility.set_height_of_valid_position(pathfinder_nextpos)
                pathfinder_prevpos = pathfinder_nextpos
                -- pathfinder.force_move(pathfinder_nextpos) -- faster with horse than request_move() else it would look bad
                pathfinder.force_move_raw(pathfinder_nextpos)
            else
                -- run if being stuck
                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - WARNING - Pathfinder STUCK detected finding next best walkable position based on current player position")
                helltide_maiden_auto_task = helltide_maiden_auto_tasks.FOUND_ZONE_STUCK
                -- find random position around player and force_move() instead of request_move()
                local random_pos_around_player = get_positions_in_radius(player_position, 10.0)
                local walkeable_pos = random_element(random_pos_around_player)
                walkeable_pos = utility.set_height_of_valid_position(walkeable_pos)
                if utility.is_point_walkeable_heavy(walkeable_pos) then
                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Found get_positions_in_radius() around current player_position, walking to alternative waypoint")
                    pathfinder.clear_stored_path()
                    -- pathfinder.force_move(walkeable_pos)
                    pathfinder.force_move_raw(walkeable_pos)
                end
            end

            -- check if we arrived
            if helltide_final_maidenpos then
                local distance_to_maiden = helltide_final_maidenpos:squared_dist_to(player_position)
                if distance_to_maiden < (8.0 * 8.0) then
                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Detected Player NEAR helltide maiden, setting helltide_maiden_arrivalstate")
                    helltide_maiden_arrivalstate = 1
                    -- throw away rest of this gametick to speed up
                    return
                end
            end

        else
            -- arrived at helltide maiden boss
            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player ARRIVED at helltide maiden")
            -- setting task to arrived
            helltide_maiden_auto_task = helltide_maiden_auto_tasks.ARRIVED
            
            -- unmount on arrival if mounted
            -- mount if we are not mounted and not yet arrived at maiden  
            if current_mount_state == 1 then
                do_a_mount_or_unmount_once = 1
                do_a_mount_last_time = current_time
                console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - (Re)-UnMounting player in next game tick as this requires animation time and takes time to get the buffs up")
                utility.toggle_mount()
                return
            end             

            -- check if players are in range, else we dont insert any heart at all
            if insert_hearts == 1 and menu.main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs:get() then
                -- check NO if players are in range
                local player_actors = actors_manager.get_all_actors()
                local count_players_near = 0
                for i, obj in ipairs(player_actors) do
                    local position = obj:get_position()
                    local obj_class = obj:get_character_class_id()
                    local distance_maidenposcenter_to_player = position:squared_dist_to_ignore_z(helltide_final_maidenpos)
                    -- look for other players (have obj_class via get_character_class_id) alive near explorer_circle_radius units from center of maidenpos
                    -- get_all_players() and get_ally_players() dont return any player actors, probably bugged
                    -- get_ally_actors() is much slower hence we use get_all_actors()
                    if obj_class > -1 and distance_maidenposcenter_to_player <= (explorer_circle_radius * explorer_circle_radius) then
                        count_players_near = count_players_near + 1
                    end
                end
                -- dont count yourself
                insert_only_with_npcs_playercount = count_players_near - 1
                if insert_only_with_npcs_playercount == 0 then
                    -- found no other players in range
                    -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - NO OTHER PLAYERS FOUND IN CIRCLE, disabling to put in any heart")
                    insert_hearts = 0
                end
            end -- end of insert_only_with_npcs

            -- insert one heart after some interval into altar to spawn helltide maiden boss (if enabled in plugin menu)
            if insert_hearts == 1 then

                -- check if insert_hearts_waiter isnt enabled
                if insert_hearts_waiter == 0 then

                    -- if we see helltide boss dead and user enabled to directly put heart after it, force to put heart in
                    if insert_hearts_afterboss == 1 then
                        -- check if we see the boss dead yet (filters dead enemies)
                        -- check if we werent here before, coming from previous tick still seeing the same boss as dead
                        if current_time - seen_boss_dead_time > 30.0 then -- boss cant spawn more than 30seconds after each other, impossible
                            local enemies = actors_manager.get_all_actors()
                            for i, obj in ipairs(enemies) do
                                local name = string.lower(obj:get_skin_name())
                                local is_dead = obj:is_dead() and "Dead" or "Alive"
                                -- helltide maiden asset name
                                if is_dead == "Dead" and obj:is_enemy() and name == "s04_demon_succubus_miniboss" and seen_boss_dead == 0 then
                                    -- just do this once, the corpse is there for some longer time
                                    seen_boss_dead = 1
                                    console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - BOSS DEAD SEEN, enabling insert_hearts_time")
                                    -- forces to put in heart on next tick
                                    insert_hearts_time = 1
                                    -- we must throttle seen_boss because this will trigger multiply frames, making us to inserting multiply times, we dont want this
                                    seen_boss_dead_time = current_time
                                end
                            end
                        end
                    end -- end of insert_hearts_afterboss

                    -- check for enemies around helltide boss, count them and place heart after we see no enemies for particular time, enable insert_hearts_time
                    local enemies_seen_in_circle = utility.get_units_inside_circle_list(helltide_final_maidenpos, explorer_circle_radius)
                    local seeing_enemies = 0
                    for i, obj in ipairs(enemies_seen_in_circle) do
                        -- look for alive enemies
                        if obj:is_enemy() and not obj:is_dead() then
                            seeing_enemies = seeing_enemies + 1
                            last_seen_enemies_elapsed = 0
                        end
                    end
                    seen_enemies = seeing_enemies
                    -- check if we see enemies and reached the seen_enemies_interval and user has feature enabled
                    if menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:get() then
                        if last_seen_enemies_elapsed >= menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider:get() then
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - INSERTING HEART because timer of seen_enemies_interval reached while having active enemies of = " .. seen_enemies)
                            -- reset last_seen_enemies timer
                            last_seen_enemies_elapsed = 0
                            -- forces to put in heart on next tick
                            insert_hearts_time = 1
                        else
                            last_seen_enemies_elapsed = last_seen_enemies_elapsed + 0.1
                        end
                    end

                    -- check if its time to insert a heart
                    if insert_hearts_time == 1 and insert_hearts_waiter == 0 then
                        console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - INSERTING HEART because timer of seen_enemies or seen_boss_dead")
                        -- insert logic part 1
                        -- enable the waiter and walk to center of maidenpos
                        pathfinder.clear_stored_path()
                        -- pathfinder.force_move(helltide_final_maidenpos)
                        pathfinder.force_move_raw(helltide_final_maidenpos)
                        insert_hearts_waiter = 1
                        helltide_maiden_auto_task = helltide_maiden_auto_tasks.INSERT
                        last_insert_hearts_waiter_time = current_time
                        insert_hearts_waiter_elapsed = insert_hearts_waiter_interval
                        -- save current amount of hearts
                        old_currenthearts = get_helltide_coin_hearts()
                    end
                else
                    -- insert_hearts_waiter is still enabled
                    -- check if waiter is done, which waits after putting in something to give chance to put in
                    if current_time - last_insert_hearts_waiter_time > insert_hearts_waiter_interval then
                        console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - WAITED ENOUGH TIME AFTER INTERACTION - Falling back to exploring")
                        -- we gave enough time after inserting, fall back to exploring
                        insert_hearts_waiter = 0
                        insert_hearts_waiter_elapsed = insert_hearts_waiter_interval
                        insert_hearts_time = 0
                        seen_boss_dead = 0
                    else
                        -- we are still waiting for finishing of waiter
                        helltide_maiden_auto_task = helltide_maiden_auto_tasks.INSERT
                        insert_hearts_waiter_elapsed = insert_hearts_waiter_elapsed - 0.1
                        local current_hearts = get_helltide_coin_hearts()
                        -- we should be at the center of maidenpos
                        -- try inserting at least one heart
                        if current_hearts > 0 then
                            -- check if the altar is_interactable() -- TODO fix when core improved
                            -- for now we look if enemies are there
                            -- after boss dead it is also for sure interactable
                            if seen_enemies == 0 or seen_boss_dead == 1 then
                                local actors = actors_manager.get_all_actors()
                                -- try interacting once with all of the altar as long as get_helltide_coin_hearts() doesnt change
                                for _, actor in ipairs(actors) do
                                    local name = string.lower(actor:get_skin_name())
                                    -- check if we placed a heart yet, we try every 3 altars
                                    -- this might loop multiply times because interact_object() is NOT reliable
                                    if current_hearts >= old_currenthearts then
                                        -- altar asset name
                                        if name == "s04_smp_succuboss_altar_a_dyn" then
                                          -- insert logic part 2
                                          console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - INTERACTING WITH ONE ALTER OF MAIDEN, TRYING TO INSERT ONE HEART (MIGHT FAIL)")
                                          -- interact with maiden altar
                                          interact_object(actor)
                                          -- move one to next until we have plugged in one heart at any altar
                                        end
                                    else
                                        -- we plugged one break up, kill this tick and wait for waiter mode to finish
                                        return
                                    end
                               end
                           end
                        else -- no hearts
                            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - WARNING - No hearts available to put into altar")
                        end
                    end
                end
            end

            -- start explorer logic (if enabled in plugin menu)
            -- dont run while/after inserting
            if run_explorer == 1 and insert_hearts_waiter == 0 then
                -- console.print("[HELLTIDE-MAIDEN-AUTO] tp_to_next() - RUN EXPLORER")

                if explorer_points then
                    local close_enemy_pos = nil
                    if run_explorer_is_close == 1 then
                        -- first find a close enemy within circle
                        local enemies = utility.get_units_inside_circle_list(helltide_final_maidenpos, explorer_circle_radius)
                        for i, obj in ipairs(enemies) do
                            if obj:is_enemy() then
                                local position = obj:get_position()
                                local distance = position:dist_to(player_position)
                                local is_close = distance < 6.0
                                if is_close then
                                    close_enemy_pos = position
                                    -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer found close distance enemy, walking to it")
                                    -- take first close enemy
                                    break
                                else
                                    -- not in close range but in circle within
                                    -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer found far distance enemy, walking to it")
                                    close_enemy_pos = position
                                end
                            end
                        end
                    end
                    -- if no enemy is found, use random waypoint within circle
                    if not close_enemy_pos then
                        local random_waypoint = random_element(explorer_points)
                        random_waypoint = utility.set_height_of_valid_position(random_waypoint)
                        if utility.is_point_walkeable_heavy(random_waypoint) then
                            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer found random position within circle")
                            close_enemy_pos = random_waypoint
                        end
                    end
                    -- run to next walkpoint using explorer
                    if explorer_go_next == 1 then
                        -- before evaluating to go to next waypoint, check if we reach a threshold, this will make us idle around randomly
                        -- tick rate logic slowing down movement
                        if current_time - last_explorer_threshold_check < explorer_threshold then
                            -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - WARNING - Explorer thresholding...")
                            return
                        end
                        last_explorer_threshold_check = current_time
                        -- use best suggested waypoint to walk to
                        if not close_enemy_pos then
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - ERROR - Explorer found no position to walk to")
                            return
                        end
                        -- try to never hit the same waypoint twice after same run, this makes it look like a bot shaking on one place
                        -- check if the new waypoint is at least a bit away from usage
                        local skip_new_point = 0
                        if explorer_point then
                            local distance_between_old_and_new = close_enemy_pos:dist_to(explorer_point)
                            if distance_between_old_and_new < 3.0 then
                                -- new point is too close, dont take it
                                skip_new_point = 1
                                -- console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - SKIPPING - Explorer suggested new position to close to previous position")
                            end
                        end
                        if skip_new_point == 0 then
                            -- randomize threshold variation depending on UI max value given
                            local slider_threshold = menu.main_helltide_maiden_auto_plugin_explorer_threshold:get()
                            explorer_thresholdvar = math.random(0, slider_threshold)
                            -- add the random threshold variation on top of the threshold, resulting in more randomness
                            explorer_threshold = slider_threshold + explorer_thresholdvar
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer walking next (t = " .. explorer_threshold .. " s = " .. slider_threshold .. " v = " .. explorer_thresholdvar)

                            -- use the point if its not too close to previous point
                            explorer_point = close_enemy_pos
                            -- pathfinder.request_move(explorer_point)
                            pathfinder.force_move_raw(explorer_point)

                            -- wait going to next waypoint until we reached previous
                            explorer_go_next = 0
                       end
                    else
                        -- check if should go next
                        if player_position:dist_to(explorer_point) < 2.5 then
                            console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Explorer reached prev waypoint moving next")
                            explorer_go_next = 1
                        else
                            -- keep moving
                            -- pathfinder.request_move(explorer_point)
                            pathfinder.force_move_raw(explorer_point)
                        end
                    end
                end
            else
                -- no explorer mode at helltide maiden boss
                -- reset pathfinder
                pathfinder.clear_stored_path()
            end
        end
    else
        -- Player is NOT in helltide zone
        console.print("[HELLTIDE-MAIDEN-AUTO] on_update() - Player NOT IN helltide zone")
        helltide_maiden_arrivalstate = 0
        reset_helltide_maiden()
        -- teleport to next location
        tp_to_next()
    end
end)

-- use for any graphics rendering drawing
on_render(function()

    -- failsafe to not run script early or during loading screens
    local local_player = get_local_player()
    if not local_player then
        return
    end
    -- get current player position vec3 x,y,z
    local player_position = local_player:get_position()

    -- check if plugin is enabled/disabled via ingame menu
    if not menu.main_helltide_maiden_auto_plugin_enabled:get() then
        -- do nothing when disabled
        return
    end

    -- red (R,G,B,alpha) with 0 opacity
    local color_red = color.new(255, 0, 0, 255)
    local color_white = color.new(255, 255, 255, 255)
    local color_green = color.new(0, 255, 0, 255)
    local color_yellow = color.new(255, 255, 0, 255)
    local color_blue = color.new(0, 0, 255, 255)

    -- check if main_helltide_maiden_auto_plugin_show_task is enabled/disabled via ingame menu
    if menu.main_helltide_maiden_auto_plugin_show_task:get() then
    
        -- used for printing graphics 2D text ingame at top_left_position
        local txta_top_left_position = vec2.new(0, 15)
        local txtb_top_left_position = vec2.new(0, 30)
        local txtc_top_left_position = vec2.new(0, 45)
        local txtd_top_left_position = vec2.new(0, 60)
        local txte_top_left_position = vec2.new(0, 75)
        local txtf_top_left_position = vec2.new(0, 90)

        -- print 2D text at top_left_position using font-size 16 in color red
        if helltide_maiden_auto_task == helltide_maiden_auto_tasks.IN_TELEPORT then
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current task: " .. helltide_maiden_auto_task .. " ... ", txta_top_left_position, 13, color_red)
        else
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current task: " .. helltide_maiden_auto_task, txta_top_left_position, 13, color_red)
        end

        local explorer_threshold_rounded_no_decimals = round(explorer_threshold, 0)
        local explorer_thresholdvar_rounded_no_decimals = round(explorer_thresholdvar, 0)
        if run_explorer_mode == run_explorer_modes.OFF then
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current explorer mode: " .. run_explorer_mode, txtb_top_left_position, 13, color_white)
        else
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current explorer mode: " .. run_explorer_mode .. " Next Position: " .. explorer_threshold_rounded_no_decimals .. "s (added random " .. explorer_thresholdvar_rounded_no_decimals .. "s)", txtb_top_left_position, 13, color_white)
        end

        local distance_check_distance_rounded_no_decimals = round(distance_check_distance, 0)
        graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Distance checker: " .. distance_check_distance_rounded_no_decimals .. "u Is_Stuck: " .. distance_check_is_stuck .. " Stuck Counter: " .. distance_check_is_stuck_counter, txtc_top_left_position, 13, color_white)
        graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Current helltide zone: " .. helltide_zone_name .. " Next teleporter zone: " .. helltide_tps_next_zone_name, txtd_top_left_position, 13, color_white)

        if insert_hearts == 1 then
            local seen_enemies_interval_rounded_no_decimals = round(menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies_interval_slider:get(), 0)
            local insert_hearts_waiter_elapsed_rounded_no_decimals = round(insert_hearts_waiter_elapsed, 0)
            local last_seen_enemies_elapsed_rounded_no_decimals = round(last_seen_enemies_elapsed, 0)
            local seen_enemies_is_enabled = 0
            if menu.main_helltide_maiden_auto_plugin_insert_hearts_afternoenemies:get() then
                seen_enemies_is_enabled = 1
            end
            local insert_onlywithnpcs_enabled = 0
            if menu.main_helltide_maiden_auto_plugin_insert_hearts_onlywithnpcs:get() then
                insert_onlywithnpcs_enabled = 1
            end
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Inserting hearts: Enabled (current playersinrange: ".. insert_only_with_npcs_playercount .. " insert when playersinrange: " .. insert_onlywithnpcs_enabled .. " insert afternoenmies: " .. seen_enemies_is_enabled .. " insert afterboss: " .. insert_hearts_afterboss .. ")", txte_top_left_position, 13, color_white)
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Inserting hearts: seen_enemies_interval: " .. seen_enemies_interval_rounded_no_decimals .. "s seen_enemies: " .. seen_enemies .." seen_elapsed: " .. last_seen_enemies_elapsed_rounded_no_decimals .. "s waiter_interval: " .. insert_hearts_waiter_interval .. "s start_waiter: " .. insert_hearts_waiter .." waiter_elapsed: " .. insert_hearts_waiter_elapsed_rounded_no_decimals .. "s", txtf_top_left_position, 13, color_white)
        else
            graphics.text_2d("[HELLTIDE-MAIDEN-AUTO] Inserting hearts: Disabled / Or currently no player in range", txte_top_left_position, 13, color_white)
        end

        -- shows helper text on first time arrival
        if helltide_maiden_auto_task == helltide_maiden_auto_tasks.ARRIVED then
            if not show_helper_text_time_up then
                show_helper_text_time_up = os.clock()
            end
            -- show helper_text only for 20 seconds
            if os.clock() - show_helper_text_time_up < 20.0 then
                local help_middle_left = vec2.new((get_screen_width() / 6), (get_screen_height() / 2))
                local help_middle_lefta = vec2.new((get_screen_width() / 6), (get_screen_height() / 2) + 40)
                local help_middle_leftb = vec2.new((get_screen_width() / 6), (get_screen_height() / 2) + 80)
                local help_middle_leftc = vec2.new((get_screen_width() / 6), (get_screen_height() / 2) + 120)
                -- print 2D text at top_left_position using font-size 16 in color red
                graphics.text_2d("Arrived at helltide maiden boss", help_middle_left, 40, color_red)
                graphics.text_2d("Everything is automatic", help_middle_lefta, 40, color_red)
             
            end
        end
    end
    
    -- draw exploring circle
    if menu.main_helltide_maiden_auto_plugin_show_explorer_circle:get() and run_explorer == 1 then
        if helltide_maiden_arrivalstate == 1 then
            if helltide_final_maidenpos then
                -- draw circle around helltide_final_maidenpos based on draw_explorer_circle_radius in color_white
                graphics.circle_3d(helltide_final_maidenpos, explorer_circle_radius, color_white)

                -- draw next explorer_point position in color_blue
                if explorer_point then
                    graphics.circle_3d(explorer_point, 2, color_blue)
                end

                -- draw all explorer_points positions in color_yellow
                if explorer_points then
                    local lengths = table_length(explorer_points)
                    -- for i, points in ipairs(explorer_points) do
                        -- only useful during debugging
                        -- graphics.circle_3d(points, 1, color_yellow)
                    -- end
                end
            end
        end
    end
end)

console.print("Lua Plugin - Helltide Maiden Auto - Version 1.3")
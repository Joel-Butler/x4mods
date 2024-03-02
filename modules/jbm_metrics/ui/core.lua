local ffi = require("ffi")
local C = ffi.C
local Lib = require("extensions.sn_mod_support_apis.lua_interface").Library
local json = require("extensions.jbm_metrics.ui.dkjson")

local mapMenu

local external = {
    output = {}
};

local function init ()
    DebugError("jbm_metrics core.lua: INIT")

    -- Main event
    RegisterEvent("jbm_metrics.getMetrics", external.getOutput)

    -- Reputations and Professions mod event triggered after all available guild missions offers are created AFTER the player clicks on the "Connect to the Guild Network" button
    RegisterEvent("kProfs.guildNetwork_onLoaded", external.getOutput)

    mapMenu = Lib.Get_Egosoft_Menu("MapMenu")
end

function external.getOutput (_, param)
    local metricData = external.fetchData()
    -- DebugError("jbm_metrics - metrics pass results : " ..  metricData.credits .. ".")
    AddUITriggeredEvent("eventlog_ui_trigger", "jbm_metrics_ui", json.encode(metricData))
end

function external.fetchData()
    local data = {}
    data.credits = GetPlayerMoney()
    data.gameTime = C.GetCurrentGameTime()

    --get number of stations owned
    local numStations = C.GetNumAllFactionStations("player")
    --create object for stations - array of UniverseIDs of size (numstations)
    local allownedstations = ffi.new("UniverseID[?]", numStations)
    --load array
    numStations = C.GetAllFactionStations(allownedstations, numStations, "player")
    
    local numShips = C.GetNumAllFactionShips("player")
	local allownedships = ffi.new("UniverseID[?]", numShips)
	numShips = C.GetAllFactionShips(allownedships, numShips, "player")
    
    data.shipsXL =0
    data.shipsL = 0
    data.shipsM = 0
    data.shipsS = 0

    for i=0, numShips-1 do 
        local locship = ConvertStringTo64Bit(tostring(allownedships[i]))
        if (not C.IsUnit(locship)) and (C.IsComponentOperational(locship)) and (not GetMacroData(GetComponentData(locship, "macro"), "islasertower")) then
            if C.IsComponentClass(locship, "ship_s") then
              data.shipsS = data.shipsS + 1
            elseif C.IsComponentClass(locship, "ship_m") then
                data.shipsM = data.shipsM + 1
            elseif C.IsComponentClass(locship, "ship_l") then
                data.shipsL = data.shipsL + 1
            elseif C.IsComponentClass(locship, "ship_xl") then
                data.shipsXL = data.shipsXL + 1
            end
        end
    end

    local transEndTime = C.GetCurrentGameTime()
    -- metrics for last 6 hours
    local starttime = math.max(0, transEndTime - 360)
    ---local transData = 
    for i=0, numStations-1 do 
        --TODO: iterate through stations and extract data.
    end

    data.stations = numStations
    data.ships = numShips

    return data;
end

init()
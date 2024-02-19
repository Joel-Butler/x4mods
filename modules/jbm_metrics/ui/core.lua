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
    return data;
end



init()
--
-- Captain Shuffle script
-- Intended for use on the map menu, allows assignment of the highest ranking unassigned captain to a selected ship.
--
--

-- ffi setup
local ffi = require("ffi")
local C = ffi.C

local modules = {}
Captain_Shuffle = {
   fleetUnits = {}
}

local function init()
   RegisterEvent("JBMCaptainShuffle", Captain_Shuffle.captainShuffle)
end


-- function 
function Captain_Shuffle.captainShuffle(_, params)
   DebugError("Called Lua model with params " .. _ .. " and " .. params)
   -- Okay - that worked and we got a result... that is real progress!
   -- from menumap it looks like this created an appropriate entity object entity = ConvertStringTo64Bit(tostring(menu.modeparam[2]))
   local fleetCommander = ConvertStringTo64Bit(tostring(params))
   -- logic from menumap - note we appear to be struggling with using this controllable as the fleet commander...
   local num_fleetunits = C.GetNumFleetUnitSubordinateFleetUnits(fleetCommander, -1)
   if num_fleetunits > 0 then
      local buf_fleetunits = ffi.new("FleetUnitID[?]", num_fleetunits)
      num_fleetunits = C.GetFleetUnitSubordinateFleetUnits(buf_fleetunits, num_fleetunits, fleetCommander, -1)
      for j = 0, num_fleetunits - 1 do
         local fleetunitsubordinate = buf_fleetunits[j]
         table.insert(Captain_Shuffle.fleetUnits,{ fleetunit = fleetunitsubordinate })
      end
   end
   DebugError("Injected " .. num_fleetunits .. " to table. Table Content sample: " .. Captain_Shuffle.fleetUnits[-1])
   
   -- this bit doesn't quite work yet... :-)
   AddUITriggeredEvent("JBMShuffle", params, "Called Lua model with params " .. _ .. " and " .. params)

end

--- init ---

init()

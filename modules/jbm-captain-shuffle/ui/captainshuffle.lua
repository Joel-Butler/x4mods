--
-- Captain Shuffle script
-- Intended for use on the map menu, allows assignment of the highest ranking unassigned captain to a selected ship.
--
--

-- ffi setup

local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t AIOrderID;
	typedef int32_t BlacklistID;
	typedef uint64_t BuildTaskID;
	typedef int32_t FightRuleID;
	typedef uint64_t FleetUnitID;
	typedef uint64_t MissionID;
	typedef uint64_t NPCSeed;
	typedef uint64_t TradeID;
	typedef int32_t TradeRuleID;
	typedef uint64_t UniverseID;

	const char* ConvertInputString(const char* text, const char* defaultvalue);
	uint64_t ConvertStringTo64Bit(const char* idstring);
	const char* FormatDateTimeString(int64_t time, const char* uiformat);
	int64_t GetCurrentUTCDataTime(void);
	const char* GetUserData(const char* name);
   const char* GetFleetName(UniverseID controllableid);
   uint64_t GetFleetUnit(UniverseID controllableid);
   uint32_t GetAllFleetUnits(FleetUnitID* result, uint32_t resultlen, UniverseID controllableid);
   uint32_t GetNumFleetUnitSubordinateFleetUnits(FleetUnitID fleetunitid, int subordinategroupid);
   uint32_t GetNumFleetUnitSubordinates(FleetUnitID fleetunitid, int32_t subordinategroupid);
   uint32_t GetFleetUnitSubordinateFleetUnits(FleetUnitID* result, uint32_t resultlen, FleetUnitID fleetunitid, int subordinategroupid);
   bool IsComponentClass(UniverseID componentid, const char* classname);
   const char* GetComponentName(UniverseID componentid);

   typedef struct {
		FleetUnitID fleetunitid;
		const char* name;
		const char* idcode;
		const char* macro;
		BuildTaskID buildtaskid;
		UniverseID replacementid;
	} FleetUnitInfo;


]]


local modules = {}
Captain_Shuffle = {
	fleetUnits = {},
	numFleetUnits = 0,  
	fleetCaptains = {},
	numFleetCaptains =0,
	shuffleableEmployees = {},
	numShuffleableEmployees = 0
}

local function init()
   RegisterEvent("JBMCaptainShuffle", Captain_Shuffle.captainShuffle)
end


-- function 
function Captain_Shuffle.captainShuffle(_, params)
   -- Okay - that worked and we got a result... that is real progress!
   -- from menumap it looks like this created an appropriate entity object entity = ConvertStringTo64Bit(tostring(menu.modeparam[2]))
   -- did we get the ship we expected? 
   AddUITriggeredEvent("JBMShuffle", "Starting Lua")
   local controllable = C.ConvertStringTo64Bit(tostring(params))
   if(C.IsComponentClass(controllable, "ship")) then
		local subordinates = GetSubordinates(params)
		Captain_Shuffle.fleetUnits = subordinates
		Captain_Shuffle.numFleetUnits = #subordinates
		if Captain_Shuffle.numFleetUnits > 0 then
        	AddUITriggeredEvent("JBMShuffle", "It worked, got ".. tostring(Captain_Shuffle.numFleetUnits) .. " subordinates.")

         -- TODO: Get captains and skills - create table of ships and captains - generate combined captain skill 
			Captain_Shuffle.loadCaptains()
         -- TODO: Create table of crew in Marine, Unassigned and Service roles sorted by combined captain skill (highest to lowest)
			Captain_Shuffle.loadEmployees()
			AddUITriggeredEvent("JBMShuffle", "Shufflable Employee count is: ".. tostring(Captain_Shuffle.numShuffleableEmployees) .. ".")
			Captain_Shuffle.sortEmployees()
			-- Lua ipars tables appear to start at 1
			AddUITriggeredEvent("JBMShuffle", "Empoyees sorted Top Captain candidate is: ".. Captain_Shuffle.shuffleableEmployees[1].name .. ".")
         -- TODO: For each captain in list, if the first (best) potential captain is better skilled, transfer. 
		 for _, captain in ipairs(Captain_Shuffle.fleetCaptains) do
			--is the top shuffleableEmployee more skilled? 
			--yes : transfer and remove the transferred employee from the table. 
			-- no: continue to the next captain (our ordered list means we assume that if the top is no good, the rest will not be either)
			if(captain.skill < Captain_Shuffle.shuffleableEmployees[1].skill) then
				AddUITriggeredEvent("JBMShuffle", "Identified potential transfer from : " .. captain.name .. " To: " .. Captain_Shuffle.shuffleableEmployees[1].name .. ".")
				--now we need to figure out the best path to transfer... There's a UI example of this we could leverage...
			end
		 end
         -- Report Done.
         
      else 
         AddUITriggeredEvent("JBMShuffle", "No subordinates for Controllable " .. 
            tostring(params) .. " name: " .. 
            ffi.string(C.GetComponentName(controllable)) ..
            " fleet: " ..
            ffi.string(C.GetFleetName(controllable)) .. 
            " fleetunit " .. tostring(fleetunit)
         )
      end
   else 
      AddUITriggeredEvent("JBMShuffle", "Invalid object passed to Lua (ComponentClass is not 'ship')")
   
   end
end

function Captain_Shuffle.GetCaptains()

end


function Captain_Shuffle.loadEmployees()

   -- todo: We want role of captain, but we only want people in role Marine, Unassigned or Service
   -- unassigned: roleid == "unassigned"
   -- roleID for captain: aipilot
   -- 
   -- Ego do this by iterating over each ship and station... we'll need to do the same. 
   -- Derived from function menu.getEmployeeList() in menu_playerinfo.lua


   -- While the menu allows sorting by different skills, we just want good captains, 
   -- and want to exclude people doing an 'important' job - so effectively we want marines,
   -- service crew and unassigned. 

   -- TODO: It would be super nice to be able to also grab people from the terraform buckets. 
   local targetPost = "aipilot"
   local roles = { "marine", "service", "unassigned"}
   local role = "post:aipilot"

	local rolemax = C.GetNumAllRoles()

	-- interesting approach - using the max of potential people to create inner arrays/tables. 
	local shipPeopleTable = ffi.new("PeopleInfo[?]", rolemax)

   -- this bit is straight from getEmployeeList()... 
   -- give the empire employee list an update to avoid referencing destroyed objects
	local numhiredpersonnel = 0
	local empireemployees = {}

	local numownedships = C.GetNumAllFactionShips("player")
	local allownedships = ffi.new("UniverseID[?]", numownedships)
	numownedships = C.GetAllFactionShips(allownedships, numownedships, "player")
	-- Note - from a C array/table object, we need to do from 0 n-1
	for i = 0, numownedships - 1 do
		local aship = ConvertStringTo64Bit(tostring(allownedships[i]))
		if(Captain_Shuffle.isShip(aship)) then
			local shipPeopleCount = C.GetPeople2(shipPeopleTable, rolemax, aship, true)
			for i = 0, shipPeopleCount - 1 do
				numhiredpersonnel = numhiredpersonnel + shipPeopleTable[i].amount
				local roleid = ffi.string(shipPeopleTable[i].id)
				local numtiers = shipPeopleTable[i].numtiers
				-- I'm unclear on the use of tiers here... we've got People, now we're inserting based on a new call of GetRoleTIerNPCs?
				if numtiers > 0 then
					local tiertable = ffi.new("RoleTierData[?]", numtiers)
					numtiers = C.GetRoleTiers(tiertable, numtiers, aship, shipPeopleTable[i].id)
					for j = 0, numtiers - 1 do
						local numpersons = tiertable[j].amount
						if numpersons > 0 then
							local persontable = GetRoleTierNPCs(aship, roleid, tiertable[j].skilllevel)
							for k, person in ipairs(persontable) do
								table.insert(empireemployees, { id = person.seed, name = person.name, combinedskill = person.combinedskill, roleid = roleid, container = aship})
							end
						end
					end
				elseif roleid == "unassigned" then
					local persontable = GetRoleTierNPCs(locship, roleid, 0)
					--print("numpersons: " .. tostring(#persontable))
					for k, person in ipairs(persontable) do
						--print(k .. ": " .. person.name)
						table.insert(empireemployees, { id = person.seed, name = person.name, combinedskill = person.combinedskill, roleid = roleid, container = aship})
					end
				end
			end
		end
	end

	-- let's ensure the skill value is set appropriately to our captain skill
	local filteredemployees = {}
	local numfilteredemployees = 0
	for _, employeedata in ipairs(empireemployees) do
		if employeedata.type == "person" then
			employeedata.skill = C.GetPersonCombinedSkill(C.ConvertStringTo64Bit(tostring(employeedata.container)), C.ConvertStringTo64Bit(tostring(employeedata.id)), role, targetPost)
		else
			employeedata.skill = C.GetEntityCombinedSkill(C.ConvertStringTo64Bit(tostring(employeedata.id)), role, targetPost)
		end
		table.insert(filteredemployees, employeedata)
		numfilteredemployees = numfilteredemployees +1
	end
	Captain_Shuffle.shuffleableEmployees = filteredemployees
	Captain_Shuffle.numShuffleableEmployees = numfilteredemployees
	-- Sort avaialable employees by captain skill. 
   	Captain_Shuffle.sortEmployees()
end

function Captain_Shuffle.isShip(component)
		--we're expecting a uint64_t that is a component.
		if(C.IsComponentClass(component, "ship")) then 
			
			local macro, isdeployable = GetComponentData(component, "macro", "isdeployable")
			local islasertower, ware = GetMacroData(macro, "islasertower", "ware")
			local isunit = C.IsUnit(component)
			-- does this contain stuff, while not being a deployable, laser tower or a unit...
			-- TODO: Is there a more efficient comparision here to determine ships with NPCs onboard? 
			return ware and (not isunit) and (not islasertower) and (not isdeployable) 
		else
			return false
		end
end

function Captain_Shuffle.loadCaptains()
	local captains = {}
	local numCaptains=0
	-- shipData should be a component object... 
	for _, shipData in ipairs(Captain_Shuffle.fleetUnits) do
		local idCode = ConvertIDTo64Bit(subordinate)
		local shipname, pilot = GetComponentData(shipData, "name", "assignedaipilot")
		if pilot and IsValidComponent(pilot) then
			local name, combinedskill, poststring, postname = GetComponentData(pilot, "name", "combinedskill", "poststring", "postname")
			-- our Captain's combinedskill in their active role is the skill we care about, so we'll just assgin this to 'skill'
			table.insert(captains, { id = ConvertIDTo64Bit(pilot), type = "entity", name = name, skill = combinedskill, roleid = poststring, rolename = postname, container = shipData, containername = shipname })
			numCaptains = numCaptains + 1
		end
	end
	Captain_Shuffle.fleetCaptains = captains
	Captain_Shuffle.numFleetCaptains = numCaptains
end


function Captain_Shuffle.skillSorter(a, b, invert)
	if a.skill == b.skill then
		return a.name < b.name
	end
	if invert then
		return a.skill < b.skill
	else
		return a.skill > b.skill
	end
end

function Captain_Shuffle.sortEmployees()
	
	table.sort(Captain_Shuffle.shuffleableEmployees, 
		function (a, b) 
			return Captain_Shuffle.skillSorter(a, b, false)
		end
	)
end

--- init ---

init()

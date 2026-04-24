-- ======================================================
-- TPG BATTLE COST COUNTER V2.0 EXTERNAL DB
-- FULL DROP-IN READY
-- ======================================================

WeaponTracker = {}
local lfs = require("lfs")

WeaponTracker.data = {
    [1] = { name = "RED COALITION",  shots = {}, losses = {}, totalCost = 0 },
    [2] = { name = "BLUE COALITION", shots = {}, losses = {}, totalCost = 0 }
}

WeaponTracker.ui = {
    expanded = true,
    displayEnabled = false,
    scriptEnabled = true
}

-- prevent duplicate death/crash logging
WeaponTracker.deadUnits = {}

-- ------------------------------------------------------
-- LOAD COST DATABASE
-- ------------------------------------------------------

local unitCosts = {}
local dcsPath = lfs.writedir()
local dbPath = dcsPath .. "Scripts\\tpg_cost_db.lua"

local ok, err = pcall(function()
    dofile(dbPath)
end)

if ok and type(TPG_COST_DB) == "table" then
    unitCosts = TPG_COST_DB
    env.info("TPG COST DB LOADED SUCCESSFULLY")
else
    env.info("TPG COST DB FAILED TO LOAD: " .. tostring(err))
end

-- ------------------------------------------------------
-- SAFE HELPERS
-- ------------------------------------------------------

local function hasMethod(obj, methodName)
    return obj ~= nil and type(obj[methodName]) == "function"
end

local function safeGetCoalition(obj)
    if hasMethod(obj, "getCoalition") then
        local okCall, result = pcall(function()
            return obj:getCoalition()
        end)
        if okCall then
            return result
        end
    end
    return nil
end

local function safeGetTypeName(obj)
    if hasMethod(obj, "getTypeName") then
        local okCall, result = pcall(function()
            return obj:getTypeName()
        end)
        if okCall then
            return result
        end
    end
    return nil
end

local function safeGetID(obj)
    if hasMethod(obj, "getID") then
        local okCall, result = pcall(function()
            return obj:getID()
        end)
        if okCall then
            return result
        end
    end
    return nil
end

local function safeGetName(obj)
    if hasMethod(obj, "getName") then
        local okCall, result = pcall(function()
            return obj:getName()
        end)
        if okCall then
            return result
        end
    end
    return nil
end

local function safeGetCategory(obj)
    if hasMethod(obj, "getCategory") then
        local okCall, result = pcall(function()
            return obj:getCategory()
        end)
        if okCall then
            return result
        end
    end
    return nil
end

local function buildDeadUnitKey(obj)
    local unitName = safeGetName(obj)
    if unitName and unitName ~= "" then
        return "NAME:" .. tostring(unitName)
    end

    local unitID = safeGetID(obj)
    if unitID ~= nil then
        return "ID:" .. tostring(unitID)
    end

    local typeName = safeGetTypeName(obj) or "Unknown"
    local side = safeGetCoalition(obj) or "NA"
    return "FALLBACK:" .. tostring(typeName) .. "|" .. tostring(side)
end

-- ------------------------------------------------------
-- COST LOOKUP (EXACT MATCH EXCEPT CASE)
-- ------------------------------------------------------

local function getCost(name)

    if not name then
        return 0, "Unknown"
    end

    local cleanName = tostring(name):gsub("weapons.shells%.", "")
    local nameLower = string.lower(cleanName)

    for dbName, entry in pairs(unitCosts) do
        if string.lower(tostring(dbName)) == nameLower then
            if type(entry) == "table" then
                return entry[1] or 0, entry[2] or "Unknown"
            else
                return entry or 0, "Unknown"
            end
        end
    end

    return 0, "Unknown"
end

-- ------------------------------------------------------
-- CSV EXPORT
-- ------------------------------------------------------

WeaponTracker.csvPath = dcsPath .. "Logs\\TPG_LIVE.csv"

function WeaponTracker.resetLiveCSV()

    local file = io.open(WeaponTracker.csvPath, "w")

    if file then
        file:write("row_type,time,side,event,name,count,total_cost,pct,category\n")
        file:close()
        env.info("TPG CSV RESET SUCCESS")
    else
        env.info("TPG CSV RESET FAILED")
    end
end

function WeaponTracker.exportLiveCSV()

    local missionTime = timer.getTime()

    local blue = WeaponTracker.data[coalition.side.BLUE]
    local red  = WeaponTracker.data[coalition.side.RED]

    if not blue or not red then
        return
    end

    local file = io.open(WeaponTracker.csvPath, "a")
    if not file then
        env.info("TPG CSV OPEN FAILED")
        return
    end

    file:write("TOTAL," .. missionTime .. ",BLUE,,,," .. blue.totalCost .. ",,\n")
    file:write("TOTAL," .. missionTime .. ",RED,,,," .. red.totalCost .. ",,\n")

    for sideID = 2, 1, -1 do

        local d = WeaponTracker.data[sideID]
        local sideName = sideID == 2 and "BLUE" or "RED"
        local coalitionTotal = d.totalCost > 0 and d.totalCost or 1

        -- --------------------------------------------------
        -- FIRED EVENTS
        -- --------------------------------------------------

        for name, count in pairs(d.shots) do

            local costPerUnit, category = getCost(name)
            local total = costPerUnit * count
            local pct = (total / coalitionTotal) * 100

            file:write(
                "ITEM," ..
                missionTime .. "," ..
                sideName .. "," ..
                "FIRED," ..
                tostring(name) .. "," ..
                tostring(count) .. "," ..
                tostring(total) .. "," ..
                tostring(pct) .. "," ..
                tostring(category or "Unknown") ..
                "\n"
            )
        end

        -- --------------------------------------------------
        -- LOSS EVENTS
        -- --------------------------------------------------

        for name, count in pairs(d.losses) do

            local costPerUnit, category = getCost(name)
            local total = costPerUnit * count
            local pct = (total / coalitionTotal) * 100

            file:write(
                "ITEM," ..
                missionTime .. "," ..
                sideName .. "," ..
                "LOSS," ..
                tostring(name) .. "," ..
                tostring(count) .. "," ..
                tostring(total) .. "," ..
                tostring(pct) .. "," ..
                tostring(category or "Unknown") ..
                "\n"
            )
        end
    end

    file:close()
end

-- ------------------------------------------------------
-- EVENT HANDLER
-- ------------------------------------------------------

function WeaponTracker:onEvent(event)

    if not self.ui.scriptEnabled then return end
    if not event then return end

    -- --------------------------------------------------
    -- WEAPON FIRED
    -- --------------------------------------------------

    if event.id == world.event.S_EVENT_SHOT or event.id == world.event.S_EVENT_SHELL_FIRED then

        if event.initiator and event.weapon then

            local side = safeGetCoalition(event.initiator)

            if side and side > 0 and self.data[side] then

                local name = safeGetTypeName(event.weapon)

                if name and name ~= "" then
                    self.data[side].shots[name] =
                        (self.data[side].shots[name] or 0) + 1

                    local cost = getCost(name)
                    self.data[side].totalCost =
                        self.data[side].totalCost + cost
                end
            end
        end

        return
    end

    -- --------------------------------------------------
    -- UNIT DESTROYED / CRASHED
    -- --------------------------------------------------

    if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_CRASH then

        if event.initiator then

            local unit = event.initiator
            local side = safeGetCoalition(unit)

            if not side or side <= 0 or not self.data[side] then
                return
            end

            local key = buildDeadUnitKey(unit)

            if WeaponTracker.deadUnits[key] then
                return
            end

            WeaponTracker.deadUnits[key] = true

            local name = safeGetTypeName(unit)

            if name and name ~= "" then
                self.data[side].losses[name] =
                    (self.data[side].losses[name] or 0) + 1

                local cost = getCost(name)
                self.data[side].totalCost =
                    self.data[side].totalCost + cost
            end
        end

        return
    end
end

-- ------------------------------------------------------
-- CSV REFRESH LOOP
-- ------------------------------------------------------

function WeaponTracker.refreshUI()
    WeaponTracker.exportLiveCSV()
    return timer.getTime() + 1
end

world.addEventHandler(WeaponTracker)
WeaponTracker.resetLiveCSV()
timer.scheduleFunction(WeaponTracker.refreshUI, nil, timer.getTime() + 1)

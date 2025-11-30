--[[
    Nameplate Example Addon
    
    This addon demonstrates how to:
    1. Get nameplate information from NPCs (enemies)
    2. Use events to track nameplates instead of polling
    3. Check nameplate visibility using IsVisible()
    4. Properly work with namePlateUnitTokens
]]

-- Create main addon frame
local NameplateExample = CreateFrame("Frame", "NameplateExampleFrame")
local addonName = "NameplateExample"

-- Storage for tracked nameplates
local trackedNameplates = {}

-- Configuration
local config = {
    debugMode = true,          -- Print debug messages
    trackEnemyNPCs = true,     -- Track enemy NPCs
    trackFriendlyNPCs = false, -- Track friendly NPCs
    trackPlayers = false,      -- Track players
}

-- Utility function for debug printing
local function DebugPrint(...)
    if config.debugMode then
        print(string.format("[%s]", addonName), ...)
    end
end

-- Check if a unit should be tracked based on configuration
local function ShouldTrackUnit(unitToken)
    if not UnitExists(unitToken) then
        return false
    end
    
    local isPlayer = UnitIsPlayer(unitToken)
    local isEnemy = UnitIsEnemy("player", unitToken)
    
    -- Player tracking
    if isPlayer and config.trackPlayers then
        return true
    end
    
    -- NPC tracking
    if not isPlayer then
        if isEnemy and config.trackEnemyNPCs then
            return true
        elseif not isEnemy and config.trackFriendlyNPCs then
            return true
        end
    end
    
    return false
end

-- Get detailed unit information
local function GetUnitInfo(unitToken)
    if not UnitExists(unitToken) then
        return nil
    end
    
    return {
        name = UnitName(unitToken) or "Unknown",
        level = UnitLevel(unitToken) or 0,
        health = UnitHealth(unitToken) or 0,
        maxHealth = UnitHealthMax(unitToken) or 1,
        healthPercent = 0,
        classification = UnitClassification(unitToken) or "normal",
        isPlayer = UnitIsPlayer(unitToken),
        isEnemy = UnitIsEnemy("player", unitToken),
        isDead = UnitIsDead(unitToken),
        inCombat = UnitAffectingCombat(unitToken),
        canAttack = UnitCanAttack("player", unitToken),
        threatSituation = UnitThreatSituation("player", unitToken),
    }
end

-- Update health percentage
local function UpdateHealthPercent(info)
    if info and info.maxHealth > 0 then
        info.healthPercent = (info.health / info.maxHealth) * 100
    end
end

-- Handle nameplate added event
local function OnNamePlateAdded(unitToken)
    -- Check if we should track this unit
    if not ShouldTrackUnit(unitToken) then
        return
    end
    
    -- Get the nameplate frame
    local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
    if not namePlateFrame then
        DebugPrint("Warning: Could not get nameplate frame for", unitToken)
        return
    end
    
    -- Get unit information
    local unitInfo = GetUnitInfo(unitToken)
    if not unitInfo then
        return
    end
    
    UpdateHealthPercent(unitInfo)
    
    -- Store tracked nameplate data
    trackedNameplates[unitToken] = {
        unitToken = unitToken,
        frame = namePlateFrame,
        info = unitInfo,
        addedTime = GetTime(),
        lastUpdate = GetTime(),
    }
    
    -- Check visibility using IsVisible() - this is the standard frame method
    local isVisible = namePlateFrame:IsVisible()
    
    -- Print information about the tracked nameplate
    local npcType = unitInfo.isPlayer and "Player" or "NPC"
    local faction = unitInfo.isEnemy and "Enemy" or "Friendly"
    
    DebugPrint(string.format(
        "Tracked %s %s: %s (Level %d %s) - HP: %.1f%% - Visible: %s",
        faction,
        npcType,
        unitInfo.name,
        unitInfo.level,
        unitInfo.classification,
        unitInfo.healthPercent,
        tostring(isVisible)
    ))
end

-- Handle nameplate removed event
local function OnNamePlateRemoved(unitToken)
    if trackedNameplates[unitToken] then
        local data = trackedNameplates[unitToken]
        local duration = GetTime() - data.addedTime
        
        DebugPrint(string.format(
            "Lost track of: %s (tracked for %.1f seconds)",
            data.info.name,
            duration
        ))
        
        trackedNameplates[unitToken] = nil
    end
end

-- Update all tracked nameplates
local function UpdateTrackedNameplates()
    for unitToken, data in pairs(trackedNameplates) do
        if UnitExists(unitToken) then
            -- Update unit information
            local newInfo = GetUnitInfo(unitToken)
            if newInfo then
                UpdateHealthPercent(newInfo)
                data.info = newInfo
                data.lastUpdate = GetTime()
                
                -- Update visibility status
                -- IMPORTANT: IsVisible() is a standard frame method, NOT a custom method
                data.isVisible = data.frame and data.frame:IsVisible() or false
            end
        else
            -- Unit no longer exists, remove it
            trackedNameplates[unitToken] = nil
        end
    end
end

-- Event handler
NameplateExample:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unitToken = ...
        OnNamePlateAdded(unitToken)
        
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unitToken = ...
        OnNamePlateRemoved(unitToken)
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        DebugPrint("Player entered world, nameplate tracking active")
        
        -- Iterate through any existing nameplates (useful on reload)
        -- This demonstrates Method 2 from the guide
        local nameplates = C_NamePlate.GetNamePlates(issecure())
        for _, namePlateFrame in pairs(nameplates) do
            -- Access unit token via GetUnit() method
            local unitToken = namePlateFrame:GetUnit()
            
            if unitToken and UnitExists(unitToken) then
                OnNamePlateAdded(unitToken)
            end
        end
    end
end)

-- Register events
NameplateExample:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NameplateExample:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
NameplateExample:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Create update ticker for periodic updates
local updateTicker = C_Timer.NewTicker(0.5, function()
    UpdateTrackedNameplates()
end)

-- Slash commands for user interaction
SLASH_NAMEPLATEEXAMPLE1 = "/npex"
SLASH_NAMEPLATEEXAMPLE2 = "/nameplateexample"

SlashCmdList["NAMEPLATEEXAMPLE"] = function(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()
    
    if command == "list" then
        -- List all tracked nameplates
        print(string.format("[%s] Currently tracked nameplates:", addonName))
        local count = 0
        for unitToken, data in pairs(trackedNameplates) do
            count = count + 1
            local visible = data.isVisible and "Yes" or "No"
            local combat = data.info.inCombat and "Yes" or "No"
            
            print(string.format(
                "  %s (Level %d) - HP: %.1f%% - Visible: %s - Combat: %s",
                data.info.name,
                data.info.level,
                data.info.healthPercent,
                visible,
                combat
            ))
        end
        if count == 0 then
            print("  No nameplates currently tracked")
        end
        
    elseif command == "config" then
        -- Show current configuration
        print(string.format("[%s] Current Configuration:", addonName))
        print(string.format("  Debug Mode: %s", tostring(config.debugMode)))
        print(string.format("  Track Enemy NPCs: %s", tostring(config.trackEnemyNPCs)))
        print(string.format("  Track Friendly NPCs: %s", tostring(config.trackFriendlyNPCs)))
        print(string.format("  Track Players: %s", tostring(config.trackPlayers)))
        
    elseif command == "debug" then
        -- Toggle debug mode
        config.debugMode = not config.debugMode
        print(string.format("[%s] Debug mode: %s", addonName, tostring(config.debugMode)))
        
    elseif command == "enemy" then
        -- Toggle enemy NPC tracking
        config.trackEnemyNPCs = not config.trackEnemyNPCs
        print(string.format("[%s] Track enemy NPCs: %s", addonName, tostring(config.trackEnemyNPCs)))
        
    elseif command == "friendly" then
        -- Toggle friendly NPC tracking
        config.trackFriendlyNPCs = not config.trackFriendlyNPCs
        print(string.format("[%s] Track friendly NPCs: %s", addonName, tostring(config.trackFriendlyNPCs)))
        
    elseif command == "players" then
        -- Toggle player tracking
        config.trackPlayers = not config.trackPlayers
        print(string.format("[%s] Track players: %s", addonName, tostring(config.trackPlayers)))
        
    elseif command == "count" then
        -- Show count of tracked nameplates
        local count = 0
        for _ in pairs(trackedNameplates) do
            count = count + 1
        end
        print(string.format("[%s] Currently tracking %d nameplates", addonName, count))
        
    elseif command == "help" or command == "" then
        -- Show help
        print(string.format("[%s] Commands:", addonName))
        print("  /npex list - List all tracked nameplates")
        print("  /npex count - Show count of tracked nameplates")
        print("  /npex config - Show current configuration")
        print("  /npex debug - Toggle debug mode")
        print("  /npex enemy - Toggle enemy NPC tracking")
        print("  /npex friendly - Toggle friendly NPC tracking")
        print("  /npex players - Toggle player tracking")
        print("  /npex help - Show this help message")
        
    else
        print(string.format("[%s] Unknown command: %s", addonName, command))
        print("Type /npex help for a list of commands")
    end
end

-- Public API for other addons to use
NameplateExample.GetTrackedNameplates = function()
    return trackedNameplates
end

NameplateExample.GetConfig = function()
    return config
end

-- Example function demonstrating Method 3 from the guide (using NamePlateDriverFrame)
NameplateExample.IterateAllNameplates = function(callback)
    if not NamePlateDriverFrame then
        DebugPrint("NamePlateDriverFrame not available")
        return
    end
    
    NamePlateDriverFrame:ForEachNamePlate(function(namePlateFrame)
        local unitToken = namePlateFrame:GetUnit()
        
        if unitToken and UnitExists(unitToken) then
            local isVisible = namePlateFrame:IsVisible()
            local unitInfo = GetUnitInfo(unitToken)
            
            if callback and unitInfo then
                callback(unitToken, namePlateFrame, unitInfo, isVisible)
            end
        end
    end)
end

-- Print startup message
print(string.format("[%s] Loaded successfully. Type /npex help for commands.", addonName))

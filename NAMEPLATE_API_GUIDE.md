# Nameplate API Guide

This guide explains how to get nameplate information from NPCs (enemies) in the current version of the WoW API.

## Overview

The nameplate system has evolved in recent versions. Key changes include:
- `IsVisible()` is now a standard frame method that works on nameplate frames
- `namePlateUnitToken` must be obtained through events, not by querying
- Unit tokens are provided via the `NAME_PLATE_UNIT_ADDED` event

## Getting Nameplate Information

### Method 1: Using Events (Recommended)

The recommended approach is to listen for nameplate events:

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

frame:SetScript("OnEvent", function(self, event, unitToken)
    if event == "NAME_PLATE_UNIT_ADDED" then
        -- A nameplate was added - unitToken is provided
        local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
        
        -- Check if it's an enemy NPC
        if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
            -- This is an enemy NPC
            local name = UnitName(unitToken)
            local health = UnitHealth(unitToken)
            local maxHealth = UnitHealthMax(unitToken)
            local level = UnitLevel(unitToken)
            
            print(string.format("Enemy NPC detected: %s (Level %d) - %d/%d HP", 
                name, level, health, maxHealth))
            
            -- Check if nameplate frame is visible
            if namePlateFrame and namePlateFrame:IsVisible() then
                print("Nameplate is visible on screen")
            end
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        -- A nameplate was removed
        print("Nameplate removed for:", unitToken)
    end
end)
```

### Method 2: Iterating All Active Nameplates

You can iterate through all currently active nameplates:

```lua
-- Get all active nameplate frames
local nameplates = C_NamePlate.GetNamePlates(issecure())

for _, namePlateFrame in pairs(nameplates) do
    -- Get the unit token from the nameplate frame using GetUnit()
    local unitToken = namePlateFrame:GetUnit()
    
    if unitToken then
        -- Check if it's visible
        if namePlateFrame:IsVisible() then
            -- Check if it's an enemy NPC
            if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
                local name = UnitName(unitToken)
                print("Visible enemy NPC:", name)
            end
        end
    end
end
```

### Method 3: Using NamePlateDriverFrame

For more advanced integration, you can use the `NamePlateDriverFrame`:

```lua
if NamePlateDriverFrame then
    NamePlateDriverFrame:ForEachNamePlate(function(namePlateFrame)
        local unitToken = namePlateFrame:GetUnit()
        
        if unitToken and UnitExists(unitToken) then
            -- Check visibility
            if namePlateFrame:IsVisible() then
                -- Check if enemy NPC
                if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
                    -- Process NPC nameplate
                    local name = UnitName(unitToken)
                    local classification = UnitClassification(unitToken)
                    
                    print(string.format("NPC: %s (%s)", name, classification))
                end
            end
        end
    end)
end
```

## Key Points

### Checking Visibility

Instead of a custom `IsVisible` method, use the standard frame method:
```lua
if namePlateFrame and namePlateFrame:IsVisible() then
    -- Nameplate is visible
end
```

### Getting Unit Tokens

Unit tokens are NOT directly queryable. You must:
1. Listen for the `NAME_PLATE_UNIT_ADDED` event to receive tokens
2. OR use `C_NamePlate.GetNamePlates()` and access the unit from each frame

### Filtering for Enemy NPCs

```lua
-- Check if unit is an enemy
local isEnemy = UnitIsEnemy("player", unitToken)

-- Check if unit is NOT a player (i.e., is an NPC)
local isNPC = not UnitIsPlayer(unitToken)

-- Combined check
if isEnemy and isNPC then
    -- This is an enemy NPC
end
```

### Getting Nameplate Frame from Unit Token

```lua
local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
```

## Additional Unit Information Functions

Once you have a valid `unitToken`, you can use these functions:

```lua
UnitName(unitToken)              -- Get unit name
UnitHealth(unitToken)            -- Current health
UnitHealthMax(unitToken)         -- Maximum health
UnitLevel(unitToken)             -- Unit level
UnitClassification(unitToken)    -- "normal", "elite", "rare", "rareelite", "worldboss"
UnitIsEnemy("player", unitToken) -- Is enemy to player
UnitIsFriend("player", unitToken)-- Is friendly to player
UnitIsPlayer(unitToken)          -- Is a player character
UnitIsDead(unitToken)            -- Is dead
UnitCanAttack("player", unitToken) -- Can player attack this unit
UnitAffectingCombat(unitToken)   -- Is in combat
UnitThreatSituation("player", unitToken) -- Threat level
```

## Complete Example: Enemy NPC Tracker

```lua
-- Create a frame to track enemy NPCs
local NPCTracker = CreateFrame("Frame")
local trackedNPCs = {}

NPCTracker:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NPCTracker:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

NPCTracker:SetScript("OnEvent", function(self, event, unitToken)
    if event == "NAME_PLATE_UNIT_ADDED" then
        -- Check if it's an enemy NPC
        if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
            local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
            
            if namePlateFrame then
                -- Store NPC information
                trackedNPCs[unitToken] = {
                    name = UnitName(unitToken),
                    level = UnitLevel(unitToken),
                    classification = UnitClassification(unitToken),
                    frame = namePlateFrame,
                    addedTime = GetTime()
                }
                
                print(string.format("Tracking enemy NPC: %s (Level %d %s)", 
                    trackedNPCs[unitToken].name,
                    trackedNPCs[unitToken].level,
                    trackedNPCs[unitToken].classification))
            end
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        if trackedNPCs[unitToken] then
            print(string.format("Lost track of: %s", trackedNPCs[unitToken].name))
            trackedNPCs[unitToken] = nil
        end
    end
end)

-- Function to list all currently tracked NPCs
function ListTrackedNPCs()
    print("Currently tracked NPCs:")
    for unitToken, npcData in pairs(trackedNPCs) do
        local isVisible = npcData.frame and npcData.frame:IsVisible()
        print(string.format("  %s (Level %d) - Visible: %s", 
            npcData.name, 
            npcData.level, 
            tostring(isVisible)))
    end
end

-- Update function to check visibility and combat status
function UpdateTrackedNPCs()
    for unitToken, npcData in pairs(trackedNPCs) do
        if UnitExists(unitToken) then
            local isVisible = npcData.frame and npcData.frame:IsVisible()
            local inCombat = UnitAffectingCombat(unitToken)
            local health = UnitHealth(unitToken)
            local maxHealth = UnitHealthMax(unitToken)
            local healthPercent = (maxHealth > 0) and (health / maxHealth * 100) or 0
            
            -- Update stored data
            npcData.isVisible = isVisible
            npcData.inCombat = inCombat
            npcData.healthPercent = healthPercent
        end
    end
end
```

## Troubleshooting

### "namePlateUnitToken is nil"

This happens when you try to access `namePlateUnitToken` directly. Instead:
- Use the `NAME_PLATE_UNIT_ADDED` event to get the token
- OR use `namePlateFrame:GetUnit()` if you already have the frame

### "IsVisible doesn't exist"

`IsVisible()` is a standard frame method. If you're getting this error:
- Ensure you have a valid frame reference
- Check that `namePlateFrame` is not nil before calling `:IsVisible()`

```lua
if namePlateFrame and namePlateFrame:IsVisible() then
    -- Safe to use
end
```

## Events Reference

### NAME_PLATE_UNIT_ADDED
Fired when a nameplate becomes active for a unit.
- **Payload**: `unitToken` (string)

### NAME_PLATE_UNIT_REMOVED
Fired when a nameplate is no longer active for a unit.
- **Payload**: `unitToken` (string)

### NAME_PLATE_CREATED
Fired when a nameplate frame is created (usually for frame pooling).
- **Payload**: `namePlateFrame` (frame reference)

### NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED
Fired when a nameplate unit moves behind or in front of the camera.
- **Payload**: `unitToken` (string), `isBehindCamera` (boolean)

## API Reference

### C_NamePlate Functions

```lua
C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
-- Returns: namePlateFrame or nil

C_NamePlate.GetNamePlates(issecure())
-- Returns: table of all active nameplate frames

C_NamePlate.SetNamePlateSize(width, height)
-- Sets the size of nameplates

C_NamePlateManager.IsNamePlateUnitBehindCamera(unitToken)
-- Returns: boolean

C_NamePlateManager.SetNamePlateSimplified(unitToken, isSimplified)
-- Sets whether nameplate should be simplified
```

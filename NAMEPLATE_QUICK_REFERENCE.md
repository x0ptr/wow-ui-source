# Nameplate Quick Reference Card

Quick reference for getting nameplate information from NPCs in WoW.

## The Problem

- ❌ `IsVisible` (as a custom property) doesn't exist
- ❌ `namePlateUnitToken` returns nil when accessed directly
- ✅ Use events and standard frame methods instead

## The Solution

### 1. Get Unit Tokens from Events

```lua
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(self, event, unitToken)
    -- unitToken is provided by the event
end)
```

### 2. Check Visibility with Standard Method

```lua
if namePlateFrame and namePlateFrame:IsVisible() then
    -- Nameplate is visible
end
```

### 3. Filter for Enemy NPCs

```lua
if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
    -- This is an enemy NPC
end
```

## Essential Events

| Event | When Fired | Payload |
|-------|-----------|---------|
| `NAME_PLATE_UNIT_ADDED` | Nameplate becomes active | `unitToken` |
| `NAME_PLATE_UNIT_REMOVED` | Nameplate removed | `unitToken` |
| `NAME_PLATE_CREATED` | Frame created | `namePlateFrame` |

## Essential Functions

| Function | Purpose | Returns |
|----------|---------|---------|
| `C_NamePlate.GetNamePlateForUnit(token, issecure())` | Get frame for unit | `frame` or `nil` |
| `C_NamePlate.GetNamePlates(issecure())` | Get all active nameplates | `table` of frames |
| `namePlateFrame:GetUnit()` | Get unit from frame | `unitToken` |
| `namePlateFrame:IsVisible()` | Check visibility | `boolean` |

## Unit Information Functions

Once you have a `unitToken`, use these:

```lua
UnitName(unitToken)              -- Unit name
UnitHealth(unitToken)            -- Current HP
UnitHealthMax(unitToken)         -- Max HP
UnitLevel(unitToken)             -- Level
UnitClassification(unitToken)    -- "normal", "elite", "rare", etc.
UnitIsEnemy("player", unitToken) -- Is enemy?
UnitIsPlayer(unitToken)          -- Is player? (false = NPC)
UnitIsDead(unitToken)            -- Is dead?
UnitAffectingCombat(unitToken)   -- In combat?
```

## Three Tracking Methods

### Method 1: Event-Based (Recommended) ⭐

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(self, event, unitToken)
    local npFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
    -- Process nameplate
end)
```

**Best for**: Real-time tracking, efficiency

### Method 2: Iteration

```lua
local nameplates = C_NamePlate.GetNamePlates(issecure())
for _, npFrame in pairs(nameplates) do
    local unitToken = npFrame:GetUnit()
    -- Process nameplate
end
```

**Best for**: One-time scans, bulk operations

### Method 3: NamePlateDriverFrame

```lua
NamePlateDriverFrame:ForEachNamePlate(function(npFrame)
    local unitToken = npFrame:GetUnit()
    -- Process nameplate
end)
```

**Best for**: Deep Blizzard integration

## Common Patterns

### Track Enemy NPCs

```lua
local tracked = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

frame:SetScript("OnEvent", function(self, event, unitToken)
    if event == "NAME_PLATE_UNIT_ADDED" then
        if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
            tracked[unitToken] = {
                name = UnitName(unitToken),
                frame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
            }
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        tracked[unitToken] = nil
    end
end)
```

### Check Visibility

```lua
for unitToken, data in pairs(tracked) do
    if data.frame and data.frame:IsVisible() then
        print(data.name .. " is visible")
    end
end
```

### Get Health Percentage

```lua
local health = UnitHealth(unitToken)
local maxHealth = UnitHealthMax(unitToken)
local percent = (maxHealth > 0) and (health / maxHealth * 100) or 0
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "namePlateUnitToken is nil" | Use events or `frame:GetUnit()` |
| "IsVisible doesn't exist" | Use `frame:IsVisible()` (method, not property) |
| Can't find enemy NPCs | Check `UnitIsEnemy()` and `not UnitIsPlayer()` |
| Frame is nil | Ensure unit token is valid with `UnitExists()` |

## Example Output

When tracking NPCs, you'll see:

```
[NameplateExample] Tracked Enemy NPC: Murloc Raider (Level 5 normal) - HP: 100.0% - Visible: true
[NameplateExample] Lost track of: Murloc Raider (tracked for 12.3 seconds)
```

## Testing Commands

If using the example addon:

```
/npex list      -- List tracked nameplates
/npex count     -- Show count
/npex debug     -- Toggle debug mode
/npex enemy     -- Toggle enemy NPC tracking
```

## Full Documentation

- 📖 [Complete API Guide](NAMEPLATE_API_GUIDE.md)
- 💻 [Example Addon](Examples/NameplateExample/)
- 📝 [Full Solution Docs](NAMEPLATE_SOLUTION.md)

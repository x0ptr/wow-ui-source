# Getting Started with Nameplate Tracking

This guide will help you quickly start using the nameplate solution.

## The Problem You're Solving

You need to get nameplate information from NPCs (enemies), but:
- `IsVisible` doesn't work (you thought it was a custom property)
- `namePlateUnitToken` is nil when you try to access it
- You need a reliable way to track nameplates

## The Quick Answer

### 1. Get Unit Tokens from Events

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(self, event, unitToken)
    -- unitToken is provided here!
    print("Nameplate added for:", UnitName(unitToken))
end)
```

### 2. Check Visibility the Right Way

```lua
local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
if namePlateFrame and namePlateFrame:IsVisible() then
    print("This nameplate is visible!")
end
```

### 3. Filter for Enemy NPCs

```lua
if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
    print("This is an enemy NPC:", UnitName(unitToken))
end
```

## Try It Right Now

### Option 1: Copy & Paste Test Code

Paste this into your chat window in-game:

```lua
/run local f=CreateFrame("Frame") f:RegisterEvent("NAME_PLATE_UNIT_ADDED") f:SetScript("OnEvent",function(_,_,t) if UnitIsEnemy("player",t) and not UnitIsPlayer(t) then print("Enemy NPC:",UnitName(t)) end end)
```

Walk near some enemy NPCs and watch the chat!

### Option 2: Install the Example Addon

1. Copy `Examples/NameplateExample/` to your WoW AddOns folder
2. Restart WoW or reload UI (`/reload`)
3. Type `/npex help` in-game
4. Walk near NPCs to see them tracked
5. Type `/npex list` to see all tracked nameplates

## Next Steps

### For Quick Reference
→ [NAMEPLATE_QUICK_REFERENCE.md](NAMEPLATE_QUICK_REFERENCE.md)

### For Learning
→ [NAMEPLATE_API_GUIDE.md](NAMEPLATE_API_GUIDE.md)

### For Complete Documentation
→ [NAMEPLATE_SOLUTION.md](NAMEPLATE_SOLUTION.md)

## Common Use Cases

### Track All Enemy NPCs

```lua
local enemyNPCs = {}

local tracker = CreateFrame("Frame")
tracker:RegisterEvent("NAME_PLATE_UNIT_ADDED")
tracker:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

tracker:SetScript("OnEvent", function(self, event, unitToken)
    if event == "NAME_PLATE_UNIT_ADDED" then
        if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
            enemyNPCs[unitToken] = {
                name = UnitName(unitToken),
                health = UnitHealth(unitToken),
                maxHealth = UnitHealthMax(unitToken),
                level = UnitLevel(unitToken)
            }
            print(string.format("Tracking: %s (Level %d)", 
                enemyNPCs[unitToken].name, 
                enemyNPCs[unitToken].level))
        end
    else
        enemyNPCs[unitToken] = nil
    end
end)
```

### Check Nameplate Visibility

```lua
for unitToken, npcData in pairs(enemyNPCs) do
    local frame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
    if frame and frame:IsVisible() then
        print(npcData.name .. " nameplate is visible")
    end
end
```

### Get Health Percentage

```lua
local health = UnitHealth(unitToken)
local maxHealth = UnitHealthMax(unitToken)
local percent = (maxHealth > 0) and (health / maxHealth * 100) or 0
print(string.format("%s: %.1f%% HP", UnitName(unitToken), percent))
```

## Troubleshooting

**Q: I get "namePlateUnitToken is nil"**  
A: Don't access it directly. Get it from the NAME_PLATE_UNIT_ADDED event or use `frame:GetUnit()`

**Q: IsVisible() doesn't work**  
A: Make sure you're calling it as a method: `frame:IsVisible()` not `frame.IsVisible`

**Q: I can't find enemy NPCs**  
A: Check both conditions: `UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken)`

**Q: The nameplate frame is nil**  
A: Check that the unit exists first with `UnitExists(unitToken)`

## Summary

You now know:
- ✅ How to get unit tokens (from events or GetUnit())
- ✅ How to check visibility (IsVisible() method)
- ✅ How to filter for enemy NPCs
- ✅ Where to find complete documentation

Happy addon development! 🎮

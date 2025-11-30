# Getting Nameplate Information from NPCs

This directory contains comprehensive resources for working with nameplates in modern World of Warcraft.

## Problem Statement

In recent versions of WoW, the nameplate API has changed:
- `IsVisible` (as a custom method) doesn't exist - you must use the standard frame method
- `namePlateUnitToken` cannot be accessed directly - you must get it from events
- The proper way to work with nameplates is through events, not polling

## Solutions Provided

This repository includes:

1. **[NAMEPLATE_API_GUIDE.md](NAMEPLATE_API_GUIDE.md)** - A comprehensive guide covering:
   - All three methods for getting nameplate information
   - Proper use of `IsVisible()` as a standard frame method
   - How to correctly obtain `namePlateUnitToken` via events
   - Complete API reference and event documentation
   - Troubleshooting common issues

2. **[Examples/NameplateExample/](Examples/NameplateExample/)** - A complete, working addon that demonstrates:
   - Event-based nameplate tracking
   - Filtering for enemy NPCs
   - Real-time updates and visibility checking
   - Interactive commands for testing
   - All three methods shown in the guide

## Quick Start

### For Users
1. Read the [Nameplate API Guide](NAMEPLATE_API_GUIDE.md)
2. Install the [example addon](Examples/NameplateExample/) to see it in action
3. Use `/npex help` in-game to explore features

### For Developers
1. Review the [Nameplate API Guide](NAMEPLATE_API_GUIDE.md) for API documentation
2. Study the [example code](Examples/NameplateExample/NameplateExample.lua) to see practical implementations
3. Use the example as a template for your own addon

## Key Concepts

### IsVisible - The Right Way
```lua
-- CORRECT: Use the standard frame method
if namePlateFrame and namePlateFrame:IsVisible() then
    -- Nameplate is visible
end

-- WRONG: There is no custom IsVisible property
-- if namePlateFrame.IsVisible then ... end
```

### Getting Unit Tokens - The Right Way
```lua
-- CORRECT: Get from events
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(self, event, unitToken)
    -- unitToken is provided by the event
    local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
end)

-- WRONG: Don't try to access directly
-- local token = namePlateFrame.namePlateUnitToken  -- This will be nil
```

### Filtering for Enemy NPCs
```lua
-- Check if unit is an enemy NPC
if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
    -- This is an enemy NPC
    local name = UnitName(unitToken)
    local health = UnitHealth(unitToken)
    -- ... process NPC data
end
```

## Three Methods for Working with Nameplates

### Method 1: Event-Based (Recommended)
Use `NAME_PLATE_UNIT_ADDED` and `NAME_PLATE_UNIT_REMOVED` events to track nameplates as they appear and disappear. This is the most efficient method.

**Best for**: Real-time tracking, monitoring specific units

### Method 2: Iteration
Use `C_NamePlate.GetNamePlates()` to get all active nameplates and iterate through them.

**Best for**: One-time scans, bulk operations

### Method 3: NamePlateDriverFrame
Use `NamePlateDriverFrame:ForEachNamePlate()` for advanced integration with the Blizzard nameplate system.

**Best for**: Deep integration with existing nameplate functionality

## API Reference Quick Links

### Events
- `NAME_PLATE_UNIT_ADDED` - Fired when a nameplate becomes active
- `NAME_PLATE_UNIT_REMOVED` - Fired when a nameplate is removed
- `NAME_PLATE_CREATED` - Fired when a nameplate frame is created

### Functions
- `C_NamePlate.GetNamePlateForUnit(unitToken, issecure())` - Get nameplate frame for a unit
- `C_NamePlate.GetNamePlates(issecure())` - Get all active nameplates
- `C_NamePlateManager.IsNamePlateUnitBehindCamera(unitToken)` - Check if behind camera

### Unit Functions (once you have a unitToken)
- `UnitName(unitToken)` - Get unit name
- `UnitHealth(unitToken)` - Get current health
- `UnitIsEnemy("player", unitToken)` - Check if enemy
- `UnitIsPlayer(unitToken)` - Check if player (vs NPC)
- See the full guide for complete list

## Files Structure

```
.
├── NAMEPLATE_API_GUIDE.md          # Comprehensive API documentation
├── NAMEPLATE_SOLUTION.md           # This file
└── Examples/
    └── NameplateExample/           # Working example addon
        ├── NameplateExample.toc    # Addon metadata
        ├── NameplateExample.lua    # Main addon code
        └── README.md               # Addon documentation
```

## Testing the Solution

1. Copy the `Examples/NameplateExample` folder to your WoW AddOns directory
2. Launch the game and log in to a character
3. Walk near some NPCs (enemies work best)
4. Type `/npex list` to see tracked nameplates
5. Type `/npex debug` to enable verbose output
6. Observe the debug messages showing nameplate tracking in action

## Common Issues and Solutions

### "namePlateUnitToken is nil"
**Cause**: Trying to access the token directly from the frame  
**Solution**: Get it from the `NAME_PLATE_UNIT_ADDED` event instead

### "IsVisible doesn't exist"
**Cause**: Looking for a custom property that doesn't exist  
**Solution**: Use `frame:IsVisible()` - it's a standard frame method

### "Can't get nameplate for enemy NPCs"
**Cause**: Not listening to the right events  
**Solution**: Register for `NAME_PLATE_UNIT_ADDED` and check `UnitIsEnemy()`

## Additional Resources

- [Blizzard NamePlate Source](Interface/AddOns/Blizzard_NamePlates/) - Official implementation
- [API Documentation](Interface/AddOns/Blizzard_APIDocumentationGenerated/NamePlateManagerDocumentation.lua) - Event definitions

## Support

This solution is based on WoW version 12.0.0 (The War Within). The nameplate system has been stable since Legion (7.0) with only minor changes, so these techniques should work on most modern versions.

For questions or issues:
1. Review the [API Guide](NAMEPLATE_API_GUIDE.md)
2. Study the [example code](Examples/NameplateExample/NameplateExample.lua)
3. Check the troubleshooting section in the guide

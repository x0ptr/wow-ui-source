# Nameplate Example Addon

This is a complete, working example addon that demonstrates how to get nameplate information from NPCs (enemies) in World of Warcraft.

## Features

This addon demonstrates all the modern ways to work with nameplates:

1. **Event-based tracking** using `NAME_PLATE_UNIT_ADDED` and `NAME_PLATE_UNIT_REMOVED`
2. **Proper visibility checking** using the standard `IsVisible()` frame method
3. **Correct unit token handling** without relying on direct queries
4. **Comprehensive unit information** gathering (health, level, classification, combat status)
5. **Real-time updates** with a ticker that monitors changes
6. **Configurable filtering** for different unit types (enemy NPCs, friendly NPCs, players)

## Installation

Copy the `NameplateExample` folder to your WoW AddOns directory:
```
World of Warcraft\_retail_\Interface\AddOns\NameplateExample\
```

## Usage

### In-Game Commands

Use the `/npex` or `/nameplateexample` command with the following options:

- `/npex list` - List all currently tracked nameplates with their status
- `/npex count` - Show the count of tracked nameplates
- `/npex config` - Display current configuration settings
- `/npex debug` - Toggle debug mode on/off
- `/npex enemy` - Toggle tracking of enemy NPCs
- `/npex friendly` - Toggle tracking of friendly NPCs
- `/npex players` - Toggle tracking of player characters
- `/npex help` - Display help message

### Example Usage

1. Load the addon and enter the game world
2. Walk near some NPCs to see them being tracked
3. Type `/npex list` to see all currently tracked nameplates
4. Type `/npex debug` to toggle verbose debug output

## Code Structure

### Main Components

1. **Event Registration**
   - Listens for `NAME_PLATE_UNIT_ADDED` events to catch new nameplates
   - Listens for `NAME_PLATE_UNIT_REMOVED` events when nameplates are removed
   - Handles `PLAYER_ENTERING_WORLD` to initialize on login/reload

2. **Nameplate Tracking**
   - Stores nameplate data in the `trackedNameplates` table
   - Each entry contains the unit token, frame reference, unit info, and timestamps

3. **Unit Information Gathering**
   - Uses standard WoW API functions like `UnitName()`, `UnitHealth()`, etc.
   - Gathers comprehensive information about each unit

4. **Update System**
   - Uses `C_Timer.NewTicker()` to periodically update tracked nameplates
   - Checks visibility and combat status in real-time

5. **Visibility Checking**
   - Uses `namePlateFrame:IsVisible()` - the standard frame method
   - This replaces any custom `IsVisible` that may have existed in older versions

## Key Solutions to Common Problems

### Problem: "IsVisible does not exist"
**Solution**: Use the standard frame method `namePlateFrame:IsVisible()`

### Problem: "namePlateUnitToken is nil"
**Solution**: Don't try to access it directly. Instead:
- Get it from the `NAME_PLATE_UNIT_ADDED` event
- OR use `C_NamePlate.GetNamePlates()` and access unit from each frame
- OR use `namePlateFrame:GetUnit()` if you have the frame

### Problem: "Can't get the nameplate frame"
**Solution**: Use `C_NamePlate.GetNamePlateForUnit(unitToken, issecure())`

## API Examples

### Getting a Nameplate Frame
```lua
local namePlateFrame = C_NamePlate.GetNamePlateForUnit(unitToken, issecure())
```

### Checking Visibility
```lua
if namePlateFrame and namePlateFrame:IsVisible() then
    -- Nameplate is visible
end
```

### Filtering for Enemy NPCs
```lua
if UnitIsEnemy("player", unitToken) and not UnitIsPlayer(unitToken) then
    -- This is an enemy NPC
end
```

### Getting All Active Nameplates
```lua
local nameplates = C_NamePlate.GetNamePlates(issecure())
for _, namePlateFrame in pairs(nameplates) do
    -- Process each nameplate
end
```

## Public API

The addon exposes a few functions that other addons can use:

```lua
-- Get all tracked nameplates
local tracked = NameplateExample.GetTrackedNameplates()

-- Get current configuration
local config = NameplateExample.GetConfig()

-- Iterate all nameplates with a callback
NameplateExample.IterateAllNameplates(function(unitToken, frame, info, isVisible)
    -- Process each nameplate
end)
```

## Learning Resources

This example addon demonstrates three different methods for working with nameplates:

1. **Method 1 (Recommended)**: Event-based tracking using `NAME_PLATE_UNIT_ADDED`
2. **Method 2**: Iterating with `C_NamePlate.GetNamePlates()`
3. **Method 3**: Using `NamePlateDriverFrame:ForEachNamePlate()`

All three methods are shown in the code with comments explaining when to use each one.

## Version Compatibility

- **Interface Version**: 120000 (The War Within - 12.0.0)
- **Tested On**: Retail WoW 12.0.0

The addon uses only standard Blizzard API functions and should work on any version with the modern nameplate system.

## License

This example addon is provided as-is for educational purposes. Feel free to use, modify, and distribute it.

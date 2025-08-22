Heaven Troll Menu 🙏
A cinematic FiveM server resource for QB-Core framework that provides an epic divine trolling experience. Send players on a heavenly journey with Jesus where their fate is decided by a 50/50 chance of survival or divine punishment!

Features ✨
🎬 Cinematic Heaven Sequence
Prayer Animation: Starts with divine presence and prayer emote
Book Reading: Player receives and reads a holy book during ascension
First Person View: Forced immersive camera throughout the sequence
Slow Ascension: 8-second gradual rise to heaven with atmospheric music
Jesus Encounter: Meet Jesus ped with blessing animations
Fate Decision: 50/50 survival chance with dramatic outcomes
😇 Survival Outcome
Blessed with parachute for safe landing
Celebration animation with success notification
"Jesus blesses you with a parachute! You survived! 😇"
💀 Death Outcome (Enhanced Humiliation)
Disappointment: Jesus shows disapproval
💩 Humiliation: Player soils themselves in fear
🔥 Divine Punishment: Bursts into flames
⚰️ Death: Final demise while burning
🎵 Audio & Effects
Layered heavenly music during sequence
Multiple ambient sound effects
Visual effects and atmospheric enhancement
Configurable audio settings
🎭 Animation System
rpemotes-reborn integration for enhanced animations
Smart fallback system for basic GTA animations
Prayer, book reading, celebration, and humiliation emotes
Jesus blessing and greeting animations
Installation 🚀
Download & Extract: Place the heaven-troll folder in your FiveM server's resources directory

Add to server.cfg:

ensure heaven-troll
Dependencies: Ensure you have these resources installed:

qb-core (Required)
rpemotes-reborn (Optional - for enhanced animations)
Restart Server: Restart your FiveM server to load the resource

Permissions 🔑
Method 1: ACE Permissions (Recommended)
Add to your server.cfg:

add_ace qbcore.god command allow
add_ace heaven-troll.use command allow
Method 2: Individual Player Permissions
add_ace identifier.steam:YOUR_STEAM_ID qbcore.god allow
Method 3: QB-Core Groups
Players with these QB-Core groups can use the troll:

god
admin
moderator
⚠️ Important: Restart your server after adding permissions!

Usage 🎮
Console Commands (txAdmin)
heaventroll [playerid]
heaven [playerid]
In-Game Commands
/heaventroll [playerid]
/heaven [playerid]
Custom Menu Integration
For integrating with custom admin menus:

Trigger the Effect:

TriggerServerEvent('heaven-troll:sendToHeaven', targetPlayerId)
Get Online Players:

QBCore.Functions.TriggerCallback('heaven-troll:getOnlinePlayers', function(players)
    -- players table contains: id, name, citizenid
    for _, player in pairs(players) do
        print(player.id, player.name, player.citizenid)
    end
end)
Configuration ⚙️
Edit config.lua to customize the resource:

Config = {
    -- Permission settings
    AcePermissions = {
        enabled = true,
        commands = {"qbcore.god", "heaven-troll.use"}
    },
    
    -- QB-Core admin ranks
    AdminRanks = {"god", "admin", "moderator"},
    
    -- Troll settings
    TrollSettings = {
        survivalChance = 50, -- 50% survival rate
        ascensionHeight = 800, -- Height to ascend in units
        ascensionTime = 8000, -- Time to ascend in milliseconds
        jesusSpawnDistance = 3.0 -- Distance Jesus spawns from player
    },
    
    -- Audio settings
    Audio = {
        enabled = true,
        sounds = {
            "MEDAL_BRONZE",
            "CHECKPOINT_NORMAL", 
            "RACE_PLACED"
        }
    }
}
File Structure 📁
heaven-troll/
├── fxmanifest.lua      # Resource manifest
├── config.lua         # Configuration settings
├── server.lua         # Server-side logic
├── client.lua         # Client-side effects
└── README.md          # This documentation
Technical Details 🔧
Framework: QB-Core
Language: Lua 5.4
Lines of Code: 706
Dependencies: qb-core, rpemotes-reborn (optional)
Compatibility: FiveM servers with QB-Core framework
Features Breakdown 📋
Security Features
ACE permission integration
QB-Core group permission fallback
Admin-only access controls
Safe command registration
Animation Features
rpemotes-reborn integration with fallbacks
Realistic book prop attachment
Jesus ped with blessing animations
Player reaction animations based on fate
Technical Features
First person camera enforcement
Smooth entity movement and positioning
Proper cleanup and resource management
Error handling and validation
Troubleshooting 🔧
Common Issues
"No permission" error:

Check your ACE permissions in server.cfg
Verify your QB-Core group assignment
Restart the server after permission changes
Animations not working:

Ensure rpemotes-reborn is installed and working
Resource falls back to basic GTA animations if rpemotes unavailable
Jesus ped not appearing:

Check console for any script errors
Verify the resource loaded properly on server start
Console Output
The resource provides detailed startup information:

[Heaven Troll] Server script loaded successfully!
[Heaven Troll] ACE Permission system enabled!
[Heaven Troll] TO GET PERMISSION IN-GAME:
[Heaven Troll] 1. Add to server.cfg: add_ace qbcore.god command allow
[Heaven Troll] 2. Restart your server after adding permissions
Credits 👨‍💻
Framework: QB-Core Development Team
Animations: rpemotes-reborn contributors
Development: Custom FiveM resource for admin trolling
License 📄
This resource is provided as-is for FiveM server use. Modify and distribute as needed for your server community.

Enjoy trolling your players with divine intervention! 😈🙏

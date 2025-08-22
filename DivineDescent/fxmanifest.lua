fx_version 'cerulean'
game 'gta5'

author 'Heaven Troll Script'
description 'QB-Core admin trolling script with Snipe menu integration'
version '1.0.0'

-- ACE Permission Setup (add to server.cfg):
-- add_ace qbcore.god command allow
-- add_ace heaven-troll.use command allow
-- Or for specific players:
-- add_ace identifier.steam:YOUR_STEAM_ID qbcore.god allow

shared_scripts {
    'config.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'qb-core',
    'rpemotes-reborn'  -- For enhanced animations
}

lua54 'yes'

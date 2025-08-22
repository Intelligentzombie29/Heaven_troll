Config = {}

-- Heaven coordinates (high in the sky)
Config.HeavenCoords = {
    x = 0.0,
    y = 0.0,
    z = 1000.0  -- High altitude
}

-- Audio settings
Config.Audio = {
    enabled = true,
    soundFile = "heaven_music", -- Sound file name (should be in audio folder of resource)
    volume = 0.5,
    duration = 10000 -- 10 seconds in milliseconds
}

-- Troll settings
Config.TrollSettings = {
    fallDamage = true,
    survivalChance = 50, -- 50% chance of survival
    fallHeight = 950.0, -- Height to fall from
    safeHeight = 2.0, -- Safe landing height
    effectDuration = 5000, -- 5 seconds before outcome
    deathMessage = "has been sent to swim with the fishes! 🐟",
    survivalMessage = "survived their trip to heaven! 😇"
}

-- Admin permissions
Config.AdminRanks = {
    "god",
    "admin",
    "moderator"
}

-- ACE Permission settings
Config.AcePermissions = {
    enabled = true,
    godPermission = "qbcore.god",      -- add_ace qbcore.god command allow
    trollPermission = "heaven-troll.use" -- add_ace heaven-troll.use command allow
}

-- Snipe menu integration
Config.SnipeMenu = {
    enabled = true,
    buttonLabel = "Heaven Troll",
    description = "Send player to heaven with random outcome"
}

-- Logging
Config.Logging = {
    enabled = true,
    webhook = nil -- Discord webhook URL if desired
}

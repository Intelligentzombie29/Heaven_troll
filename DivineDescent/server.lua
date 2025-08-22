local QBCore = exports['qb-core']:GetCoreObject()

-- Check if player has admin permissions (QB-Core groups + ACE permissions)
local function HasAdminPermission(source)
    -- Console always has permission (txAdmin/server console)
    if source == 0 then
        if Config.Logging.enabled then
            print("^2[Heaven Troll]^7 Admin access granted to SERVER CONSOLE")
        end
        return true
    end
    
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        if Config.Logging.enabled then
            print(string.format("^1[Heaven Troll]^7 No player found for source: %s", source))
        end
        return false 
    end
    
    local playerName = Player.PlayerData.name or "Unknown Player"
    
    -- Check ACE permissions first if enabled
    if Config.AcePermissions.enabled then
        -- Debug ACE permission checking
        if Config.Logging.enabled then
            print(string.format("^3[Heaven Troll]^7 Checking ACE permissions for %s (source: %s)", playerName, source))
        end
        
        -- Check god permission (add_ace qbcore.god command allow)
        if IsPlayerAceAllowed(source, Config.AcePermissions.godPermission) then
            if Config.Logging.enabled then
                print(string.format("^2[Heaven Troll]^7 Admin access granted to %s via ACE permission: %s", 
                    playerName, Config.AcePermissions.godPermission))
            end
            return true
        end
        
        -- Check specific troll permission (add_ace heaven-troll.use command allow)
        if IsPlayerAceAllowed(source, Config.AcePermissions.trollPermission) then
            if Config.Logging.enabled then
                print(string.format("^2[Heaven Troll]^7 Admin access granted to %s via ACE permission: %s", 
                    playerName, Config.AcePermissions.trollPermission))
            end
            return true
        end
        
        if Config.Logging.enabled then
            print(string.format("^3[Heaven Troll]^7 No ACE permissions found for %s", playerName))
        end
    end
    
    -- Check QB-Core group permissions (fallback/compatibility)
    local playerGroup = QBCore.Functions.GetPermission(source)
    if Config.Logging.enabled then
        print(string.format("^3[Heaven Troll]^7 QB-Core group for %s: %s", playerName, tostring(playerGroup)))
    end
    
    for _, rank in pairs(Config.AdminRanks) do
        if playerGroup == rank then
            if Config.Logging.enabled then
                print(string.format("^2[Heaven Troll]^7 Admin access granted to %s via QB-Core group: %s", 
                    playerName, playerGroup))
            end
            return true
        end
    end
    
    if Config.Logging.enabled then
        print(string.format("^1[Heaven Troll]^7 ACCESS DENIED for %s - No valid permissions found", playerName))
    end
    return false
end

-- Log admin actions
local function LogAction(adminSource, targetSource, action, outcome)
    if not Config.Logging.enabled then return end
    
    local adminPlayer = QBCore.Functions.GetPlayer(adminSource)
    local targetPlayer = QBCore.Functions.GetPlayer(targetSource)
    
    if adminPlayer and targetPlayer then
        local logMessage = string.format(
            "[HEAVEN TROLL] Admin: %s (%s) | Target: %s (%s) | Action: %s | Outcome: %s",
            adminPlayer.PlayerData.name,
            adminPlayer.PlayerData.citizenid,
            targetPlayer.PlayerData.name,
            targetPlayer.PlayerData.citizenid,
            action,
            outcome
        )
        
        print(logMessage)
        
        -- Discord webhook logging if configured
        if Config.Logging.webhook then
            -- Implementation for Discord webhook would go here
        end
    end
end

-- Send player to heaven with random outcome
local function SendToHeaven(adminSource, targetSource)
    local targetPlayer = QBCore.Functions.GetPlayer(targetSource)
    if not targetPlayer then
        if adminSource == 0 then
            print("^1[Heaven Troll]^7 Player not found!")
        else
            TriggerClientEvent('QBCore:Notify', adminSource, 'Player not found!', 'error')
        end
        return
    end
    
    -- Generate random outcome (50/50 chance)
    local outcome = math.random(1, 100) <= Config.TrollSettings.survivalChance
    local outcomeText = outcome and "survival" or "death"
    
    -- Log the action
    LogAction(adminSource, targetSource, "Heaven Troll", outcomeText)
    
    -- Trigger client-side effect
    TriggerClientEvent('heaven-troll:startEffect', targetSource, outcome)
    
    -- Notify admin
    local targetName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
    local successMsg = string.format('Sent %s to heaven! Outcome: %s', targetName, outcomeText)
    
    if adminSource == 0 then
        print("^2[Heaven Troll]^7 " .. successMsg)
    else
        TriggerClientEvent('QBCore:Notify', adminSource, successMsg, 'success')
    end
    
    -- Notify all players about the outcome after effect duration
    SetTimeout(Config.TrollSettings.effectDuration + 2000, function()
        local message = outcome and Config.TrollSettings.survivalMessage or Config.TrollSettings.deathMessage
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 255, 0},
            multiline = true,
            args = {"[HEAVEN]", targetName .. " " .. message}
        })
    end)
end

-- Command registration using native RegisterCommand (more reliable)
RegisterCommand('heaventroll', function(source, args, rawCommand)
    -- Handle both console (source == 0) and player commands
    if not HasAdminPermission(source) then
        if source == 0 then
            print("^1[Heaven Troll]^7 Console access denied - this shouldn't happen!")
        else
            TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command!', 'error')
        end
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        local usageMsg = 'Usage: /heaventroll [playerid]'
        if source == 0 then
            print("^3[Heaven Troll]^7 " .. usageMsg)
        else
            TriggerClientEvent('QBCore:Notify', source, usageMsg, 'error')
        end
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        local errorMsg = 'Player not found!'
        if source == 0 then
            print("^1[Heaven Troll]^7 " .. errorMsg)
        else
            TriggerClientEvent('QBCore:Notify', source, errorMsg, 'error')
        end
        return
    end
    
    SendToHeaven(source, targetId)
end, true) -- true = restricted command

-- Alternative QB-Core command registration (fallback)
CreateThread(function()
    Wait(2000) -- Wait for QB-Core to fully load
    
    -- Try QB-Core command registration as backup
    if QBCore and QBCore.Commands and QBCore.Commands.Add then
        local success, err = pcall(function()
            QBCore.Commands.Add('heaven', 'Send a player to heaven with random outcome (Admin Only)', {
                {name = 'playerid', help = 'Player Server ID'}
            }, true, function(source, args)
                if not source or source == 0 then return end
                
                if not HasAdminPermission(source) then
                    TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command!', 'error')
                    return
                end
                
                local targetId = tonumber(args[1])
                if not targetId then
                    TriggerClientEvent('QBCore:Notify', source, 'Usage: /heaven [playerid]', 'error')
                    return
                end
                
                local targetPlayer = QBCore.Functions.GetPlayer(targetId)
                if not targetPlayer then
                    TriggerClientEvent('QBCore:Notify', source, 'Player not found!', 'error')
                    return
                end
                
                SendToHeaven(source, targetId)
            end)
        end)
        
        if success then
            print("^2[Heaven Troll]^7 QB-Core command 'heaven' registered successfully!")
        else
            print("^3[Heaven Troll]^7 QB-Core command registration failed, using native command only")
        end
    end
end)

-- Export for custom menu integration
RegisterServerEvent('heaven-troll:sendToHeaven')
AddEventHandler('heaven-troll:sendToHeaven', function(targetId)
    local source = source
    
    if not HasAdminPermission(source) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this feature!', 'error')
        return
    end
    
    if targetId and tonumber(targetId) then
        SendToHeaven(source, tonumber(targetId))
    else
        TriggerClientEvent('QBCore:Notify', source, 'Invalid target player ID!', 'error')
    end
end)

-- Get online players callback for custom menus
CreateThread(function()
    Wait(2000) -- Wait for QB-Core to fully load
    
    if QBCore and QBCore.Functions and QBCore.Functions.CreateCallback then
        QBCore.Functions.CreateCallback('heaven-troll:getOnlinePlayers', function(source, cb)
            if not HasAdminPermission(source) then
                cb({})
                return
            end
            
            local players = {}
            local QBPlayers = QBCore.Functions.GetPlayers()
            
            for _, playerId in pairs(QBPlayers) do
                local Player = QBCore.Functions.GetPlayer(playerId)
                if Player and Player.PlayerData and Player.PlayerData.charinfo then
                    table.insert(players, {
                        id = playerId,
                        name = (Player.PlayerData.charinfo.firstname or "Unknown") .. " " .. (Player.PlayerData.charinfo.lastname or "Player"),
                        citizenid = Player.PlayerData.citizenid or "Unknown"
                    })
                end
            end
            
            cb(players)
        end)
        print("^2[Heaven Troll]^7 Callback 'heaven-troll:getOnlinePlayers' registered successfully!")
    else
        print("^1[Heaven Troll]^7 Failed to register callback - QB-Core Functions not available")
    end
end)

-- Startup information
CreateThread(function()
    Wait(500)
    print("^2[Heaven Troll]^7 Server script loaded successfully!")
    print("^3[Heaven Troll]^7 ================================")
    
    if Config.AcePermissions.enabled then
        print("^2[Heaven Troll]^7 ACE Permission system enabled!")
        print("^3[Heaven Troll]^7 ========================================")
        print("^3[Heaven Troll]^7 TO GET PERMISSION IN-GAME:")
        print("^6[Heaven Troll]^7 1. Add to server.cfg:")
        print("^6[Heaven Troll]^7    add_ace qbcore.god command allow")
        print("^6[Heaven Troll]^7    add_ace heaven-troll.use command allow")
        print("^6[Heaven Troll]^7 2. For specific players:")
        print("^6[Heaven Troll]^7    add_ace identifier.steam:YOUR_STEAM_ID qbcore.god allow")
        print("^6[Heaven Troll]^7 3. Restart your server after adding permissions")
        print("^3[Heaven Troll]^7 ========================================")
    end
    
    print("^3[Heaven Troll]^7 QB-Core group permissions also supported:")
    for _, rank in pairs(Config.AdminRanks) do
        print("^6[Heaven Troll]^7   - " .. rank)
    end
    
    print("^3[Heaven Troll]^7 Commands: /heaventroll [playerid] or /heaven [playerid]")
    print("^3[Heaven Troll]^7 ================================")
end)

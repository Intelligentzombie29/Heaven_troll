local QBCore = exports['qb-core']:GetCoreObject()
local inHeavenEffect = false
local originalCoords = nil
local bookObj = nil

-- Play heavenly music
local function PlayHeavenMusic()
    if not Config.Audio.enabled then return end
    
    -- Play multiple heavenly sounds for ambiance
    PlaySoundFrontend(-1, "MEDAL_BRONZE", "HUD_AWARDS", 1)
    SetTimeout(1000, function()
        PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", 1)
    end)
    SetTimeout(2000, function()
        PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1)
    end)
end

-- Stop heaven music
local function StopHeavenMusic()
    if not Config.Audio.enabled then return end
    
    -- Stop any playing sounds
    StopSound(-1)
    
    -- Alternative: Stop custom audio
    -- SendNUIMessage({
    --     type = "stopAudio"
    -- })
end

-- Create heaven effect (visual effects)
local function CreateHeavenEffects()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Add particle effects if available
    -- This would require ptfx assets to be loaded
    -- RequestNamedPtfxAsset("core")
    -- while not HasNamedPtfxAssetLoaded("core") do
    --     Citizen.Wait(1)
    -- end
    -- UseParticleFxAssetNextCall("core")
    -- StartParticleFxLoopedAtCoord("ent_amb_falling_leaves", coords.x, coords.y, coords.z + 10.0, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
    
    -- Screen effect
    SetTimecycleModifier("hud_def_blur")
    SetTimecycleModifierStrength(0.3)
end

-- Remove heaven effects
local function RemoveHeavenEffects()
    ClearTimecycleModifier()
    -- Remove particle effects if created
    -- RemoveParticleFxInRange(coords.x, coords.y, coords.z, 50.0)
end

-- Start book reading and slow ascension to heaven
local function StartHeavenlyJourney()
    local ped = PlayerPedId()
    
    -- Store original coordinates
    originalCoords = GetEntityCoords(ped)
    
    -- Disable player control
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    
    -- Force first person view
    SetFollowPedCamViewMode(4) -- Force first person
    
    -- Start proper book reading animation
    if exports['rpemotes-reborn'] then
        -- Use rpemotes for better book reading animation
        exports['rpemotes-reborn']:EmoteCommandStart("book", 0) -- Better book reading emote
    else
        -- Fallback to basic animation with proper book
        RequestAnimDict("amb@world_human_reading@male@base")
        while not HasAnimDictLoaded("amb@world_human_reading@male@base") do
            Wait(10)
        end
        
        -- Give player a proper book prop
        local bookHash = GetHashKey("prop_novel_01")
        RequestModel(bookHash)
        while not HasModelLoaded(bookHash) do
            Wait(10)
        end
        
        -- Create book object and attach to player's hand properly
        bookObj = CreateObject(bookHash, 0, 0, 0, true, true, true)
        AttachEntityToEntity(bookObj, ped, GetPedBoneIndex(ped, 28422), 0.02, 0.02, 0.08, 15.0, 0.0, 0.0, true, true, false, true, 1, true)
        
        -- Start reading animation with loop
        TaskPlayAnim(ped, "amb@world_human_reading@male@base", "base", 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    
    -- Slowly ascend to heaven while reading
    local startCoords = GetEntityCoords(ped)
    local ascensionTime = 8000 -- 8 seconds to ascend
    local startTime = GetGameTimer()
    
    CreateThread(function()
        while GetGameTimer() - startTime < ascensionTime do
            local progress = (GetGameTimer() - startTime) / ascensionTime
            local newZ = startCoords.z + (progress * 800.0) -- Ascend 800 units
            
            SetEntityCoords(ped, startCoords.x, startCoords.y, newZ, false, false, false, true)
            Wait(50)
        end
        
        -- Stop rpemotes animation or clean up basic animation
        if exports['rpemotes-reborn'] then
            exports['rpemotes-reborn']:EmoteCancel()
        else
            -- Clean up basic animation
            if bookObj then
                DeleteObject(bookObj)
                bookObj = nil
            end
            ClearPedTasks(ped)
        end
        
        -- Now show Jesus
        ShowJesusEncounter()
    end)
end

-- Show Jesus encounter and decide fate
function ShowJesusEncounter()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Spawn Jesus ped
    local jesusHash = GetHashKey("u_m_m_jesus_01")
    RequestModel(jesusHash)
    while not HasModelLoaded(jesusHash) do
        Wait(10)
    end
    
    -- Calculate position directly in front of player
    local playerHeading = GetEntityHeading(ped)
    local frontX = coords.x + math.cos(math.rad(playerHeading)) * 3.0
    local frontY = coords.y + math.sin(math.rad(playerHeading)) * 3.0
    
    -- Create Jesus ped directly in front of player
    local jesusPed = CreatePed(4, jesusHash, frontX, frontY, coords.z, playerHeading + 180.0, false, true)
    SetEntityInvincible(jesusPed, true)
    SetBlockingOfNonTemporaryEvents(jesusPed, true)
    FreezeEntityPosition(jesusPed, true)
    SetEntityCanBeDamaged(jesusPed, false)
    SetPedCanRagdoll(jesusPed, false)
    
    -- Make Jesus face the player
    TaskTurnPedToFaceEntity(jesusPed, ped, 2000)
    
    -- Jesus greeting animation using rpemotes if available
    SetTimeout(1000, function()
        if exports['rpemotes-reborn'] then
            -- Use rpemotes for Jesus blessing animation
            TaskPlayAnim(jesusPed, "mp_player_int_upperbless", "mp_player_int_bless", 8.0, -8.0, 4000, 0, 0, false, false, false)
        else
            -- Fallback to basic greeting
            RequestAnimDict("gestures@m@standing@casual")
            while not HasAnimDictLoaded("gestures@m@standing@casual") do
                Wait(10)
            end
            TaskPlayAnim(jesusPed, "gestures@m@standing@casual", "gesture_hello", 8.0, -8.0, 3000, 0, 0, false, false, false)
        end
    end)
    
    -- Show notification about Jesus
    QBCore.Functions.Notify("Jesus appears before you! Your fate will be decided... 🙏", "primary", 4000)
    
    -- Wait 4 seconds then decide fate and remove Jesus
    SetTimeout(4000, function()
        DeleteEntity(jesusPed)
        SetModelAsNoLongerNeeded(jesusHash)
        
        -- Decide the fate (50/50)
        DecideFinalFate()
    end)
end

-- Handle survival outcome
local function HandleSurvival()
    local ped = PlayerPedId()
    
    -- Give parachute and auto-deploy it
    GiveWeaponToPed(ped, GetHashKey("GADGET_PARACHUTE"), 1, false, true)
    SetTimeout(1000, function()
        TaskParachute(ped, true)
    end)
    
    QBCore.Functions.Notify("Jesus blesses you with a parachute! You survived! 😇", "success", 5000)
end

-- Handle death outcome with humiliation
local function HandleDeath()
    local ped = PlayerPedId()
    
    QBCore.Functions.Notify("Jesus shakes his head... You have disappointed him greatly... 💀", "error", 5000)
    
    -- First make player poop themselves
    SetTimeout(1000, function()
        if exports['rpemotes-reborn'] then
            exports['rpemotes-reborn']:EmoteCommandStart("poop", 3000)
        else
            -- Fallback animation - crouch down in shame
            RequestAnimDict("anim@heists@ornate_bank@chat_manager")
            while not HasAnimDictLoaded("anim@heists@ornate_bank@chat_manager") do
                Wait(10)
            end
            TaskPlayAnim(ped, "anim@heists@ornate_bank@chat_manager", "fail", 8.0, -8.0, 3000, 0, 0, false, false, false)
        end
        
        QBCore.Functions.Notify("💩 You soil yourself in fear!", "error", 3000)
        
        -- Then set them on fire after pooping
        SetTimeout(3000, function()
            StartEntityFire(ped)
            QBCore.Functions.Notify("🔥 Divine punishment! You burst into flames!", "error", 4000)
            
            -- Kill player after being on fire for a moment
            SetTimeout(2000, function()
                SetEntityHealth(ped, 0)
            end)
        end)
    end)
end

-- Decide final fate (50/50 chance)
function DecideFinalFate()
    local ped = PlayerPedId()
    
    -- Generate 50/50 outcome
    local survives = math.random(1, 100) <= Config.TrollSettings.survivalChance
    
    if survives then
        QBCore.Functions.Notify("Jesus smiles upon you! 😇", "success", 3000)
        
        -- Player celebration animation
        if exports['rpemotes-reborn'] then
            exports['rpemotes-reborn']:EmoteCommandStart("cheer", 3000)
        end
        
        SetTimeout(1000, function()
            HandleSurvival()
        end)
    else
        QBCore.Functions.Notify("Jesus frowns and turns away... 😔", "error", 3000)
        
        -- Player despair animation
        if exports['rpemotes-reborn'] then
            exports['rpemotes-reborn']:EmoteCommandStart("cry", 3000)
        end
        
        SetTimeout(1000, function()
            HandleDeath()
        end)
    end
    
    -- Re-enable physics and movement, restore camera
    SetTimeout(2000, function()
        SetEntityInvincible(ped, false)
        FreezeEntityPosition(ped, false)
        -- Restore normal camera view
        SetFollowPedCamViewMode(1) -- Third person
    end)
end

-- Main heaven troll effect with cinematic sequence
RegisterNetEvent('heaven-troll:startEffect')
AddEventHandler('heaven-troll:startEffect', function(willSurvive)
    if inHeavenEffect then return end
    
    inHeavenEffect = true
    
    QBCore.Functions.Notify("You feel a divine presence... A holy book appears! 📖", "primary", 4000)
    
    -- Start with prayer animation if rpemotes available
    if exports['rpemotes-reborn'] then
        exports['rpemotes-reborn']:EmoteCommandStart("pray", 2000)
    end
    
    -- Start the cinematic sequence
    PlayHeavenMusic()
    CreateHeavenEffects()
    
    -- Start the heavenly journey (book reading + slow ascension)
    SetTimeout(2000, function()
        StartHeavenlyJourney()
    end)
    
    -- Clean up after the entire sequence
    SetTimeout(20000, function() -- Extended time for full sequence
        RemoveHeavenEffects()
        StopHeavenMusic()
        
        -- Reset flag after everything is done
        SetTimeout(5000, function()
            inHeavenEffect = false
        end)
    end)
end)

-- Prevent abuse during effect
CreateThread(function()
    while true do
        Wait(1000)
        if inHeavenEffect then
            local ped = PlayerPedId()
            -- Prevent weapon usage during effect
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 47, true) -- Weapon wheel
        end
    end
end)

print("^2[Heaven Troll]^7 Client script loaded successfully!")

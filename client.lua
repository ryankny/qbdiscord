--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                         QBDISCORD JOB SYNC                                ║
    ║                         Client-Side Script                                ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

-- Custom notification handler (if not using QBCore notifications)
RegisterNetEvent('qbdiscord:notification', function(message, type)
    -- Fallback notification using native GTA notification
    -- Replace with your notification system if needed
    
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end)

-- Register command help text
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Settings.Command, 'Sync your Discord roles to your in-game job')
end)

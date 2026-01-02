--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                         QBDISCORD JOB SYNC                                ║
    ║                         Server-Side Script                                ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

local QBCore = exports['qb-core']:GetCoreObject()
local Cooldowns = {}

-- Sort job mappings by priority (highest first) on resource start
local SortedMappings = {}

CreateThread(function()
    -- Copy and sort mappings by priority descending
    for _, mapping in ipairs(Config.JobMappings) do
        table.insert(SortedMappings, mapping)
    end
    
    table.sort(SortedMappings, function(a, b)
        return a.priority > b.priority
    end)
    
    Debug("Loaded %d job mappings (sorted by priority)", #SortedMappings)
end)

--[[
    ═══════════════════════════════════════════════════════════════════════════
                                UTILITY FUNCTIONS
    ═══════════════════════════════════════════════════════════════════════════
]]

function Debug(msg, ...)
    if Config.Settings.Debug then
        print(string.format("^3[QBDISCORD]^7 [DEBUG] " .. msg, ...))
    end
end

function Log(msg, ...)
    print(string.format("^2[QBDISCORD]^7 " .. msg, ...))
end

function LogError(msg, ...)
    print(string.format("^1[QBDISCORD]^7 [ERROR] " .. msg, ...))
end

function GetDiscordId(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(id, "discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

function Notify(source, msg, type)
    TriggerClientEvent('QBCore:Notify', source, msg, type or "primary", 5000)
end

function IsOnCooldown(source)
    if not Cooldowns[source] then return false end
    return (os.time() - Cooldowns[source]) < Config.Settings.Cooldown
end

function GetCooldownRemaining(source)
    if not Cooldowns[source] then return 0 end
    return Config.Settings.Cooldown - (os.time() - Cooldowns[source])
end

function SetCooldown(source)
    Cooldowns[source] = os.time()
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
                              DISCORD API FUNCTIONS
    ═══════════════════════════════════════════════════════════════════════════
]]

function FetchMemberRoles(guildId, discordId, callback)
    local url = string.format(
        "https://discord.com/api/%s/guilds/%s/members/%s",
        Config.Bot.ApiVersion,
        guildId,
        discordId
    )
    
    Debug("API Request: %s", url)
    
    PerformHttpRequest(url, function(statusCode, response, headers)
        Debug("API Response: %d", statusCode)
        
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.roles then
                callback(data.roles, nil)
            else
                callback(nil, "Invalid response format")
            end
        elseif statusCode == 404 then
            callback(nil, "not_in_server")
        elseif statusCode == 401 then
            callback(nil, "Invalid bot token")
        elseif statusCode == 403 then
            callback(nil, "Bot lacks permissions")
        elseif statusCode == 429 then
            callback(nil, "Rate limited - try again")
        else
            callback(nil, "API error: " .. tostring(statusCode))
        end
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Bot.Token,
        ["Content-Type"] = "application/json"
    })
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
                              ROLE CHECKING LOGIC
    ═══════════════════════════════════════════════════════════════════════════
]]

function CheckAllServersForRoles(discordId, callback)
    local allRoles = {}      -- guildId -> { roleId = true }
    local serversToCheck = {}
    local serversChecked = 0
    local hasError = false
    local errorMsg = nil
    
    -- Build list of enabled servers
    for key, server in pairs(Config.Servers) do
        if server.enabled then
            table.insert(serversToCheck, { key = key, server = server })
        end
    end
    
    if #serversToCheck == 0 then
        callback(nil, "No servers configured")
        return
    end
    
    Debug("Checking %d Discord servers for user %s", #serversToCheck, discordId)
    
    -- Check each server
    for _, data in ipairs(serversToCheck) do
        FetchMemberRoles(data.server.id, discordId, function(roles, err)
            serversChecked = serversChecked + 1
            
            if err then
                if err == "not_in_server" then
                    Debug("User not in server: %s", data.server.name)
                else
                    LogError("Error checking %s: %s", data.server.name, err)
                    hasError = true
                    errorMsg = err
                end
            else
                Debug("Found %d roles in %s", #roles, data.server.name)
                allRoles[data.key] = {}
                for _, roleId in ipairs(roles) do
                    allRoles[data.key][roleId] = true
                end
            end
            
            -- All servers checked
            if serversChecked >= #serversToCheck then
                if hasError and next(allRoles) == nil then
                    callback(nil, errorMsg)
                else
                    callback(allRoles, nil)
                end
            end
        end)
    end
end

function FindMatchingJob(allRoles)
    -- SortedMappings is already sorted by priority (highest first)
    -- First match wins
    
    for _, mapping in ipairs(SortedMappings) do
        local serverRoles = allRoles[mapping.server]
        
        if serverRoles and serverRoles[mapping.role] then
            Debug("Matched role: %s (priority %d) -> %s grade %d", 
                mapping.label, mapping.priority, mapping.job, mapping.grade)
            return mapping
        end
    end
    
    return nil
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
                                 MAIN COMMAND
    ═══════════════════════════════════════════════════════════════════════════
]]

RegisterCommand(Config.Settings.Command, function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        return
    end
    
    -- Check cooldown
    if IsOnCooldown(src) then
        Notify(src, string.format(Config.Messages.Cooldown, GetCooldownRemaining(src)), "error")
        return
    end
    
    -- Get Discord ID
    local discordId = GetDiscordId(src)
    
    if not discordId then
        Notify(src, Config.Messages.NoDiscord, "error")
        return
    end
    
    Debug("Player %s (Discord: %s) using /getjob", GetPlayerName(src), discordId)
    
    -- Set cooldown immediately
    SetCooldown(src)
    
    -- Notify player we're checking
    Notify(src, Config.Messages.Checking, "primary")
    
    -- Check all servers for roles
    CheckAllServersForRoles(discordId, function(allRoles, err)
        if err then
            LogError("Failed to check roles for %s: %s", discordId, err)
            Notify(src, Config.Messages.Error, "error")
            return
        end
        
        if not allRoles or next(allRoles) == nil then
            Debug("No roles found in any server for %s", discordId)
            
            if Config.Settings.RemoveJobIfNoRole then
                Player.Functions.SetJob(Config.Settings.DefaultJob.name, Config.Settings.DefaultJob.grade)
                Notify(src, Config.Messages.NoRole, "error")
            else
                Notify(src, Config.Messages.NoRole, "error")
            end
            return
        end
        
        -- Find best matching job based on priority
        local matchedJob = FindMatchingJob(allRoles)
        
        if matchedJob then
            -- Set the job
            Player.Functions.SetJob(matchedJob.job, matchedJob.grade)
            
            -- Get grade label from QBCore
            local jobData = QBCore.Shared.Jobs[matchedJob.job]
            local gradeLabel = matchedJob.label
            
            if jobData and jobData.grades and jobData.grades[matchedJob.grade] then
                gradeLabel = jobData.grades[matchedJob.grade].name or matchedJob.label
            end
            
            Log("Set job for %s: %s (grade %d - %s)", 
                GetPlayerName(src), matchedJob.job, matchedJob.grade, matchedJob.label)
            
            Notify(src, string.format(Config.Messages.Success, matchedJob.label, matchedJob.job), "success")
        else
            Debug("No matching job mapping for %s", discordId)
            
            if Config.Settings.RemoveJobIfNoRole then
                Player.Functions.SetJob(Config.Settings.DefaultJob.name, Config.Settings.DefaultJob.grade)
            end
            
            Notify(src, Config.Messages.NoRole, "error")
        end
    end)
end, false)

--[[
    ═══════════════════════════════════════════════════════════════════════════
                              ADMIN COMMANDS (Optional)
    ═══════════════════════════════════════════════════════════════════════════
]]

-- Admin command to check a player's Discord roles
QBCore.Commands.Add('checkdiscord', 'Check a player\'s Discord roles (Admin)', {
    { name = 'id', help = 'Player server ID' }
}, true, function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        Notify(source, "Invalid player ID", "error")
        return
    end
    
    local discordId = GetDiscordId(targetId)
    
    if not discordId then
        Notify(source, "Target has no Discord linked", "error")
        return
    end
    
    Notify(source, "Checking Discord roles...", "primary")
    
    CheckAllServersForRoles(discordId, function(allRoles, err)
        if err then
            Notify(source, "Error: " .. err, "error")
            return
        end
        
        local count = 0
        for serverKey, roles in pairs(allRoles) do
            for roleId, _ in pairs(roles) do
                count = count + 1
            end
        end
        
        Notify(source, string.format("Found %d roles across all servers", count), "success")
        
        -- Print detailed info to console
        print("^3[QBDISCORD]^7 Discord roles for " .. GetPlayerName(targetId) .. ":")
        for serverKey, roles in pairs(allRoles) do
            print("  Server: " .. serverKey)
            for roleId, _ in pairs(roles) do
                print("    - " .. roleId)
            end
        end
    end)
end, 'admin')

-- Admin command to force refresh a player's job
QBCore.Commands.Add('refreshjob', 'Force refresh a player\'s job from Discord (Admin)', {
    { name = 'id', help = 'Player server ID' }
}, true, function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        Notify(source, "Invalid player ID", "error")
        return
    end
    
    -- Trigger the command as if the target used it (bypass cooldown)
    Cooldowns[targetId] = nil
    ExecuteCommand(string.format('%s', Config.Settings.Command))
    
    Notify(source, "Refreshing job for player " .. targetId, "success")
end, 'admin')

--[[
    ═══════════════════════════════════════════════════════════════════════════
                                    EXPORTS
    ═══════════════════════════════════════════════════════════════════════════
]]

-- Export to check roles programmatically
exports('GetPlayerDiscordRoles', function(source, callback)
    local discordId = GetDiscordId(source)
    if not discordId then
        callback(nil, "No Discord linked")
        return
    end
    CheckAllServersForRoles(discordId, callback)
end)

-- Export to find matching job for a player
exports('GetMatchingJob', function(source, callback)
    local discordId = GetDiscordId(source)
    if not discordId then
        callback(nil, "No Discord linked")
        return
    end
    
    CheckAllServersForRoles(discordId, function(allRoles, err)
        if err then
            callback(nil, err)
            return
        end
        callback(FindMatchingJob(allRoles), nil)
    end)
end)

--[[
    ═══════════════════════════════════════════════════════════════════════════
                                   CLEANUP
    ═══════════════════════════════════════════════════════════════════════════
]]

AddEventHandler('playerDropped', function()
    Cooldowns[source] = nil
end)

Log("Discord Job Sync loaded - Command: /%s", Config.Settings.Command)

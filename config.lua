Config = {}

--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                         DISCORD BOT CONFIGURATION                         ║
    ╠═══════════════════════════════════════════════════════════════════════════╣
    ║  Your bot must be in ALL Discord servers listed below                     ║
    ║  Required bot permissions:                                                ║
    ║    - View Server Members (Privileged Intent - enable in Developer Portal) ║
    ║                                                                           ║
    ║  Developer Portal > Bot > Privileged Gateway Intents > Server Members     ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

Config.Bot = {
    Token = "YOUR_BOT_TOKEN_HERE",
    ApiVersion = "v10",
}

--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                         DISCORD SERVER DEFINITIONS                        ║
    ╠═══════════════════════════════════════════════════════════════════════════╣
    ║  Define all Discord servers to check for roles                            ║
    ║  Key = reference name used in job mappings                                ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

Config.Servers = {
    ["main"] = {
        id = "123456789012345678",
        name = "Main Community",
        enabled = true,
    },
    
    ["leo"] = {
        id = "234567890123456789",
        name = "Law Enforcement",
        enabled = true,
    },
    
    ["ems"] = {
        id = "345678901234567890",
        name = "EMS & Fire",
        enabled = true,
    },
}

--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                              JOB MAPPINGS                                 ║
    ╠═══════════════════════════════════════════════════════════════════════════╣
    ║  Maps Discord roles to QBCore jobs                                        ║
    ║                                                                           ║
    ║  PRIORITY SYSTEM:                                                         ║
    ║  - Higher priority number = checked first                                 ║
    ║  - First matching role WINS (stops checking)                              ║
    ║  - Example: Officer II (priority 70) beats "Police Department"            ║
    ║                                                                           ║
    ║  Fields:                                                                  ║
    ║    server   = key from Config.Servers                                     ║
    ║    role     = Discord Role ID                                             ║
    ║    job      = QBCore job name (from jobs.lua)                             ║
    ║    grade    = QBCore grade number                                         ║
    ║    priority = higher number = higher priority                             ║
    ║    label    = display name for notifications                              ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

Config.JobMappings = {
    
    --[[
        ═══════════════════════════════════════════════════════════════════════
                            LSPD (Law Enforcement Server)
        ═══════════════════════════════════════════════════════════════════════
        Priority: Chief (100) > Asst Chief (95) > Captain (90) > ... > Dept Role (10)
    ]]
    
    -- Command Staff
    { server = "leo", role = "111111111111111100", job = "police", grade = 15, priority = 100, label = "Chief of Police" },
    { server = "leo", role = "111111111111111101", job = "police", grade = 14, priority = 95,  label = "Assistant Chief" },
    { server = "leo", role = "111111111111111102", job = "police", grade = 13, priority = 90,  label = "Deputy Chief" },
    
    -- Senior Officers
    { server = "leo", role = "111111111111111103", job = "police", grade = 12, priority = 85,  label = "Commander" },
    { server = "leo", role = "111111111111111104", job = "police", grade = 11, priority = 80,  label = "Captain" },
    { server = "leo", role = "111111111111111105", job = "police", grade = 10, priority = 75,  label = "Lieutenant" },
    { server = "leo", role = "111111111111111106", job = "police", grade = 9,  priority = 70,  label = "Sergeant II" },
    { server = "leo", role = "111111111111111107", job = "police", grade = 8,  priority = 65,  label = "Sergeant I" },
    
    -- Officers
    { server = "leo", role = "111111111111111108", job = "police", grade = 7,  priority = 60,  label = "Senior Lead Officer" },
    { server = "leo", role = "111111111111111109", job = "police", grade = 6,  priority = 55,  label = "Officer III+1" },
    { server = "leo", role = "111111111111111110", job = "police", grade = 5,  priority = 50,  label = "Officer III" },
    { server = "leo", role = "111111111111111111", job = "police", grade = 4,  priority = 45,  label = "Officer II" },
    { server = "leo", role = "111111111111111112", job = "police", grade = 3,  priority = 40,  label = "Officer I" },
    { server = "leo", role = "111111111111111113", job = "police", grade = 2,  priority = 35,  label = "Probationary Officer" },
    { server = "leo", role = "111111111111111114", job = "police", grade = 1,  priority = 30,  label = "Police Cadet" },
    
    -- Department Role (fallback - lowest priority)
    { server = "leo", role = "111111111111111199", job = "police", grade = 0,  priority = 10,  label = "Police Recruit" },
    
    
    --[[
        ═══════════════════════════════════════════════════════════════════════
                            BCSO (Law Enforcement Server)
        ═══════════════════════════════════════════════════════════════════════
    ]]
    
    { server = "leo", role = "222222222222222200", job = "bcso", grade = 10, priority = 100, label = "Sheriff" },
    { server = "leo", role = "222222222222222201", job = "bcso", grade = 9,  priority = 95,  label = "Undersheriff" },
    { server = "leo", role = "222222222222222202", job = "bcso", grade = 8,  priority = 90,  label = "Assistant Sheriff" },
    { server = "leo", role = "222222222222222203", job = "bcso", grade = 7,  priority = 85,  label = "Captain" },
    { server = "leo", role = "222222222222222204", job = "bcso", grade = 6,  priority = 80,  label = "Lieutenant" },
    { server = "leo", role = "222222222222222205", job = "bcso", grade = 5,  priority = 75,  label = "Sergeant" },
    { server = "leo", role = "222222222222222206", job = "bcso", grade = 4,  priority = 70,  label = "Senior Deputy" },
    { server = "leo", role = "222222222222222207", job = "bcso", grade = 3,  priority = 65,  label = "Deputy II" },
    { server = "leo", role = "222222222222222208", job = "bcso", grade = 2,  priority = 60,  label = "Deputy I" },
    { server = "leo", role = "222222222222222209", job = "bcso", grade = 1,  priority = 55,  label = "Trainee Deputy" },
    { server = "leo", role = "222222222222222299", job = "bcso", grade = 0,  priority = 10,  label = "BCSO Recruit" },
    
    
    --[[
        ═══════════════════════════════════════════════════════════════════════
                                EMS (EMS Server)
        ═══════════════════════════════════════════════════════════════════════
    ]]
    
    { server = "ems", role = "333333333333333300", job = "ambulance", grade = 10, priority = 100, label = "EMS Director" },
    { server = "ems", role = "333333333333333301", job = "ambulance", grade = 9,  priority = 95,  label = "Assistant Director" },
    { server = "ems", role = "333333333333333302", job = "ambulance", grade = 8,  priority = 90,  label = "Chief of Medicine" },
    { server = "ems", role = "333333333333333303", job = "ambulance", grade = 7,  priority = 85,  label = "Captain" },
    { server = "ems", role = "333333333333333304", job = "ambulance", grade = 6,  priority = 80,  label = "Lieutenant" },
    { server = "ems", role = "333333333333333305", job = "ambulance", grade = 5,  priority = 75,  label = "Doctor" },
    { server = "ems", role = "333333333333333306", job = "ambulance", grade = 4,  priority = 70,  label = "Senior Paramedic" },
    { server = "ems", role = "333333333333333307", job = "ambulance", grade = 3,  priority = 65,  label = "Paramedic" },
    { server = "ems", role = "333333333333333308", job = "ambulance", grade = 2,  priority = 60,  label = "EMT" },
    { server = "ems", role = "333333333333333309", job = "ambulance", grade = 1,  priority = 55,  label = "EMT Trainee" },
    { server = "ems", role = "333333333333333399", job = "ambulance", grade = 0,  priority = 10,  label = "EMS Recruit" },
    
    
    --[[
        ═══════════════════════════════════════════════════════════════════════
                            FIRE DEPARTMENT (EMS Server)
        ═══════════════════════════════════════════════════════════════════════
    ]]
    
    { server = "ems", role = "444444444444444400", job = "fire", grade = 8,  priority = 100, label = "Fire Chief" },
    { server = "ems", role = "444444444444444401", job = "fire", grade = 7,  priority = 95,  label = "Assistant Chief" },
    { server = "ems", role = "444444444444444402", job = "fire", grade = 6,  priority = 90,  label = "Battalion Chief" },
    { server = "ems", role = "444444444444444403", job = "fire", grade = 5,  priority = 85,  label = "Captain" },
    { server = "ems", role = "444444444444444404", job = "fire", grade = 4,  priority = 80,  label = "Engineer" },
    { server = "ems", role = "444444444444444405", job = "fire", grade = 3,  priority = 75,  label = "Firefighter III" },
    { server = "ems", role = "444444444444444406", job = "fire", grade = 2,  priority = 70,  label = "Firefighter II" },
    { server = "ems", role = "444444444444444407", job = "fire", grade = 1,  priority = 65,  label = "Firefighter I" },
    { server = "ems", role = "444444444444444499", job = "fire", grade = 0,  priority = 10,  label = "Fire Recruit" },
    
    
    --[[
        ═══════════════════════════════════════════════════════════════════════
                            CIVILIAN JOBS (Main Server)
        ═══════════════════════════════════════════════════════════════════════
    ]]
    
    -- Mechanic
    { server = "main", role = "555555555555555500", job = "mechanic", grade = 4, priority = 100, label = "Shop Owner" },
    { server = "main", role = "555555555555555501", job = "mechanic", grade = 3, priority = 90,  label = "Head Mechanic" },
    { server = "main", role = "555555555555555502", job = "mechanic", grade = 2, priority = 80,  label = "Senior Mechanic" },
    { server = "main", role = "555555555555555503", job = "mechanic", grade = 1, priority = 70,  label = "Mechanic" },
    { server = "main", role = "555555555555555504", job = "mechanic", grade = 0, priority = 60,  label = "Trainee" },
    
    -- Real Estate
    { server = "main", role = "666666666666666600", job = "realestate", grade = 3, priority = 100, label = "Agency Owner" },
    { server = "main", role = "666666666666666601", job = "realestate", grade = 2, priority = 90,  label = "Senior Agent" },
    { server = "main", role = "666666666666666602", job = "realestate", grade = 1, priority = 80,  label = "Agent" },
    { server = "main", role = "666666666666666603", job = "realestate", grade = 0, priority = 70,  label = "Trainee" },
}

--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                           GENERAL SETTINGS                                ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

Config.Settings = {
    Command = "getjob",
    Cooldown = 30,                           -- Seconds between uses
    Debug = false,                           -- Print debug info to console
    
    -- If true: sets player to unemployed when no role matches
    -- If false: keeps their current job when no role matches
    RemoveJobIfNoRole = false,
    DefaultJob = { name = "unemployed", grade = 0 },
}

--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                            NOTIFICATION MESSAGES                          ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

Config.Messages = {
    NoDiscord      = "Discord not linked. Make sure Discord is running and connected to FiveM.",
    Checking       = "Checking your Discord roles...",
    Success        = "Job updated: %s (%s)",          -- job label, grade label
    NoRole         = "No matching Discord roles found.",
    Cooldown       = "Please wait %s seconds.",
    Error          = "Error checking roles. Try again later.",
    NotInServer    = "You must be in the %s Discord server.",
}

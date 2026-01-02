# QBDiscord

Automatically assign QBCore jobs based on Discord roles across multiple servers.

## Features

- **Multi-Server Support**: Check roles across multiple Discord servers (LEO, EMS, Main, etc.)
- **Priority System**: Higher priority roles take precedence (Officer II > Police Department role)
- **Single Job Assignment**: Assigns one job based on the highest priority matching role
- **Cooldown Protection**: Prevents command spam
- **Admin Commands**: Check and refresh player jobs

## Installation

1. **Create Discord Bot**
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Create a new application
   - Go to "Bot" tab and create a bot
   - Copy the bot token
   - Enable **Server Members Intent** under Privileged Gateway Intents
   - Invite bot to ALL your Discord servers with `Read Members` permission

2. **Install Resource**
   - Place `qbdiscord` folder in your resources directory
   - Add `ensure qbdiscord` to your server.cfg (after qb-core)

3. **Configure**
   - Open `config.lua`
   - Add your bot token to `Config.Bot.Token`
   - Add your Discord server IDs to `Config.Servers`
   - Configure role mappings in `Config.JobMappings`

## Configuration

### Bot Token

```lua
Config.Bot = {
    Token = "YOUR_BOT_TOKEN_HERE",  -- Get from Discord Developer Portal
    ApiVersion = "v10",
}
```

### Discord Servers

```lua
Config.Servers = {
    ["leo"] = {
        id = "123456789012345678",  -- Right-click server > Copy Server ID
        name = "Law Enforcement",
        enabled = true,
    },
    ["ems"] = {
        id = "234567890123456789",
        name = "EMS & Fire",
        enabled = true,
    },
}
```

### Job Mappings

```lua
Config.JobMappings = {
    -- Higher priority = checked first
    -- First match wins
    
    { server = "leo", role = "ROLE_ID", job = "police", grade = 10, priority = 100, label = "Chief" },
    { server = "leo", role = "ROLE_ID", job = "police", grade = 5,  priority = 50,  label = "Officer II" },
    { server = "leo", role = "ROLE_ID", job = "police", grade = 0,  priority = 10,  label = "Police Dept" },
}
```

### Priority System

The priority system ensures rank roles beat department roles:

| Role | Priority | Result |
|------|----------|--------|
| Chief of Police | 100 | Wins if player has this role |
| Captain | 90 | Wins if no higher role |
| Officer II | 50 | Wins if no higher role |
| Police Department | 10 | Only used if no rank role |

## Commands

| Command | Description | Permission |
|---------|-------------|------------|
| `/getjob` | Sync Discord roles to job | Everyone |
| `/checkdiscord [id]` | View player's Discord roles | Admin |
| `/refreshjob [id]` | Force refresh player's job | Admin |

## Getting Discord IDs

1. Enable Developer Mode in Discord (User Settings > Advanced > Developer Mode)
2. **Server ID**: Right-click server name > Copy Server ID
3. **Role ID**: Server Settings > Roles > Right-click role > Copy Role ID

## Exports

```lua
-- Get all Discord roles for a player
exports['qbdiscord']:GetPlayerDiscordRoles(source, function(roles, err)
    if err then print(err) return end
    -- roles = { ["leo"] = { ["roleId"] = true }, ... }
end)

-- Get the matching job for a player
exports['qbdiscord']:GetMatchingJob(source, function(job, err)
    if err then print(err) return end
    -- job = { server, role, job, grade, priority, label }
end)
```

## Troubleshooting

### "Discord not linked"
- Player needs Discord open and connected to FiveM
- Check if Discord identifier shows in player identifiers

### "Bot lacks permissions"
- Ensure Server Members Intent is enabled in Developer Portal
- Re-invite bot with correct permissions

### "Not in server"
- Player must be in the Discord server being checked
- Verify server ID is correct

### No job assigned despite having role
- Check role ID is correct (18-digit number)
- Verify role is in correct server key
- Enable `Config.Settings.Debug = true` for detailed logs

## Support

Built by Hydra Labs

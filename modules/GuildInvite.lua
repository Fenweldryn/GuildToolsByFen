GuildToolsByFenInternals.GuildInvite = {}
local GuildInvite = GuildToolsByFenInternals.GuildInvite

function GuildInvite.addMenuItem(playerName, rawName)    
    guildsSubMenu = {}
    
    for i = 1, GetNumGuilds() do
        guildId = GetGuildId(i)
        guildName = GetGuildName(guildId)
        guildsSubMenu[i] = {
            label = guildName,
            callback = function() GuildInvite(guildId, playerName) end,
            itemType = MENU_ADD_OPTION_LABEL,
            tooltip = "Invite " .. playerName .. ' to ' .. guildName,
        }
    end
    AddCustomSubMenuItem("Invite to Guild", guildsSubMenu)
end

LibCustomMenu:RegisterPlayerContextMenu(GuildInvite.addMenuItem)

GuildToolsByFenInternals.TimeJoined = {}
local TimeJoined = GuildToolsByFenInternals.TimeJoined
local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang

function TimeJoined.createTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""
    
    if (GuildToolsByFen.history[guildId][string.lower(displayName)].timeJoined) then
        num, str = secToTime(timeStamp - GuildToolsByFen.history[guildId][string.lower(displayName)].timeJoined)
        tooltip = tooltip .. string.format(langStrings[lang].member, "", num, str)
    else
        num, str = secToTime(timeStamp - GuildToolsByFen.history[guildId].oldestEvent)
        tooltip = tooltip .. string.format(langStrings[lang].member, "> ", num, str)
    end
    
    return tooltip
end

function TimeJoined.storeGuildJoins(guildId, user, eventTime)
    if(GuildToolsByFen.history[guildId][string.lower(user)].timeJoined ~= nil) then return end
    
    GuildToolsByFen.history[guildId][string.lower(user)].timeJoined = eventTime    
end
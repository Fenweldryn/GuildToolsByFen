GuildToolsByFenInternals.TimeJoined = {}
local TimeJoined = GuildToolsByFenInternals.TimeJoined
local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang

function TimeJoined.createTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""
    
    if (GuildToolsByFen.history[guildId][displayName].timeJoined) then
        num, str = secToTime(timeStamp - GuildToolsByFen.history[guildId][displayName].timeJoined)
        tooltip = tooltip .. string.format(langStrings[lang].member, "", num, str)
    else
        num, str = secToTime(timeStamp - GuildToolsByFen.history[guildId].oldestEvent)
        tooltip = tooltip .. string.format(langStrings[lang].member, "> ", num, str)
    end
    
    return tooltip
end

function TimeJoined.storeGuildJoins(guildId, user, eventTime)
    if(GuildToolsByFen.history[guildId][user].timeJoined ~= nil) then return end
    
    GuildToolsByFen.history[guildId][user].timeJoined = eventTime    
end
GuildToolsByFenInternals.BankGoldTransactions = {}
local BankGoldTransactions = GuildToolsByFenInternals.BankGoldTransactions
local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang

function BankGoldTransactions.store(guildId, user, gold, event, eventTime)  
    
    eventDate = os.date("*t", eventTime)
    eventDate.yWeek = os.date('%U', eventTime);
    eventDate.tradeWeek = eventDate.yWeek;
    today = os.date("*t")
    today.yWeek = os.date('%U', os.time());
    today.tradeWeek = today.yWeek;

    if(eventDate.year ~= os.date('*t', os.time()).year) then return end
    if(eventTime < (os.time() - 60*60*24*30)) then return end
    
    -- last 30 days
    if(eventTime >= (os.time() - 60*60*24*30)) then 
        GuildToolsByFen.history[guildId][user][event].last30Days = gold + GuildToolsByFen.history[guildId][user][event].last30Days
    end
    
    -- checking event and today's trade week (trade weeks start tuesdays at 2:01pm)
    if(today.wday <= 2 or (today.wday == 3 and today.hour < 14)) then
        today.tradeWeek = today.yWeek - 1
    end
    if(eventDate.wday <= 2 or (eventDate.wday == 3 and eventDate.hour < 14)) then
        eventDate.tradeWeek = eventDate.yWeek - 1
    end            
   
    -- last week
    if (tonumber(eventDate.tradeWeek) == tonumber(today.tradeWeek - 1)) then
        GuildToolsByFen.history[guildId][user][event].lastWeek = gold + GuildToolsByFen.history[guildId][user][event].lastWeek        
    end
    
    -- this week
    if (eventDate.tradeWeek == today.tradeWeek) then
        GuildToolsByFen.history[guildId][user][event].thisWeek = gold + GuildToolsByFen.history[guildId][user][event].thisWeek
    end
    
    -- today
    if (eventDate.day == today.day and eventDate.month == today.month) then
        GuildToolsByFen.history[guildId][user][event].today = gold + GuildToolsByFen.history[guildId][user][event].today
    end
end

function BankGoldTransactions.resetUserTransactions(guildId)
    if (GuildToolsByFen.history[guildId] ~= nil) then
        for index, value in pairs(GuildToolsByFen.history[guildId]) do    
            if(string.sub(index, 1, 1) == '@') then
                GuildToolsByFen.history[guildId][index].deposits = {
                    last30Days = 0,
                    lastWeek = 0,
                    thisWeek = 0,
                    today = 0
                }
                GuildToolsByFen.history[guildId][index].withdrawals = {
                    last30Days = 0,
                    lastWeek = 0,
                    thisWeek = 0,
                    today = 0
                }
            end
        end
    end
end

function BankGoldTransactions.createDepositsTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""
    local tooltip = tooltip .. "\n\n" .. langStrings[lang].bankGoldDeposits .. '\n'
    local deposits = GuildToolsByFen.history[guildId][displayName].deposits
    
    if (deposits.last30Days == 0
        and deposits.lastWeek == 0
        and deposits.thisWeek == 0
        and deposits.today == 0) then
        tooltip = tooltip .. langStrings[lang].noRecords
    else
        depositsLast30Days = deposits.last30Days
        tooltip = tooltip .. string.format(langStrings[lang].last30Days, depositsLast30Days)
        
        tooltip = tooltip .. "\n"           
        depositsLastWeek = deposits.lastWeek
        tooltip = tooltip .. string.format(langStrings[lang].lastWeek, depositsLastWeek)
        
        tooltip = tooltip .. "\n"           
        depositsThisWeek = deposits.thisWeek
        tooltip = tooltip .. string.format(langStrings[lang].thisWeek, depositsThisWeek)
        
        tooltip = tooltip .. "\n"           
        depositsToday = deposits.today
        tooltip = tooltip .. string.format(langStrings[lang].today, depositsToday)
    end

    return tooltip
end

function BankGoldTransactions.createWhidrawalsTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""
    local tooltip = tooltip .. "\n\n" .. langStrings[lang].bankGoldWithdrawals .. '\n'
    local withdrawals = GuildToolsByFen.history[guildId][displayName].withdrawals
    
    if (withdrawals.last30Days == 0 
    and withdrawals.lastWeek == 0 
    and withdrawals.thisWeek == 0
    and withdrawals.today == 0) then
        tooltip = tooltip .. langStrings[lang].noRecords
    else
        withdrawalsLast30Days = withdrawals.last30Days
        tooltip = tooltip .. string.format(langStrings[lang].last30Days, withdrawalsLast30Days)
        
        tooltip = tooltip .. "\n"           
        withdrawalsLastWeek = withdrawals.lastWeek
        tooltip = tooltip .. string.format(langStrings[lang].lastWeek, withdrawalsLastWeek)
        
        tooltip = tooltip .. "\n"           
        withdrawalsThisWeek = withdrawals.thisWeek
        tooltip = tooltip .. string.format(langStrings[lang].thisWeek, withdrawalsThisWeek)
        
        tooltip = tooltip .. "\n"           
        withdrawalsToday = withdrawals.today
        tooltip = tooltip .. string.format(langStrings[lang].today, withdrawalsToday)
    end
    
    return tooltip
end
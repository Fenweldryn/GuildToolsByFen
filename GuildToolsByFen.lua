-------------------------------------------------------------------------------
-- Guild Tools By Fen v0.6.1
-------------------------------------------------------------------------------
-- Author: Fenweldryn
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media
-- Inc. or its affiliates. The Elder Scrolls® and related logos are registered
-- trademarks or trademarks of ZeniMax Media Inc. in the United States and/or
-- other countries.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------

local LSC = LibSlashCommander
local name = "GuildToolsByFen"
local scanGuildIndex = nil
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit
local lang = 'en'
local langStrings =
{
    en =
    {
        member      = "Member for %s%i %s",
        deposits    = "Deposits",
        withdrawals = "Withdrawals",
        total       = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (over %i %s)",
        last        = "Last: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s ago)",
        minute      = "minute",
        hour        = "hour",
        day         = "day",
        last30Days  = "last 30 days: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        lastWeek    = "last week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        thisWeek    = "this week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        today       = "today: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        noRecords   = "no records found",
        bankGoldDeposits   = "BANK GOLD DEPOSITS",
        bankGoldWithdrawals   = "BANK GOLD WITHDRAWALS",
    },
	fr =
    {
        member      = "Membre pour %s%i %s",
        deposits    = "Dépôts",
        withdrawals = "Retraits",
        total       = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (sur %i %s)",
        last        = "Dernier: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s depuis)",
        minute      = "minute",
        hour        = "heure",
        day         = "jour",
        last30Days  = "last 30 days: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        lastWeek    = "last week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        thisWeek    = "this week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        today       = "today: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        noRecords   = "no records found",
        bankGoldDeposits   = "BANK GOLD DEPOSITS",
        bankGoldWithdrawals   = "BANK GOLD WITHDRAWALS",
    },
    de =
    {
        member      = "Mitglied seit %s%i %s",
        deposits    = "Einzahlungen",
        withdrawals = "Auszahlungen",
        total       = "Gesamt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (innerhalb von %i %s)",
        last        = "Zuletzt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (vor %i %s)",
        minute      = "Minute",
        hour        = "Stunde",
        day         = "Tag",
        last30Days  = "last 30 days: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        lastWeek    = "last week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        thisWeek    = "this week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        today       = "today: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        noRecords   = "no records found",
        bankGoldDeposits   = "BANK GOLD DEPOSITS",
        bankGoldWithdrawals   = "BANK GOLD WITHDRAWALS",
    }
}

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function secToTime(seconds)
    local time = math.floor(seconds / 60)
    local str = langStrings[lang].minute

    if (time > 60) then
        time = math.floor(seconds / (60 * 60))

        if (time > 24) then
            time = math.floor(seconds / (60 * 60 * 24))

            str = langStrings[lang].day
        else
            str = langStrings[lang].hour
        end
    end

    if (time ~= 1) then
        if (lang == "en") then
            str = str .. 's'
        end

        if (lang == "de") then
            if (str == langStrings[lang].day) then
                str = str .. 'en'
            else
                str = str .. 'n'
            end
        end
    end

    return time, str
end

local function createTimeJoinedTooltipString(guildId, displayName, timeStamp)
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

local function createBankGoldDepositsTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""
    
    tooltip = tooltip .. "\n\n" .. langStrings[lang].bankGoldDeposits .. '\n'
    deposits = GuildToolsByFen.history[guildId][string.lower(displayName)].deposits
    
    if (deposits.last30Days == 0
        and deposits.lastWeek == 0
        and deposits.thisWeek == 0
        and deposits.today == 0
    ) then
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

local function createBankGoldWhidrawalsTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""

    tooltip = tooltip .. "\n\n" .. langStrings[lang].bankGoldWithdrawals .. '\n'
    withdrawals = GuildToolsByFen.history[guildId][string.lower(displayName)].withdrawals

    if (withdrawals.last30Days == 0 
        and withdrawals.lastWeek == 0 
        and withdrawals.thisWeek == 0
        and withdrawals.today == 0
    ) then
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

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
    org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)

    local parent = control:GetParent()
    local data = ZO_ScrollList_GetData(parent)
    local guildId = GUILD_SELECTOR.guildId
    local displayName = string.lower(data.displayName)
    local timeStamp = GetTimeStamp()

    local tooltip = data.characterName
    local num, str

    if (GuildToolsByFen.history[guildId] == nil) then return end

    tooltip = tooltip .. "\n\n"              
    
    if (GuildToolsByFen.history[guildId][string.lower(displayName)] == nil) then
        --  NO PLAYER RECORD FOUND
        num, str = secToTime(timeStamp - GuildToolsByFen.history[guildId].oldestEvent)
        tooltip = tooltip .. string.format(langStrings[lang].member, "> ", num, str)
        tooltip = tooltip .. "\n\n" .. langStrings[lang].bankGoldDeposits .. '\n'
        tooltip = tooltip .. langStrings[lang].noRecords
        tooltip = tooltip .. "\n\n" .. langStrings[lang].bankGoldWithdrawals .. '\n'
        tooltip = tooltip .. langStrings[lang].noRecords
    else
        tooltip = tooltip .. createTimeJoinedTooltipString(guildId, displayName, timeStamp)
        tooltip = tooltip .. createBankGoldDepositsTooltipString(guildId, displayName, timeStamp)
        tooltip = tooltip .. createBankGoldWhidrawalsTooltipString(guildId, displayName, timeStamp)
    end
     
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
    SetTooltipText(InformationTooltip, tooltip)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
    ClearTooltip(InformationTooltip)

    org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end

local function createGuild(guildId)
    if (GuildToolsByFen.history[guildId] ~= nil) then return end

    GuildToolsByFen.history[guildId] = {}
end

local function createUser(user, guildId)
    if (GuildToolsByFen.history[guildId][string.lower(user)] ~= nil) then return end  

    GuildToolsByFen.history[guildId][string.lower(user)] = {
        lastEvent = nil,
        timeJoined = nil,
        deposits = {
            last30Days = 0,
            lastWeek = 0,
            thisWeek = 0,
            today = 0
        },
        withdrawals = {
            last30Days = 0,
            lastWeek = 0,
            thisWeek = 0,
            today = 0
        }
    }
end

local function storeGuildJoins(guildId, user, eventTime)
    if(GuildToolsByFen.history[guildId][string.lower(user)].timeJoined ~= nil) then return end
    
    GuildToolsByFen.history[guildId][string.lower(user)].timeJoined = eventTime    
end

local function storeGuildBankGoldTransactions(guildId, user, gold, event, eventTime)  
    
    date = os.date("*t", eventTime)
    date.yWeek = os.date('%U', eventTime);
    date.tradeWeek = date.yWeek;
    today = os.date("*t")
    today.yWeek = os.date('%U', os.time());
    today.tradeWeek = today.yWeek;
    
    if(date.year ~= os.date('*t', os.time()).year) then return end
    if(eventTime < (os.time() - 60*60*24*30)) then return end
    
    -- last 30 days
    if(eventTime >= (os.time() - 60*60*24*30)) then 
        GuildToolsByFen.history[guildId][string.lower(user)][event].last30Days = gold + GuildToolsByFen.history[guildId][string.lower(user)][event].last30Days
    end

    -- checking event and today's trade week (trade weeks start tuesdays at 2:01pm)
    if(today.wday == 1 or (today.wday == 2 and today.hour < 14)) then
        today.tradeWeek = today.yWeek - 1
    end
    if(date.wday == 1 or (date.wday == 2 and date.hour < 14)) then
        date.tradeWeek = date.yWeek - 1
    end            

    -- last week
    if (date.tradeWeek == (today.tradeWeek - 1)) then
        GuildToolsByFen.history[guildId][string.lower(user)][event].lastWeek = gold + GuildToolsByFen.history[guildId][string.lower(user)][event].lastWeek
    end

    -- this week
    if (date.tradeWeek == today.tradeWeek) then
        GuildToolsByFen.history[guildId][string.lower(user)][event].thisWeek = gold + GuildToolsByFen.history[guildId][string.lower(user)][event].thisWeek
    end
    
    -- today
    if (date.day == today.day) then
        GuildToolsByFen.history[guildId][string.lower(user)][event].today = gold + GuildToolsByFen.history[guildId][string.lower(user)][event].today
    end
end

local function addInviteToGuildMenuItem(playerName, rawName)    
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

local function SetUpLibHistoireListener(guildId, category, startTime, endTime)
    local listener = LibHistoire:CreateGuildHistoryListener(guildId, category)    
    
    if(startTime ~= nil and endTime ~= nil) then
        listener:SetTimeFrame(startTime, endTime)
    end

    listener:SetEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)        
        createGuild(guildId)   
        createUser(param1, guildId) 


        if(eventType == GUILD_EVENT_GUILD_JOIN and category == GUILD_HISTORY_GENERAL) then              
            storeGuildJoins(guildId, param1, eventTime)
        end

        if(eventType == GUILD_EVENT_BANKGOLD_ADDED and category == GUILD_HISTORY_BANK) then                
            storeGuildBankGoldTransactions(guildId, param1, param2, 'deposits', eventTime)                          
        end

        if(eventType == GUILD_EVENT_BANKGOLD_REMOVED and category == GUILD_HISTORY_BANK) then
            storeGuildBankGoldTransactions(guildId, param1, param2, 'withdrawals', eventTime)                          
        end

        if(eventType == GUILD_EVENT_GUILD_JOIN and category == GUILD_HISTORY_GENERAL) then  
            if(GuildToolsByFen.history[guildId].oldestEvent == nil) then
                GuildToolsByFen.history[guildId].oldestEvent = eventTime                    
            end
        end
    end)
    listener:Start()
end

function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= name) then
        return
    end
    
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
    
    if(GuildToolsByFen == nil) then 
        GuildToolsByFen = {} 
        GuildToolsByFen.history = {} 
    end

    startTime = os.time() - 30*24*60*60
    endTime = os.time()

    for i = 1, GetNumGuilds() do
        SetUpLibHistoireListener(GetGuildId(i), GUILD_HISTORY_GENERAL)
        SetUpLibHistoireListener(GetGuildId(i), GUILD_HISTORY_BANK, startTime, endTime)
    end
end

LibCustomMenu:RegisterPlayerContextMenu(addInviteToGuildMenuItem)
EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)

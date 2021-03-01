-------------------------------------------------------------------------------
-- Guild Tools By Fen v0.3.4
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
local savedData = {
    history = {},    
}
local scanGuildIndex = nil
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit
local lang = 'en'
local langStrings =
{
    en =
    {
        member                       = "Member for %s%i %s",
        GUILD_EVENT_BANKGOLD_ADDED   = "Deposits",
        GUILD_EVENT_BANKGOLD_REMOVED = "Withdrawals",
        total                        = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (over %i %s)",
        last                         = "Last: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s ago)",
        minute                       = "minute",
        hour                         = "hour",
        day                          = "day",
        last30Days                       = "last 30 days: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        thisWeek                     = "this week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        today                        = "today: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
    },
	fr =
    {
        member                       = "Membre pour %s%i %s",
        GUILD_EVENT_BANKGOLD_ADDED   = "Dépôts",
        GUILD_EVENT_BANKGOLD_REMOVED = "Retraits",
        total                        = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (sur %i %s)",
        last                         = "Dernier: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s depuis)",
        minute                       = "minute",
        hour                         = "heure",
        day                          = "jour",
        last30Days                   = "last 30 days: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        thisWeek                     = "this week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        today                        = "today: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
    },
    de =
    {
        member                       = "Mitglied seit %s%i %s",
        GUILD_EVENT_BANKGOLD_ADDED   = "Einzahlungen",
        GUILD_EVENT_BANKGOLD_REMOVED = "Auszahlungen",
        total                        = "Gesamt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (innerhalb von %i %s)",
        last                         = "Zuletzt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (vor %i %s)",
        minute                       = "Minute",
        hour                         = "Stunde",
        day                          = "Tag",
        last30Days                   = "last 30 days: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        thisWeek                     = "this week: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        today                        = "today: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
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

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
    org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)

    local parent = control:GetParent()
    local data = ZO_ScrollList_GetData(parent)
    local guildId = GUILD_SELECTOR.guildId
    local displayName = string.lower(data.displayName)
    local timeStamp = GetTimeStamp()

    local tooltip = data.characterName
    local num, str

    if (savedData.history[guildId] == nil) then return end
    if (savedData.history[guildId][string.lower(displayName)] == nil) then return end

    -- time joined
    if (savedData.history[guildId][string.lower(displayName)].timeJoined) then
        tooltip = tooltip .. "\n\n"            
        num, str = secToTime(timeStamp - savedData.history[guildId][string.lower(displayName)].timeJoined)
        tooltip = tooltip .. string.format(langStrings[lang].member, "", num, str)
    end

    -- bank gold transactions
    if (savedData.history[guildId][string.lower(displayName)].deposits) then
        tooltip = tooltip .. "\n\n" .. 'BANK GOLD DEPOSITS' .. '\n'
        depositsLast30Days = savedData.history[guildId][string.lower(displayName)].deposits.last30Days
        tooltip = tooltip .. string.format(langStrings[lang].last30Days, depositsLast30Days)
        
        tooltip = tooltip .. "\n"           
        depositsThisWeek = savedData.history[guildId][string.lower(displayName)].deposits.thisWeek
        tooltip = tooltip .. string.format(langStrings[lang].thisWeek, depositsThisWeek)

        tooltip = tooltip .. "\n"           
        depositsToday = savedData.history[guildId][string.lower(displayName)].deposits.today
        tooltip = tooltip .. string.format(langStrings[lang].today, depositsToday)
    end

    if (savedData.history[guildId][string.lower(displayName)].withdrawals) then
       tooltip = tooltip .. "\n\n" .. 'BANK GOLD WITHDRAWALS' .. '\n'
        withdrawalsLast30Days = savedData.history[guildId][string.lower(displayName)].withdrawals.last30Days
        tooltip = tooltip .. string.format(langStrings[lang].last30Days, withdrawalsLast30Days)
        
        tooltip = tooltip .. "\n"           
        withdrawalsThisWeek = savedData.history[guildId][string.lower(displayName)].withdrawals.thisWeek
        tooltip = tooltip .. string.format(langStrings[lang].thisWeek, withdrawalsThisWeek)

        tooltip = tooltip .. "\n"           
        withdrawalsToday = savedData.history[guildId][string.lower(displayName)].withdrawals.today
        tooltip = tooltip .. string.format(langStrings[lang].today, withdrawalsToday)
    end
      
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
    SetTooltipText(InformationTooltip, tooltip)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
    ClearTooltip(InformationTooltip)

    org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end

local function createGuild(guildId)
    if (savedData.history[guildId] == nil) then
        savedData.history[guildId] = {}
    end 
end

local function createUser(user, guildId)
    if (savedData.history[guildId][string.lower(user)] == nil) then  
        savedData.history[guildId][string.lower(user)] = {
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
end

local function storeGuildJoins(guildId, user, eventTime)
    createGuild(guildId)   
    createUser(user, guildId)

    savedData.history[guildId][string.lower(user)].timeJoined = eventTime    
end

local function storeGuildBankGoldTransactions(guildId, user, gold, event, eventTime)  
    createGuild(guildId)   
    createUser(user, guildId)
    date = os.date("*t", eventTime)
    date.yWeek = os.date('%u', eventTime);
    date.tradeWeek = date.yWeek;
    today = os.date("*t")
    today.yWeek = os.date('%u', os.time());
    today.tradeWeek = today.yWeek;
    
    if(date.year ~= os.date('*t', os.time()).year) then return end
    if(eventTime < (os.time() - 60*60*24*30)) then return end
    
    -- last 30 days
    if(eventTime >= (os.time() - 60*60*24*30)) then 
        savedData.history[guildId][string.lower(user)][event].last30Days = gold + savedData.history[guildId][string.lower(user)][event].last30Days
    end

    -- checking event ocurred and today's trade week that starts tuesdays at 2:01pm
    if(today.wday == 1 or (today.wday == 2 and today.hour < 14)) then
        today.tradeWeek = today.yWeek - 1
    end
    if(date.wday == 1 or (date.wday == 2 and date.hour < 14)) then
        date.tradeWeek = date.yWeek - 1
    end        
    if (date.tradeWeek == today.tradeWeek) then
        savedData.history[guildId][string.lower(user)][event].thisWeek = gold + savedData.history[guildId][string.lower(user)][event].thisWeek
    end

    -- last week
    if (date.tradeWeek == (today.tradeWeek - 1)) then
        savedData.history[guildId][string.lower(user)][event].lastWeek = gold + savedData.history[guildId][string.lower(user)][event].lastWeek
    end

    -- this week
    if (date.tradeWeek == today.tradeWeek) then
        savedData.history[guildId][string.lower(user)][event].thisWeek = gold + savedData.history[guildId][string.lower(user)][event].thisWeek
    end
    
    -- today
    if (date.day == today.day) then
        savedData.history[guildId][string.lower(user)][event].today = gold + savedData.history[guildId][string.lower(user)][event].today
    end
end

LibHistoire:RegisterCallback(LibHistoire.callback.INITIALIZED, function()
    local function SetUpListener(guildId, category)
        local listener = LibHistoire:CreateGuildHistoryListener(guildId, category)
        listener:SetEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)            
           
            if(eventType == GUILD_EVENT_GUILD_JOIN and category == GUILD_HISTORY_GENERAL) then
                storeGuildJoins(guildId, param1, eventTime)
            end
            if(eventType == GUILD_EVENT_BANKGOLD_ADDED and category == GUILD_HISTORY_BANK) then                
                storeGuildBankGoldTransactions(guildId, param1, param2, 'deposits', eventTime)                          
            end
            if(eventType == GUILD_EVENT_BANKGOLD_REMOVED and category == GUILD_HISTORY_BANK) then
                storeGuildBankGoldTransactions(guildId, param1, param2, 'withdrawals', eventTime)                          
            end
        end)
        listener:Start()
    end

    for i = 1, GetNumGuilds() do
        SetUpListener(GetGuildId(i), GUILD_HISTORY_GENERAL)
        SetUpListener(GetGuildId(i), GUILD_HISTORY_BANK)
    end
end)

function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= name) then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
    -- savedData = ZO_SavedVars:NewAccountWide(name, nil, nil, savedData)
    
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)


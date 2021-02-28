-------------------------------------------------------------------------------
-- Guild Tools By Fen v0.2.0
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
        member      = "Member for %s%i %s",
        deposits    = "Deposits",
        withdrawals = "Withdrawals",
        total       = "Total tax: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        -- total       = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (over %i %s)",
        last        = "Last: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s ago)",
        minute      = "minute",
        hour        = "hour",
        day         = "day"
    },
	fr =
    {
        member      = "Membre pour %s%i %s",
        deposits    = "Dépôts",
        withdrawals = "Retraits",
        total       = "Total tax: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        -- total       = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (sur %i %s)",
        last        = "Dernier: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s depuis)",
        minute      = "minute",
        hour        = "heure",
        day         = "jour"
    },
    de =
    {
        member      = "Mitglied seit %s%i %s",
        deposits    = "Einzahlungen",
        withdrawals = "Auszahlungen",
        total       = "Gesamt tax: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t",
        -- total       = "Gesamt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (innerhalb von %i %s)",
        last        = "Zuletzt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (vor %i %s)",
        minute      = "Minute",
        hour        = "Stunde",
        day         = "Tag"
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

    if (savedData.history[guildId][string.lower(displayName)].timeJoined) then
        tooltip = tooltip .. "\n\n"            
        num, str = secToTime(timeStamp - savedData.history[guildId][string.lower(displayName)].timeJoined)
        tooltip = tooltip .. string.format(langStrings[lang].member, "", num, str)
    end

    if (savedData.history[guildId][string.lower(displayName)].deposits) then
        tooltip = tooltip .. "\n\n"    
        deposits = savedData.history[guildId][string.lower(displayName)].deposits
        tooltip = tooltip .. langStrings[lang].deposits .. ": " .. deposits .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
    end

    if (savedData.history[guildId][string.lower(displayName)].withdrawals) then
        tooltip = tooltip .. "\n"    
        withdrawals = savedData.history[guildId][string.lower(displayName)].withdrawals
        tooltip = tooltip .. langStrings[lang].withdrawals .. ": " .. withdrawals .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
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
        savedData.history[guildId][string.lower(user)] = {}
    end
end

local function storeGuildJoins(guildId, user, eventTime)
    createGuild(guildId)   
    createUser(user, guildId)

    savedData.history[guildId][string.lower(user)].timeJoined = eventTime    
end

local function storeGuildGoldDeposit(guildId, user, gold, eventTime)  
    createGuild(guildId)   
    createUser(user, guildId)

    if (savedData.history[guildId][string.lower(user)].deposits == 0 or savedData.history[guildId][string.lower(user)].deposits == nil) then
        savedData.history[guildId][string.lower(user)].deposits = gold
    else
        savedData.history[guildId][string.lower(user)].deposits = gold + savedData.history[guildId][string.lower(user)].deposits
    end
end

local function storeGuildGoldWithdrawal(guildId, user, gold, eventTime)  
    createGuild(guildId)   
    createUser(user, guildId)

    if (savedData.history[guildId][string.lower(user)].withdrawals == 0 or savedData.history[guildId][string.lower(user)].withdrawals == nil) then
        savedData.history[guildId][string.lower(user)].withdrawals = gold
    else
        savedData.history[guildId][string.lower(user)].withdrawals = gold + savedData.history[guildId][string.lower(user)].withdrawals
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
                -- if(guildId == 361) then
                --     d(eventType .." ".. eventId .." ".. eventTime .." ".. (param1 or "-") .." ".. (param2 or "-") .." ".. (param3 or "-") .." ".. (param4 or "-") .." ".. (param5 or "-") .." ".. (param6 or "-"))
                -- end
                storeGuildGoldDeposit(guildId, param1, param2, eventTime)                          
            end
            if(eventType == GUILD_EVENT_BANKGOLD_REMOVED and category == GUILD_HISTORY_BANK) then
                storeGuildGoldWithdrawal(guildId, param1, param2, eventTime)                          
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

    savedData = ZO_SavedVars:NewAccountWide(name, nil, nil, savedData)
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)


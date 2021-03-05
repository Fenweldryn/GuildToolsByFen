-------------------------------------------------------------------------------
-- Guild Tools By Fen v0.7.0
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

local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang
local BankGoldTransactions = GuildToolsByFenInternals.BankGoldTransactions
local TimeJoined = GuildToolsByFenInternals.TimeJoined
local GuildInvite = GuildToolsByFenInternals.GuildInvite
local SettingsMenu = GuildToolsByFenInternals.SettingsMenu
local SlashCommands = GuildToolsByFenInternals.SlashCommands

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
    -- org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
    
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
        tooltip = tooltip .. TimeJoined.createTooltipString(guildId, displayName, timeStamp)
        tooltip = tooltip .. GuildToolsByFenInternals.BankGoldTransactions.createDepositsTooltipString(guildId, displayName, timeStamp)
        tooltip = tooltip .. GuildToolsByFenInternals.BankGoldTransactions.createWhidrawalsTooltipString(guildId, displayName, timeStamp)
    end
    
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
    SetTooltipText(InformationTooltip, tooltip)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
    
    -- org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end

local function SetUpLibHistoireListener(guildId, category, startTime, endTime)
    local listener = LibHistoire:CreateGuildHistoryListener(guildId, category)    
    
    if(startTime ~= nil and endTime ~= nil) then
        listener:SetTimeFrame(startTime, endTime)
    end
    
    listener:SetEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)        
        GuildToolsByFenInternals.createGuild(guildId)   
        GuildToolsByFenInternals.createUser(param1, guildId) 
        
        
        if(eventType == GUILD_EVENT_GUILD_JOIN and category == GUILD_HISTORY_GENERAL) then              
            TimeJoined.storeGuildJoins(guildId, param1, eventTime)
        end
        
        if(eventType == GUILD_EVENT_BANKGOLD_ADDED and category == GUILD_HISTORY_BANK) then                
            BankGoldTransactions.store(guildId, param1, param2, 'deposits', eventTime)                          
        end
        
        if(eventType == GUILD_EVENT_BANKGOLD_REMOVED and category == GUILD_HISTORY_BANK) then
            BankGoldTransactions.store(guildId, param1, param2, 'withdrawals', eventTime)                          
        end
        
        if(eventType == GUILD_EVENT_GUILD_JOIN and category == GUILD_HISTORY_GENERAL) then  
            if( GuildToolsByFen.history[guildId].oldestEvent == nil 
                or GuildToolsByFen.history[guildId].oldestEvent >= eventTime) then
                GuildToolsByFen.history[guildId].oldestEvent = eventTime                    
        end
    end
end)
listener:Start()
end

function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= GuildToolsByFenInternals.name) then
        return
    end
    
    EVENT_MANAGER:UnregisterForEvent(GuildToolsByFenInternals.name, EVENT_ADD_ON_LOADED)
    SettingsMenu.InitAddonMenu()    
    
    startTime = os.time() - 30*24*60*60
    endTime = os.time()
    
    for i = 1, GetNumGuilds() do
        SetUpLibHistoireListener(GetGuildId(i), GUILD_HISTORY_GENERAL)
        BankGoldTransactions.resetUserTransactions(GetGuildId(i))
        SetUpLibHistoireListener(GetGuildId(i), GUILD_HISTORY_BANK, startTime, endTime)
    end
end

EVENT_MANAGER:RegisterForEvent(GuildToolsByFenInternals.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)

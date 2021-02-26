-------------------------------------------------------------------------------
-- Guild Tools By Fen v0.1.2
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
local history = {}
local scanGuildIndex = nil
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit
local lang = 'en'
local langStrings =
{
    en =
    {
        member      = "Member for %s%i %s",
        depositions = "Deposits",
        withdrawals = "Withdrawals",
        total       = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (over %i %s)",
        last        = "Last: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s ago)",
        minute      = "minute",
        hour        = "hour",
        day         = "day"
    },
	fr =
    {
        member      = "Membre pour %s%i %s",
        depositions = "Dépôts",
        withdrawals = "Retraits",
        total       = "Total: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (sur %i %s)",
        last        = "Dernier: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (%i %s depuis)",
        minute      = "minute",
        hour        = "heure",
        day         = "jour"
    },
    de =
    {
        member      = "Mitglied seit %s%i %s",
        depositions = "Einzahlungen",
        withdrawals = "Auszahlungen",
        total       = "Gesamt: %i |t16:16:EsoUI/Art/currency/currency_gold.dds|t (innerhalb von %i %s)",
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

    if (history[guildId] ~= nil) then
        if (history[guildId].joined[string.lower(displayName)] ~= nil) then
            tooltip = tooltip .. "\n\n"            
            num, str = secToTime(timeStamp - history[guildId].joined[string.lower(displayName)].timeJoined)
            tooltip = tooltip .. string.format(langStrings[lang].member, "", num, str)
        end
    end
      
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
    SetTooltipText(InformationTooltip, tooltip)
end

function nt2_write(path, data, sep)
    sep = sep or ','
    local file = assert(io.open(path, "w"))
    file:write('Image ID' .. "," .. 'Caption')
    file:write('\n')
    for k, v in pairs(data) do
      file:write(v["image_id"] .. "," .. v["caption"])
      file:write('\n')
    end
    file:close()
end

LSC:Register(
    "/gtfexport", 
    function(input)
        d('export') 
    end, "Prints the specified text"
)

LibHistoire:RegisterCallback(LibHistoire.callback.INITIALIZED, function()
    local function SetUpListener(guildId, category)
        local listener = LibHistoire:CreateGuildHistoryListener(guildId, category)
        listener:SetEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)            
            if(eventType == 1) then
                if (history[guildId] == nil) then
                    history[guildId] = {}
                    history[guildId].joined = {}
                end 
                history[guildId].joined[string.lower(param2)] = {}
                history[guildId].joined[string.lower(param2)].timeJoined = eventTime            
            end
        end)
        listener:Start()
    end

    for i = 1, GetNumGuilds() do
        SetUpListener(GetGuildId(i), GUILD_HISTORY_GENERAL)
    end
end)

function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= name) then
        return
    end
end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)


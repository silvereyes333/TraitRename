local addon = {
    name = "Preposterous",
    version = "1.2.2",
    author = "|c99CCEFsilvereyes|r",
}
local defaults = {
    replacementText = { },
}

--[[ Opens the addon settings panel ]]
function addon.OpenSettingsPanel()
    local LAM2 = LibStub("LibAddonMenu-2.0")
    if not LAM2 then return end
    LAM2:OpenToPanel(addon.settingsPanel)
end
local function GetTraitStringId(traitIndex)
    local traitStringId = _G[zo_strformat("SI_ITEMTRAITTYPE<<1>>", traitIndex)]
    return traitStringId
end
--[[ Removes any ESO color code markers from the start and end of the given text. ]]
local function StripColorAndWhitespace(text)
    text = zo_strtrim(text)
    text = string.gsub(text, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]", "")
    text = string.gsub(text, "|r", "")
    return text
end
local function PostProcess(value)
    value = StripColorAndWhitespace(value)
    return ZO_ColorDef:New("ff77dd"):Colorize(value)
end
function addon.OverrideTraitText(traitIndex, value)
    local traitStringId = GetTraitStringId(traitIndex)
    if GetDate() == 20170401 and not addon.settings.nofun then
        value = PostProcess(value)
    end
    SafeAddString(traitStringId, value, 1)
end
local function CreateTraitOption(optionsTable, traitIndex, gearCategoryStringId)
    local traitStringId = GetTraitStringId(traitIndex)
    local tooltip = zo_strformat(GetString(SI_PREPOSTEROUS_TEXT_TOOLTIP_FORMAT), 
                                 GetString(traitStringId),
                                 GetString(gearCategoryStringId))
    local traitOption = {
        type = "editbox",
        width = "full",
        name = GetString(traitStringId),
        tooltip = tooltip,
        isExtraWide = true,
        getFunc = function() return addon.settings.replacementText[traitIndex] end,
        setFunc = function(value)
            addon.settings.replacementText[traitIndex] = value
            addon.OverrideTraitText(traitIndex, value)
        end,
        default = defaults.replacementText[traitIndex],
    }
    
    table.insert(optionsTable, traitOption)
end
local function UpgradeSettings(settings)
    if addon.settings.dataVersion and addon.settings.dataVersion > 2 then
        return
    end
    
    -- Bugfix in data upgrade code for data version 2
    if addon.settings.dataVersion == 2 and type(addon.settings.replacementText) == "table" 
       and addon.settings.replacementText[17] and type(addon.settings.replacementText[17]) == "table"
    then
        addon.settings.dataVersion = 3
        addon.settings.replacementText[17] = addon.settings.replacementText[17][17]
        return
    end
    
    -- Upgrade code from data version 1 to 3
    addon.settings.dataVersion = 3
    if type(settings.replacementText) == "string" then
        local prosperousReplacementText = settings.replacementText
        settings.replacementText = {}
        for traitIndex = 0, 26 do
            settings.replacementText[traitIndex] = defaults.replacementText[traitIndex]
        end
        settings.replacementText[17] = prosperousReplacementText
   end
end
local function InitialOverride()
    -- Perform the initial override
    for traitIndex = 0, 26 do
        local traitStringId = GetTraitStringId(traitIndex)
        SafeAddVersion(traitStringId, 1)
        local traitText = addon.settings.replacementText[traitIndex]
        addon.OverrideTraitText(traitIndex, traitText)
    end
end
function addon.Refresh()
    InitialOverride()
end
local isMasterWritQuest
local function OnQuestOffered(eventCode)
    local questInfo = GetOfferedQuestInfo()
    -- Restore original trait names before accepting a Master Writ quest
    if string.match(questInfo, "Rolis Hlaalu") then
        isMasterWritQuest = true
        for traitIndex = 0, 26 do
            local traitStringId = GetTraitStringId(traitIndex)
            SafeAddString(traitStringId, defaults.replacementText[traitIndex], 1)
        end
    end
end
local function OnChatterEnd(eventCode)
    -- Reapply custom trait names after a Master Writ dialog closes
    if isMasterWritQuest then
        isMasterWritQuest = nil
        InitialOverride()
    end
end
local function SlashCommand(argument)
    if not argument or argument == "settings" then
        addon.OpenSettingsPanel()
        
    elseif argument == "refresh" or argument == "reload" then
        addon.Refresh()
        
    elseif argument == "fun" then
        addon.settings.nofun = nil
        addon.Refresh()
        
    elseif argument == "nofun" then
        addon.settings.nofun = true
        addon.Refresh()
        
    end
end
local function OnAddonLoaded(event, name)
    if name ~= addon.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    
    -- Default to base game trait names
    for traitIndex = 0, 26 do
        defaults.replacementText[traitIndex] = GetString(GetTraitStringId(traitIndex))
    end

    -- Initialize saved variable
    addon.settings = ZO_SavedVars:NewAccountWide("Preposterous_Data", 1, nil, defaults)
    
    -- Upgrade to version 2 settings
    UpgradeSettings(addon.settings)

    local LAM2 = LibStub("LibAddonMenu-2.0")
    if not LAM2 then return end

    local panelData = {
        type = "panel",
        name = addon.name,
        displayName = addon.name,
        author = addon.author,
        version = addon.version,
        --website = "http://www.esoui.com/downloads/<TBD>.html",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    addon.settingsPanel = LAM2:RegisterAddonPanel(addon.name .. "Options", panelData)

    local optionsTable = {

        -- Armor Trait
        {
            type = "header",
            width = "full",
            name = GetString(SI_ITEMTYPE45),
        }
    }
    for traitIndex=11,20 do
        CreateTraitOption(optionsTable, traitIndex, SI_SPECIALIZEDITEMTYPE300)
    end
    CreateTraitOption(optionsTable, 25)

    table.insert(optionsTable,
    
        -- Weapon Trait
        {
            type = "header",
            width = "full",
            name = GetString(SI_ITEMTYPE46),
        }
    )
    
    for traitIndex=1,10 do
        CreateTraitOption(optionsTable, traitIndex, SI_SPECIALIZEDITEMTYPE250)
    end
    CreateTraitOption(optionsTable, 26)
    
    
    table.insert(optionsTable,
    
        -- Jewelry
        {
            type = "header",
            width = "full",
            name = GetString(SI_GAMEPADITEMCATEGORY38),
        }
    )
    for traitIndex=21,24 do
        CreateTraitOption(optionsTable, traitIndex, SI_GAMEPADITEMCATEGORY38)
    end

    LAM2:RegisterOptionControls(addon.name .. "Options", optionsTable)
    
    InitialOverride()

    SLASH_COMMANDS["/ptrait"]       = SlashCommand
    SLASH_COMMANDS["/preposterous"] = SlashCommand
end
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_QUEST_OFFERED, OnQuestOffered)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CHATTER_END, OnChatterEnd)

   

Preposterous = addon

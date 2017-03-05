local addon = {
    name = "Preposterous",
    version = "1.1.1",
    author = "|c99CCEFsilvereyes|r",
}
local defaults = {
    replacementText = { [17] = "Effing Preposterous" },
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
function addon.OverrideTraitText(traitIndex, value)
    local traitStringId = GetTraitStringId(traitIndex)
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
local function OnAddonLoaded(event, name)
    if name ~= addon.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    
    -- Default to base game trait names
    for traitIndex = 0, 26 do
        if not defaults.replacementText[traitIndex] then
            defaults.replacementText[traitIndex] = GetString(GetTraitStringId(traitIndex))
        end
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
    
    -- Perform the initial override
    for traitIndex = 0, 26 do
        local traitStringId = GetTraitStringId(traitIndex)
        SafeAddVersion(traitStringId, 1)
        local traitText = addon.settings.replacementText[traitIndex]
        addon.OverrideTraitText(traitIndex, traitText)
    end

    SLASH_COMMANDS["/preposterous"] = addon.OpenSettingsPanel
end
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

Preposterous = addon

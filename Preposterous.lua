local addon = {
    name = "Preposterous",
    version = "1.0.0",
    author = "|c99CCEFsilvereyes|r",
}
local defaults = {
    replacementText = "Effing Preposterous",
}

--[[ Opens the addon settings panel ]]
function addon.OpenSettingsPanel()
    local LAM2 = LibStub("LibAddonMenu-2.0")
    if not LAM2 then return end
    LAM2:OpenToPanel(addon.settingsPanel)
end
function addon.OverrideProsperous(value)
    SafeAddString(SI_ITEMTRAITTYPE17, value, 1)
end
local function OnAddonLoaded(event, name)
    if name ~= addon.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    -- Initialize saved variable
    addon.settings = ZO_SavedVars:NewAccountWide("Preposterous_Data", 1, nil, defaults)
    addon.OverrideProsperous(addon.settings.replacementText)

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

            -- Replacement text option
            {
                type = "editbox",
                width = "full",
                isExtraWide = true,
                name = GetString(SI_PREPOSTEROUS_TEXT_LABEL),
                tooltip = GetString(SI_PREPOSTEROUS_TEXT_TOOLTIP),
                getFunc = function() return addon.settings.replacementText end,
                setFunc = function(value)
                    addon.settings.replacementText = value
                    addon.OverrideProsperous(value)
                end,
            }
    }

    LAM2:RegisterOptionControls(addon.name .. "Options", optionsTable)

    SLASH_COMMANDS["/preposterous"] = addon.OpenSettingsPanel
end
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

Preposterous = addon

-- Japanese strings TBD
local strings = {
    ["SI_PREPOSTEROUS_TEXT_LABEL"]   = "Prosperous Trait Name Replacement", 
    ["SI_PREPOSTEROUS_TEXT_TOOLTIP"] = "All references to the item trait 'Prosperous' will be replaced with this custom text.",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    PREPOSTEROUS_STRINGS[stringId] = value
end
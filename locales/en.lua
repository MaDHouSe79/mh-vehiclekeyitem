--[[ ===================================================== ]]--
--[[         MH Vehicle Key Item Script by MaDHouSe        ]]--
--[[ ===================================================== ]]--

local Translations = {
    error = {
        ['not_have_the_right_key'] = "You don\'t have the right key for the %{model}",
    },
    info = {
        ['you_can_use_the_key'] = "You can now use this key for the %{model}",
        ['engine_on'] = "Engine on",
        ['engine_off'] = "Engine off",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
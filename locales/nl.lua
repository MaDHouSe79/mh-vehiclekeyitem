--[[ ===================================================== ]]--
--[[         MH Vehicle Key Item Script by MaDHouSe        ]]--
--[[ ===================================================== ]]--

local Translations = {
    error = {
        ['not_enough_money'] = 'Je hebt niet genoeg geld!',
    },
    info = {
        ['you_can_use_the_key'] = "Je kunt deze sleutel nu voor de %{model} gebruiken.",
        ['engine_on'] = "Moter staat aan",
        ['engine_off'] = "Motor is uit",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
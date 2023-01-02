--[[ ===================================================== ]]--
--[[         MH Vehicle Key Item Script by MaDHouSe        ]]--
--[[ ===================================================== ]]--

fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe'
version '1.0'
description 'MH Vehicle Key Item - The best vehicle key item for QBCore Framework'

shared_scripts {
	'@qb-core/shared/locale.lua',
    'locales/nl.lua', -- Change this to your preferred language
	'config.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

lua54 'yes'

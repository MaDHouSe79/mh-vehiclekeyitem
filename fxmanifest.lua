fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe79'
description 'MH Vehiclekey Item - onw of the best vehicle key item for QBCore.'
version '1.0.0'
lua54 'yes'

client_script {
    'client/main.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'shared/vehicles.lua',
    'server/sv_config.lua',
    'server/main.lua',
    'server/update.lua',
}

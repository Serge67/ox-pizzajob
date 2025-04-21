fx_version 'cerulean'
game 'gta5'

author '53RG3'
description 'Pizza Delivery Job'--créé de toute pièce avec l'aide de l'IA
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_society',
    'ox_target'
}
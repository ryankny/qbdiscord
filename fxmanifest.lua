fx_version 'cerulean'
game 'gta5'

author 'Hydra Labs'
description 'Discord Role-Based Job Assignment for QBCore'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'qb-core'
}

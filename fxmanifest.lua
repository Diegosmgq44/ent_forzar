fx_version 'cerulean'
game 'gta5'

version '2.7.1'
description 'https://github.com/Diegosmgq44/ent_forzar'

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/fr.lua',
    'client/esx.lua',
    'client/main.lua',
}

shared_script 'config.lua'

server_scripts {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'locales/en.lua',
    'locales/fr.lua',
    'server.lua',
}

ui_page {
    'html/alerts.html',
}

files {
	'html/alerts.html',
	'html/main.js', 
	'html/style.css',
}

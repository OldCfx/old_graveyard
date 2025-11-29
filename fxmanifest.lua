fx_version 'cerulean'
game 'gta5'

name "old_graveyard"
description "graveyard creator"
author "OldMoney"
version "1.0.0"

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

files {
	'shared/data.json'
}

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'HRNPCDialogue'
author 'HRScripts Development'
description 'NPC dialogue system with custom design made by HRScripts Development'
repository 'https://github.com/HRScripts/HRNPCDialogue'
version '1.0.0'

shared_script '@HRLib/import.lua'

client_script 'client.lua'

files {
    'web/*.*',
    'config.lua'
}

ui_page 'web/index.html'
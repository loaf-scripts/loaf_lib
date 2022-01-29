fx_version "cerulean"
game "gta5"

version "1.0.1"

client_scripts {
    "client/*.lua",
    "client/functions/*.lua"
}
server_scripts {
    "server/*.lua",
    "server/functions/*.lua"
}
shared_script "shared/*.lua"

files {
    "client/html/*.html",
    "client/html/*.js"
}
ui_page "client/html/index.html"
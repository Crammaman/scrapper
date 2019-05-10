# Capistrano is perhaps a bit excessive for a one machine deploy
server "192.168.1.32", user: "scrapper", roles: %w{ app db }

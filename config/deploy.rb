# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "scrapper"
set :repo_url, "git@github.com:Crammaman/scrapper.git"

set :deploy_to, "/srv/scrapper"

set :user, "scrapper"

append :linked_files, ".env"
append :linked_files, ".secrets.yaml"

# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "scrapper"
set :repo_url, "git@github.com:Crammaman/scrapper.git"

set :deploy_to, "/srv/scrapper"

set :user, "scrapper"

append :linked_files, ".env"
append :linked_files, ".secrets.yml"

# Environment variables are set by dotenv when scrapper is run so when ever does
# not have to have the environment variables handed to it as they will be loaded
# at run time anyways.
set :whenever_command_environment_variables, ->{ fetch(:default_env) }

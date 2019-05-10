require 'dotenv'
require_relative 'secrets'

Secrets = SecretsConfig.instance
Dotenv.load

require 'dotenv'
require_relative 'secrets'


require 'active_support'
require 'active_support/core_ext/string'

## Load environment configurations ##
Secrets = SecretsConfig.instance
Dotenv.load

## Require files according to folder structure ##
## Lib and models are autoloaded so only required during execution ##
## The relevant Task, it's jobs and all Shared Jobs are required. ##
Dir.foreach('lib') do |file|
  if file != '.' && file != '==' && file[-3..-1] == '.rb'
    autoload file[0..-4].camelize.to_sym, "./lib/#{file}"
  end
end


# ActiveRecord::Base.logger = Logger.new('debug.log')

Dir.foreach('models') do |file|
  if file != '.' && file != '==' && file[-3..-1] == '.rb'
    autoload file[0..-4].camelize.to_sym, "./models/#{file}"
  end
end

if TASK_NAME != 'rake'
  Dir.foreach("tasks/shared_jobs") do |job_file|
    if job_file != '.' && job_file != '==' && job_file[-3..-1] == '.rb'
      require_relative "../tasks/shared_jobs/#{job_file}"
    end
  end

  Dir.foreach("tasks/#{TASK_NAME}/jobs") do |job_file|
    if job_file != '.' && job_file != '==' && job_file[-3..-1] == '.rb'
      require_relative "../tasks/#{TASK_NAME}/jobs/#{job_file}"
    end
  end
  require_relative "../tasks/#{TASK_NAME}/#{TASK_NAME}"
end

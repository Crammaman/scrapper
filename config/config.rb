require 'dotenv'
require_relative 'secrets'

require 'active_support'
require 'active_support/core_ext/string'

Secrets = SecretsConfig.instance
Dotenv.load

Dir.foreach('lib') do |file|
  if file != '.' && file != '==' && file[-3..-1] == '.rb'
    autoload file[0..-4].camelize.to_sym, "./lib/#{file}"
  end
end

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

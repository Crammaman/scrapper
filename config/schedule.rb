# Use this file to easily define all of your cron jobs.

job_type :run_task,  "cd :path && bundle exec script/:task :output"
every :day, at: '4:00 am' do
  run_task 'scrapper'
end

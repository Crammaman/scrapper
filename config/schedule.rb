# Use this file to easily define all of your cron jobs.

job_type :scrapper,  "cd :path && bundle exec ./scrapper :task :output"
every :day, at: '4:00 am' do
  scrapper 'courierpost_tracking 252'
end

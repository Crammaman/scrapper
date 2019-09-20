# Use this file to easily define all of your cron jobs.

job_type :scrapper,  "cd :path && bundle exec ./scrapper :task :output"
every :day, at: '1:00 am' do
  scrapper 'courierpost_tracking 252'
end

every :day, at: '2:00 am' do
  scrapper 'export_to_domo'
end

# every :day, at: '6:00 pm' do
#   scrapper 'bhp_blackwoods_references'
# end

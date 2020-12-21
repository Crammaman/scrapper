# Use this file to easily define all of your cron jobs.

job_type :scrapper,  "cd :path && bundle exec ./scrapper :task :output"
every :day, at: '2:00 am' do
  scrapper 'export_to_domo'
end

every 1.month, :at => 'December 22nd 2:00am' do
  scrapper 'update_signatures'
end
# every :day, at: '6:00 pm' do
#   scrapper 'bhp_blackwoods_references'
# end

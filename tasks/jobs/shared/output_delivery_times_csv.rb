require 'fileutils'
require 'csv'
class OutputDeliveryDatesCsvSharedJob < Job
  def initialize args
    @consignments = args[:consignments]
    @task_name = args[:task_name]
  end

  def perform
    FileUtils.mkdir_p "output/#{@task_name}"
    CSV.open( "output/#{@task_name}/#{@task_name}_delivery_dates.csv", 'wb') do |csv|
      csv << ['consignment_number', 'delivery_date']
      @consignments.each do |consignment|
        csv << [ consignment[:consignment_number], consignment[:actual_delivery_date] ]
      end
    end
  end
end

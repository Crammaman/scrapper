require 'csv'
class UploadDeliveryDatesCsvSharedJob < Job
  def initialize args
    @task_name = args[:task_name]
  end

  def perform
    myfreight_ftp_upload "output/#{@task_name}/#{@task_name}_delivery_dates.csv"
  end
end

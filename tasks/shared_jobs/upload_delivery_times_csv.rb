require 'csv'
class UploadDeliveryDatesCsvSharedJob < Job

  def perform
    Myfreight.ftp_upload "output/#{task_name}/#{task_name}_delivery_dates.csv"
  end
end

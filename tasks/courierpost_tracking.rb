require_relative 'jobs/courierpost_tracking/jobs'

class CourierpostTracking < Task
  def initialize args
    @customer_id = args[:customer_id]
    super()
  end

  def run
    # Consignments are [ { :id, :consignment_number } ]
    consignments = GetConsignmentListJob.perform_now @customer_id

    status_jobs = JobSet.new AddStateToConsignmentJob, consignments
    consignments = status_jobs.perform_in_batches_of 20

    # consignments.reject! { |consignment| consignment[:state] != 'despatched' }

    tracking_url_jobs = JobSet.new AddTrackingUrlToConsignmentJob, consignments
    consignments = tracking_url_jobs.perform_in_batches_of 20

    courierpost_tracking_jobs = JobSet.new AddCourierpostTrackingToConsignmentJob, consignments
    consignments = courierpost_tracking_jobs.perform_in_batches_of 20

    OutputDeliveryDatesCsvSharedJob.perform_now consignments: consignments, task_name: 'courierpost_tracking'
    UploadDeliveryDatesCsvSharedJob.perform_now task_name: 'courierpost_tracking'
  end
end

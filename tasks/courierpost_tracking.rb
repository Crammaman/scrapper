require_relative 'jobs/courierpost_tracking/jobs'

class CourierpostTracking < Task
  def initialize args
    @customer_id = args[:customer_id]
    super()
  end

  def run
    # Consignments are [ { :id, :consignment_number } ]
    raise 'No customer id provided' if @customer_id.nil?
    consignments = GetConsignmentListJob.perform_now @customer_id

    consignments = consignments.map{|consignment| consignment.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}}

    consignments = JobSet.perform_now_in_batches_of 20, AddStateToConsignmentJob, consignments
    consignments.reject! { |consignment| consignment[:state] != 'despatched' }

    consignments = JobSet.perform_now_in_batches_of 20, AddTrackingUrlToConsignmentJob, consignments

    consignments = JobSet.perform_now_in_batches_of 20, AddCourierpostTrackingToConsignmentJob, consignments

    OutputDeliveryDatesCsvSharedJob.perform_now consignments: consignments, task_name: 'courierpost_tracking'
    UploadDeliveryDatesCsvSharedJob.perform_now task_name: 'courierpost_tracking'
  end
end

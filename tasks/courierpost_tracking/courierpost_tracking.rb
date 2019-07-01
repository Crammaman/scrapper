class CourierpostTracking < Task
  def initialize args

    raise 'No customer id provided' unless args[:customer_id]
    @customer_id = args[:customer_id]

  end

  def run
    consignments = GetConsignmentListJob.perform_now @customer_id
    # consignments = JobSet.perform_now_in_batches_of 20, ConsignmentIdFromConsignmentNumberSharedJob, CSV.read( 'file_name', headers: :first_row).map{|row| row['consignment_number']}

    consignments = consignments.map{|consignment| consignment.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}}

    consignments = JobSet.perform_now_in_batches_of 20, AddTrackingUrlAndStateToConsignmentJob, consignments[0..10]
    consignments.reject! { |consignment| consignment[:state] != 'despatched' }

    # consignments = JobSet.perform_now_in_batches_of 20, AddTrackingUrlToConsignmentJob, consignments

    consignments = JobSet.perform_now_in_batches_of 20, AddCourierpostTrackingToConsignmentJob, consignments

    OutputDeliveryDatesCsvSharedJob.perform_now consignments: consignments
    UploadDeliveryDatesCsvSharedJob.perform_now
  end
end

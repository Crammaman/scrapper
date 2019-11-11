require 'csv'

class GetConsignmentsInfo < Task
  def initialize args
    @consignment_numbers = CSV.read(args[:consignment_numbers_path]).map(&:first)
  end
  
  def run
    summaries = JobSet.perform_now_in_batches_of 50, ConsignmentSummaryFromConsignmentNumberSharedJob, consignment_numbers
    consignment_ids = summaries.map { |summary| !summary[:summary].nil? ? summary[:summary]['id'] : nil }.compact
    consignments_info = JobSet.perform_now_in_batches_of 50, GetConsignmentInfo, consignment_ids
    OutputConsignmentsInfoJob.perform_now consignments_info
  end
  
  private
  attr :consignment_numbers
end
  
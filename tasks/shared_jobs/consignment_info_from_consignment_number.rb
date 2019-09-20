class ConsignmentInfoFromConsignmentNumberSharedJob < Job
  def initialize consignment_number
    @consignment_number = consignment_number
  end

  def perform
    search_result = Myfreight.consignment_search @consignment_number
    
    { info: search_result['consignments'][0], consignment_number: @consignment_number } if search_result['consignments'].length > 0
  end
end

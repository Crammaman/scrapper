class ConsignmentIdFromConsignmentNumberSharedJob < Job
  def initialize consignment_number
    @consignment_number = consignment_number
  end

  def perform
    search_result = myfreight_consignment_search @consignment_number

    { id: search_result['consignments'][0]['id'], consignment_number: @consignment_number }
  end
end

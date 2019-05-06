class ConsignmentInfoFromConsignmentNumberSharedJob < Job
  def initialize consignment_number
    @consignment_number = consignment_number
  end

  def perform
    search_result = myfreight_consignment_search @consignment_number

    myfreight_consignment_info search_result['consignments'][0]['id']
  end
end

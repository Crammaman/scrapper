class GetConsignmentInfo < Job
  def initialize consignment_id
    @consignment_id = consignment_id
  end
  
  def perform
    Myfreight.consignment consignment_id
  end
  
  private
  attr :consignment_id
end

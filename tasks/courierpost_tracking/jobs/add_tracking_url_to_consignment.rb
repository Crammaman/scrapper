class AddTrackingUrlToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    tracking = Myfreight.consignment_tracking @consignment[:id]

    @consignment[:tracking_url] = tracking['metadata']['web_url']

    @consignment
  end
end

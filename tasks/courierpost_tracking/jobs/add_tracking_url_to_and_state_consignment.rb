class AddTrackingUrlAndStateToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    consignment = Myfreight.consignment_info @consignment[:id]
    
    @consignment[:state] = consignment['state']
    
    @consignment[:tracking_url] = 'http://trackandtrace.courierpost.co.nz/Search/0049351459' + consignment['items'][0]['ssccs'].split(',')[0]

    @consignment
  end
end

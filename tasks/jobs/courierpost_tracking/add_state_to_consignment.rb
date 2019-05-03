class AddStateToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    consignment = myfreight_consignment @consignment[:id]

    @consignment[:state] = consignment['state']

    @consignment
  end
end

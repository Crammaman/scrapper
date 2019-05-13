class AddStateToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    consignment = Myfreight.consignment @consignment[:id]

    @consignment[:state] = consignment['state']

    @consignment
  end
end

class RequestPricingFromSsi < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    Ssi.quote @consignment
  end
end

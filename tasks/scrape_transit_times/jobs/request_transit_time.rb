class RequestTransitTimeJob < Job
  def initialize args
    @carrier = args[:carrier]
    @from_locality = args[:from_locality]
    @to_locality = args[:to_locality]
  end

  def perform
    days = case @carrier.code.downcase.to_sym
    when :tnt
      Tnt.transit_time @from_locality, @to_locality
    else
      raise "No transit time request for #{carrier.name}"
    end

    TransitTime.new from_locality: @from_locality, to_locality: @to_locality, carrier: @carrier, days: days
    
  end
end

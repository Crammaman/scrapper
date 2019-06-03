class SaveTransitTimesJob < Job
  def initialize args
    @transit_times = args[:transit_times]
  end

  def perform
    TransitTime.import @transit_times
  end
end

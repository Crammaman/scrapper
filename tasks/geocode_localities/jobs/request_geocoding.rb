class RequestGeocodingJob < Job

  def initialize locality
    @locality = locality
  end
  def perform
    coords = GoogleGeocoder.geocode(@locality)
    if coords.nil? || coords[:lat].nil?
      puts "Failed to geocode #{@locality}"
      @locality
    else
      @locality.merge({ 'Latitude' => coords[:lat], 'Longitude' => coords[:lng] })
    end
  end
end

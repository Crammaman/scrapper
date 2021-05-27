require 'csv'
class GeocodeLocalities < Task
  def initialize
    @localities = CSV.read("input/geocode_localities/NZ_nzpost.csv", headers: :first_row).map { |l| l.to_h.merge('Country' => 'New Zealand')}
  end

  def run
    geocode_requests = JobSet.new RequestGeocodingJob, @localities
    geocoding = geocode_requests.perform_in_batches_of 10

    CSV.open( 'output/geocode_localities/geocoded_localities.csv', 'wb') do |csv|
      csv << geocoding.first.keys
      geocoding.each do |row|
        csv << row.values
      end
    end
  end
end

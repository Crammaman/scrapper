class GoogleGeocoder
  require 'json'
  require 'net/http'

  def self.geocode locality
    address = locality.values.join(', ')
    response = Net::HTTP.get(URI("https://maps.googleapis.com/maps/api/geocode/json?#{URI.encode_www_form(key: Secrets.google_geocoding_api_key, address: address)}"))
    JSON.parse(response, symbolize_names: true)[:results].first&.dig(:geometry,:location)
  end
end
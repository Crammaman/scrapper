module Ssi
  require 'net/http'
  require 'json'
  def self.user
    { api_key: Secrets.ssi_api_key }
  end

  def self.quote consignment
    request '/apiext/api/v1/consignment', :post, { consignments: [ ssi_consignment(consignment) ] }
  end

  def self.request request_path, method, payload = {}, response_content_type = :json
    # puts("Sending #{ENV['MYFREIGHT_DOMAIN']}#{request_path}")
    uri = URI("#{ENV['SSI_DOMAIN']}#{request_path}")

    puts payload.to_json

    case method
    when :get
      req = Net::HTTP::Get.new(uri, 'api-key' => user[:api_key])

    when :post
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'api-key' => user[:api_key] )
      req.body = payload.to_json
    end

    http = Net::HTTP.new(uri.hostname, uri.port )
    http.use_ssl = true

    #TODO handle request failures
    begin
      response = http.request(req)
    rescue
      print "trying again                                                       \r"
      response = http.request(req)
    end

    JSON.parse response.body
  end

  def self.ssi_consignment consignment
    {
      RuleNamesToEvaluate: [
        "BUY_RATES_USING_ENTRIES",
        "BUY_RATES_USING_SINGLE_FORMULA",
        "BUY_RATES_USING_SAPHIRE_TABLE_LOOKUP"
      ],
      id: consignment[:id], #is int
      customer_code: consignment[:customer_code],
      site_code: consignment[:site_code],
      dispatch_date: consignment[:despatch_date],
      account_payable: consignment[:account_payable] || "sender",
      items: consignment[:items].map do |item|
        {
          dangerous_goods: item[:dangerous_goods] || false,
          height:   item[:height].to_i,
          item_type: item[:item_type],
          length:   item[:length].to_i,
          quantity: item[:quantity].to_i,
          weight_in_kilograms:   item[:weight].to_i,
          width:    item[:width].to_i
        }
      end,
      sender: {
        address_line_1: "1 Bellevue Circuit",
        address_line_2: nil,
        address_line_3: nil,
        address_line_4: nil,
        sublocality: nil,
        locality: "Greystanes",
        postcode: "2145",
        region: "NSW",
        country: "Australia"
      },
      receiver: {
        address_line_1: consignment[:receiver_address_line_1],
        address_line_2: nil,
        address_line_3: nil,
        address_line_4: nil,
        sublocality: nil,
        locality: consignment[:receiver_locality],
        postcode: consignment[:receiver_postcode],
        region: consignment[:receiver_region],
        country: "AUSTRALIA",
        phone: nil,
        email: nil
      },
      third_party: nil,
      return_consignment: false
    }
  end
end

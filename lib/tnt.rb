class Tnt
  require 'net/http'
  require 'xmlsimple'

  FROM_DATE = '2019-05-07'
  @@invalid_ids = {}

  def self.transit_time from_locality, to_locality

    return nil if @@invalid_ids[ from_locality[:id] ] == 'INVALID' || @@invalid_ids[ to_locality[:id] ] == 'INVALID'

    xml = XmlSimple.new
    uri = URI('https://www.tntexpress.com.au/Rtt/inputRequest.asp')

    res = {}
    begin
      Net::HTTP.start( uri.host, uri.port, use_ssl: true ) do |http|

        req = Net::HTTP::Post.new uri
        req.content_type = 'application/x-www-form-urlencoded '
        req.set_form_data(
          'username' => 'CIT00000000000116386',
          'password' => 'myfreight123',
          'version' => '2',
          'xmlRequest' => transit_time_request_xml( from_locality, to_locality )
        )

        res = http.request req
      end

    rescue
      puts 'Retrying'
      return transit_time from_locality, to_locality
    end
    tnt_response_data = xml.xml_in(res.body)

    if (['INVALID_SENDER','INVALID_RECEIVER','LOCAL_TIME_NO_GOOD'] & (locality_errors(tnt_response_data) || [])).any?
      @@invalid_ids[ from_locality[:id] ] = 'INVALID' if locality_errors(tnt_response_data).include?('INVALID_SENDER')
      @@invalid_ids[ to_locality[:id] ] = 'INVALID' if locality_errors(tnt_response_data).include?('INVALID_RECEIVER')
    end

    if extract_transits(tnt_response_data)
      (Date.parse(extract_transits(tnt_response_data)) - Date.parse(FROM_DATE))
    else
      nil
    end
  end

  def self.locality_errors tnt_response
    tnt_response['ratedTransitTimeResponse'].find{|rt| rt.keys.include?('brokenRules') }['brokenRules'][0]['brokenRule'].map do |br|

      case br['code'][0]
      when '590'
        'INVALID_SENDER'
      when '591'
        'INVALID_RECEIVER'
      when '352'
        'CANT_SEND_WITH_SERVICE'
      when '472'
        'LOCAL_TIME_NO_GOOD'
      when '475'
        'TIME_OVER_WEEKEND_OR_HOLIDAY' #Currently no provisioning for this error.
      else
        puts "Dunno what '#{br['description']}' means code: #{br['code'][0]}"
      end
    end
  rescue
    nil
  end

  def self.extract_transits tnt_transits
    tnt_transits["ratedTransitTimeResponse"].find{ |tt|
      tt.keys.include?('ratedProducts')
    }['ratedProducts'].find{ |rp|
        rp.keys.include?('ratedProduct')
    }['ratedProduct'].find{|product|
      product['product'][0]['code'] == ['76']
    }['estimatedDeliveryDateTime'][0]
  rescue
    nil
  end

  def self.transit_time_request_xml from, to
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <enquiry xmlns=\"http://www.tntexpress.com.au\">
      <ratedTransitTimeEnquiry>
        <cutOffTimeEnquiry>
          <collectionAddress>
            <suburb>#{from[:locality]}</suburb>
            <postCode>#{from[:postcode]}</postCode>
            <state>#{from[:region]}</state>
          </collectionAddress>
          <deliveryAddress>
            <suburb>#{to[:locality]}</suburb>
            <postCode>#{to[:postcode]}</postCode>
            <state>#{to[:region]}</state>
          </deliveryAddress>
          <shippingDate>#{FROM_DATE}</shippingDate>
          <userCurrentLocalDateTime>2019-03-25T16:28:00 </userCurrentLocalDateTime>
          <dangerousGoods>
            <dangerous>false</dangerous>
          </dangerousGoods>
          <packageLines packageType=\"D\">
            <packageLine>
              <numberOfPackages>1</numberOfPackages>
              <dimensions unit=\"cm\">
                <length>20</length>
                <width>20</width>
                <height>20</height>
              </dimensions>
              <weight unit=\"kg\">
                <weight>1</weight>
              </weight>
            </packageLine>
          </packageLines>
        </cutOffTimeEnquiry>
        <termsOfPayment>
          <senderAccount>21223607</senderAccount>
          <payer>S</payer>
        </termsOfPayment>
      </ratedTransitTimeEnquiry>
    </enquiry>"
  end
end

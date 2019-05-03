require 'nokogiri'
require 'net/http'
require 'net/ftp'
require 'json'
module Util
  MYFREIGHT_DOMAIN = 'https://qa.teamwilberforce.com'
  MYFREIGHT_FTP = 'ftp.qa.teamwilberforce.com'

  def myfreight_user
    { username: 'api@myfreightconsignments.com.au', token: '2x9x3uX5otje_irzDEkC' }
  end

  def myfreight_consignment id
    myfreight_request "/api/consignments/#{id}", :get
  end

  def myfreight_consignment_tracking id
    myfreight_request "/api/track_trace/#{id}", :get
  end

  def myfreight_manifests customer_id, filter
    myfreight_request "/api/users/switch_customer/#{customer_id}", :get
    myfreight_request( "/api/manifests?dateFilter=last_30_days", :get )['data']
  end

  def myfreight_ftp_upload file, user = 'generic', password = 'KBmhPtV8aqtyuWm'
    Net::FTP.open( MYFREIGHT_FTP, user, password ) do |ftp|
      ftp.putbinaryfile( file )
    end
  end

  def myfreight_request request_path, method, payload = {}, response_content_type = :json
    print("Sending #{MYFREIGHT_DOMAIN}#{request_path}                                               \r")
    uri = URI("#{MYFREIGHT_DOMAIN}#{request_path}")

    case method
    when :get
      req = Net::HTTP::Get.new(uri)

    when :post
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = payload.to_json
    end

    req.basic_auth myfreight_user[:username], myfreight_user[:token]
    http = Net::HTTP.new(uri.hostname, uri.port )
    http.use_ssl = true
    http.read_timeout = 4

    #TODO handle request failures
    begin
      response = http.request(req)
    rescue
      print "trying again                                                       \r"
      response = http.request(req)
    end

    case response_content_type
      when :json then JSON.parse response.body
      when :xml then Nokogiri::XML response.body
    else
      response.body
    end
  end
end

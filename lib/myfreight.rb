module Myfreight
  require 'nokogiri'
  require 'net/http'
  require 'net/ftp'
  require 'json'

  def self.user
    { username: ENV['MYFREIGHT_USER'], token: Secrets.myfreight_api_token }
  end

  def self.consignment id
    request "/api/consignments/#{id}", :get
  end

  def self.consignment_info id
    request "/api/consignment_information?id=#{id}", :get
  end

  def self.consignment_search query
    request "/api/consignments/search?query=#{query}", :get
  end

  def self.consignment_tracking id
    request "/api/track_trace/#{id}", :get
  end

  def self.manifests customer_id, filter
    request "/api/users/switch_customer/#{customer_id}", :get
    request( "/api/manifests?dateFilter=last_30_days", :get )['data']
  end

  def self.ftp_upload file, user = 'generic', password = 'KBmhPtV8aqtyuWm'
    Net::FTP.open( ENV['MYFREIGHT_FTP'], user, password ) do |ftp|
      ftp.putbinaryfile( file )
    end
  end

  def self.request request_path, method, payload = {}, response_content_type = :json
    # puts("Sending #{ENV['MYFREIGHT_DOMAIN']}#{request_path}")
    uri = URI("#{ENV['MYFREIGHT_DOMAIN']}#{request_path}")

    case method
    when :get
      req = Net::HTTP::Get.new(uri)

    when :post
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = payload.to_json
    end

    req.basic_auth user[:username], user[:token]
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

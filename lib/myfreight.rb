module Myfreight
  require 'nokogiri'
  require 'net/http'
  require 'net/ftp'
  require 'json'

  def self.user
    { username: ENV['MYFREIGHT_USER'], token: Secrets.myfreight_api_token }
  end

  def self.start_export customer_id, from_date, to_date, site_code = nil
    request "/api/users/switch_customer/#{customer_id}", :get
    puts ({ site_code: site_code, from_date: from_date.strftime("%d/%m/%Y"), to_date: to_date.strftime("%d/%m/%Y") }).to_json
    puts request "/api/exports", :post, { site_code: site_code, from_date: from_date.strftime("%d/%m/%Y"), to_date: to_date.strftime("%d/%m/%Y") }, :txt
  end

  def self.download_export id, out_path
    # Might not handle particularly large downloads
    redirect = request "/api/exports/#{id}", :get, nil, :html

    download_link = redirect.xpath('//a').first.attributes['href'].to_s

    uri = URI( download_link )

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Get.new(uri)

    resp = http.request req

    File.write out_path, resp.body

  end

  def self.consignment id
    request "/public/api/v1/consignments/#{id}", :get
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

  def self.request request_path, method, payload = {}, response_content_type = :json, attempt = 1
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
    http.open_timeout = 4
    http.read_timeout = 6
    response = {}
    
    begin
      response = http.request(req)
      puts response
    rescue
      print "\rAttempt #{attempt} failed"
      
      raise 'Exceeded more than five attempts' if attempt > 5 
      return request(request_path, method, payload, response_content_type, attempt + 1)
    end

    case response_content_type
      when :json then JSON.parse response.body
      when :xml then Nokogiri::XML response.body
      when :html then Nokogiri::HTML response.body
    else
      response.body
    end
  end
end

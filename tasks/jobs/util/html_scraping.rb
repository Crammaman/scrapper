require 'nokogiri'
require 'net/http'
require 'open-uri'

module Util

  def get_elements_from_page args
    page = get_page args[:url]
    page.xpath args[:path]
  end

  def get_page(url, attempts=1)

  	Nokogiri::HTML(open(url))

  rescue
  	if attempts <= 5 then

  		print "Failed Attempt #{attempts} \r"
  		get_page(url, attempts + 1)
  	end
  end
end

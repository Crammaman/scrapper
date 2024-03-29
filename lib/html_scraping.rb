module HtmlScraping
  require 'nokogiri'
  require 'net/http'
  require 'open-uri'


  def self.get_elements_from_page args
    page = get_page args[:url]

    unless page.nil?
      page.xpath args[:path]
    else
      ''
    end
  end

  def self.get_page(url, attempts=1)

  	Nokogiri::HTML(open(url))

  rescue
  	if attempts <= 5 then

  		print "Failed Attempt #{attempts} \r"
  		get_page(url, attempts + 1)
  	end
  end
end

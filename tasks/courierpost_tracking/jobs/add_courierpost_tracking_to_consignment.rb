class AddCourierpostTrackingToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    elements = HtmlScraping.get_elements_from_page url: @consignment[:tracking_url], path: '//li[@class="status"]'

    @consignment[:status] = elements[1].nil? ? 'Not on CP site' : elements[1].children[1].content

    unless @consignment[:status] != 'Delivered'

      date_string = elements[1].children[3].content
      date_parts = date_string.split('on')

      # Generic upload does not currently support time, only date.
      # date_parts[0] = '0' + date_parts[0] if date_parts[0].length == 7
      # date_parts[0] = date_parts[0].sub( '.', ':')

      @consignment[:actual_delivery_date] = Date.parse( "#{date_parts[1]}")

    else
      @consignment[:actual_delivery_date] = ''
    end

    @consignment
  end
end

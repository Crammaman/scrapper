class AddCourierpostTrackingToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    elements = get_elements_from_page url: @consignment[:tracking_url], path: '//li[@class="status"]'

    unless elements[1].nil?
      @consignment[:status] = elements[1].children[1].content

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

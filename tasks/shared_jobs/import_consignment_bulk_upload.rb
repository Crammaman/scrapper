require 'csv'
class ImportConsignmentBulkUploadSharedJob < Job
  def initialize input_path
    @input_path = input_path
  end

  def perform
    consignments = []
    consignment = {}

    CSV.foreach( @input_path, headers: :first_row ) do |row|
      if row['SITE CODE']
        consignment = {
          site_code:    row['SITE CODE'],
          reference:    row['REFERENCE'],
          receiver_name: row['NAME'],
          receiver_address_line_1: row['LINE1'],
          receiver_locality: row['LOCALITY'],
          receiver_region:   row['REGION'],
          receiver_postcode: row['POSTCODE'],
          items:        [ item( row ) ]
        }
        consignments << consignment
      else

        consignment[:items] << item( row )

      end
    end

    consignments
  end

  def item row
    {
      quantity:  row['QUANTITY'],
      item_type: row['ITEM TYPE'],
      length:    row['LENGTH CM'],
      width:     row['WIDTH CM'],
      height:    row['HEIGHT CM'],
      weight:    row['TOTAL WEIGHT KG']
    }
  end
end

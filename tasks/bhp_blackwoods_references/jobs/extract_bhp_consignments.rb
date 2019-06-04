require 'csv'

class ExtractBhpConsignmentsJob < Job
  def initialize output_path, codes
    @export_path = output_path
    @bhp_codes = codes
  end

  def perform

    consignments = []

    CSV.foreach( @export_path, headers: :first_row ) do |row|
      if @bhp_codes.include? row['Receiver Code']
        consignments << {
          consignment_number: row['Consignment Number'],
          references: row['Internal Reference'].split(/[, ]+/),
          receiver_name: row['Receiver Name'],
          total_weight: row['Total Dead Weight (kgs)'],
          total_volume: row['Total Volume (m3)'],
          item_count: row['Item Count']
        }
      end
    end

    consignments
  end
end

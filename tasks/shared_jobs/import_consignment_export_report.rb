require 'csv'

class ImportConsignmentExportReportSharedJob < Job
  def initialize input_path
    @input_path = input_path
  end

  def perform
    consignments = []

    CSV.foreach( @input_path, headers: :first_row ) do |row|
        consignments << {
          consignment_number: row['Consignment Number'],
          reference: row['Reference'],
          receiver_name: row['Receiver Name'],
          total_weight: row['Total Dead Weight (kgs)'],
          total_volume: row['Total Volume (m3)'],
          item_count: row['Item Count']
        }
    end

    consignments
  end
end

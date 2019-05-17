require 'csv'

class OutputConsignmentsJob < Job
  def initialize consignments, output_path
  @consignments = consignments
  @output_path = output_path
  end

  def perform
  CSV.open( @output_path, 'wb') do |csv|
    csv << [ 'Consignment Number', 'Purchase Order', 'Receiver Name', 'Total Dead Weight', 'Total Volume', 'Item Count']

    @consignments.each do |c|
       c[:references].each do |ref|
         csv << [
           c[:consignment_number],
           ref.strip,
           c[:receiver_name],
           c[:total_weight],
           c[:total_volume],
           c[:item_count]
         ]
       end
       [' ',' ',' ',' ',' ',' ']
     end
   end
  end
end

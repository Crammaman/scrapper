class OutputConsignmentsInfoJob < Job
  def initialize consignments_info
    @consignments_info = consignments_info
  end
  
  def perform
    CSV.open("output/#{task_name}/consignment_info.csv", 'wb')do |csv|
      csv << @consignments_info.first.keys
      @consignments_info.each do |info|
        csv << info.values unless info.nil?
      end
    end
  end
end

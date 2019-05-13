class OutputQueryResultsJob < Job
  def initialize results, absolute_path = nil
    @results = results
    @output_path = absolute_path || "output/#{task_name}/query_results.csv"
  end

  def perform
    CSV.open( @output_path, 'wb') do |csv|
      csv << @results.fields
      @results.each do |row|
        csv << row
      end
    end
  end
end

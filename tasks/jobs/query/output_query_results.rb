class OutputQueryResultsJob < Job
  def initialize results
    @results = results
  end

  def perform
    
    @results.each do |row|
      puts row
    end
  end
end

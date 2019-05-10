require_relative 'jobs/query/jobs'

class Query < Task
  def initialize args
    @query_name = args[ :query_name ]
    @query_args = args[ :query_args ]
    super()
  end

  def run
    results = RunQueryJob.perform_now query_name: @query_name, query_args: @query_args
    OutputQueryResultsJob.perform_now results
  end
end

class Query < Task
  def initialize args
    @query_name = args[ :query_name ]

    @query_args = query_args_to_hash args[ :query_args ]

  end

  def run
    results = RunQueryJob.perform_now query_name: @query_name, query_args: @query_args
    OutputQueryResultsJob.perform_now results, output_path
  end

  private
  def query_args_to_hash args
    args.reduce({}) do | acc, arg |

      var, value = arg.split('=')
      raise "Invalid argument #{arg}" if var.nil? || value.nil?

      acc[ var ] = value
      acc
    end
  end

  def output_path
    if @query_args.keys.include? 'customer_code'
      "output/#{task_name}/#{@query_args['customer_code']}_#{@query_name}.csv"

    elsif @query_args.keys.include? 'carrier_code'
      "output/#{task_name}/#{@query_args['carrier_code']}_#{@query_name}.csv"
    end
  end
end

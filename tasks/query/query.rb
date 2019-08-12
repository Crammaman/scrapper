class Query < Task
  def initialize args
    @query_name = args[ :query_name ]

    @email_to = shift_if_first_is_email! args[ :query_args ]
    @query_args = query_args_to_hash args[ :query_args ]

  end

  def run
    results = RunQueryJob.perform_now query_name: @query_name, query_args: @query_args
    OutputQueryResultsJob.perform_now results, output_path

    if @email_to
      SendEmailSharedJob.perform_now(
        from: 'sam.adams@myfreight.com.au',
        to: @email_to,
        subject: email_subject,
        body: 'Here you go.',
        attachment: output_path
      )
    end
  end

  private
  def shift_if_first_is_email! query_args
    # Has an @ but is not an query parameter as it doesn't have an =
    if query_args.first&.include?('@') && !query_args.first&.include?('=')
      query_args.shift
    end
  end

  def email_subject
    file_name.gsub('_', ' ').gsub('%','All')[0..-5]
  end

  def query_args_to_hash args
    args.reduce({}) do | acc, arg |

      var, value = arg.split('=')
      raise "Invalid argument #{arg}" if var.nil? || value.nil?

      acc[ var ] = value
      acc
    end
  end

  def file_name
    if @query_args.keys.include? 'customer_code'
      "#{@query_args['customer_code']}_#{@query_name}.csv"

    elsif @query_args.keys.include? 'carrier_code'
      "#{@query_args['carrier_code']}_#{@query_name}.csv"
    else
      "#{@query_name}.csv"
    end
  end

  def output_path
    "output/#{task_name}/#{file_name}"
  end
end

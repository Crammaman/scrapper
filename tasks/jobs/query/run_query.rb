class RunQueryJob < Job
  def initialize args
    @query = File.read( "input/query/#{args[ :query_name ]}.sql" ).split(';')
    @query_args = args[ :query_args ]
  end

  def perform
    @query_args.each do |arg|
      set_query_variable arg
    end

    result = nil
    DB.run_query do |runner|
      @query.each do |statement|
        result = runner.query statement
      end
    end

    result
  end

  def set_query_variable arg

    var, value = arg.split('=')

    raise "Invalid argument #{arg}" if var.nil? || value.nil?
    @query.unshift "SET @#{var}='#{value}' COLLATE utf8_unicode_ci;\n"
  end
end

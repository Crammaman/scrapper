class RunQueryJob < Job
  def initialize args
    @query = File.read( "input/query/#{args[ :query_name ]}.sql" ).split(';')
    @query_args = args[ :query_args ]
  end

  def perform
    @query_args.each do |key, value|
      set_query_variable key, value
    end

    result = nil
    Database.query do |connection|
      @query.each do |statement|
        result = connection.execute statement
      end
    end

    result
  end

  def set_query_variable key,value
    @query.unshift "SET @#{key}='#{value}' COLLATE utf8_unicode_ci;\n"
  end
end

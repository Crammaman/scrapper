module Database
  require 'active_record'
  require 'mysql2'
  require 'logger'

  ActiveRecord::Base.logger = Logger.new('log/database.log')
  configuration = YAML::load(IO.read('config/database.yml'))
  ActiveRecord::Base.establish_connection(configuration[ENV['SCRAPPER_ENV']])

  def self.query statement = nil

    unless statement.nil?

      ActiveRecord::Base.connection.execute statement

    else

      yield ActiveRecord::Base.connection

    end
  end
end

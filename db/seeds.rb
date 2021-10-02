require 'mysql2'
  ## Locality assumes the existance of a wilberforce database ##
WILBERFORCE_DB = Mysql2::Client.new( host: 'localhost', username: ENV['DB_USER'], password: Secrets.db_password, database: 'wilberforce')

localities = WILBERFORCE_DB.query "select * from localities"

localities.map do |row|

  Locality.update_or_create id: row['id'].to_i, postcode: row['postcode'], locality: row['locality'], region: row['region'], sublocality: row['sublocality'], country: row['country']
end

require 'active_record'
require 'activerecord-import'

ActiveRecord::Base.logger = Logger.new('log/active_record.log')
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection( configuration[ ENV['SCRAPPER_ENV'] ] )
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Used for copying data from Myfreight, find the record by id or create it.
  def self.update_or_create(attributes)
    obj = assign_or_new(attributes)
    obj.save
    obj
  end

  def self.assign_or_new(attributes)
    id = attributes["id"] || attributes[:id]
    obj = self.find_by(id: id) || new
    obj.assign_attributes(attributes)
    obj
  end
end

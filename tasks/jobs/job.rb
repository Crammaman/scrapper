require_relative 'util/util'
class Job
  include Util

  def perform
    throw "Job #{self.class} has not implemented perform"
  end

  def self.perform_now *args
    self.new( *args ).perform
  end
end

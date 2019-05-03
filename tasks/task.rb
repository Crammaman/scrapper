require_relative 'jobs/shared/jobs'
class Task

  def run
    throw "Run not implemented for task #{self.class}"
  end
end

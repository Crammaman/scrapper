class Job

  def perform
    throw "Job #{self.class} has not implemented perform"
  end

  def task_name
    TASK_NAME
  end

  def self.perform_now *args
    puts "Performing #{self.name}"
    self.new( *args ).perform
  end
end

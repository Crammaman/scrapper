class Task

  attr_accessor :task_name
  def task_name
    @task_name || 'Task name not set'
  end

  def run
    throw "Run not implemented for task #{self.class}"
  end
end

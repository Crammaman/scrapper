class Task

  def task_name
    TASK_NAME || 'Task name not set'
  end

  def run
    throw "Run not implemented for task #{self.class}"
  end
end

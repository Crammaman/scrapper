class JobSet
  include Enumerable

  def self.perform_now_in_batches_of batch_size, job, args_array
    job_set = new job, args_array
    job_set.perform_in_batches_of batch_size
  end

  def initialize job, args_array
    @jobs = args_array.map { |args| job.new args }
  end

  def each
    @jobs.each { |job| yield job }
  end

  def perform_in_batches_of batch_size
    results = []
    threads = []

    mutex = Mutex.new
    count = 1
    each_slice( batch_size) do |job_batch|

      job_batch.each do |job|
        threads << Thread.new do
          results << job.perform

          print "  #{count} out of #{@jobs.length} complete for #{job.class}\r"

          mutex.synchronize do
            count += 1
          end
        end
      end

      threads.each { |thread| thread.join }

    end

    results
  end
end

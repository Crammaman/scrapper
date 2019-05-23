class JobSet
  include Enumerable

  def self.perform_now_in_batches_of batch_size, job, args_array
    job_set = new job, args_array
    job_set.perform_in_batches_of batch_size
  end

  def self.perform_now job, args_array
    job_set = new job, args_array
    job_set.map do |job|
      job.perform
    end
  end

  def initialize job, args_array
    @job = job
    @jobs = args_array.map { |args| job.new args }
  end

  def each
    @jobs.each { |job| yield job }
  end

  def perform_in_batches_of batch_size
    results = []
    threads = []

    if @jobs.length == 0

      puts "No jobs to perform for #{@job}"
      return results

    end

    mutex = Mutex.new
    count = 0
    each_slice( batch_size) do |job_batch|

      job_batch.each do |job|
        threads << Thread.new do
          results << job.perform

          mutex.synchronize do
            count += 1
          end

          print "\r  #{count} out of #{@jobs.length} complete for #{job.class}"

        end
      end

      threads.each { |thread| thread.join }

    end

    puts "\r#{count} out of #{@jobs.length} complete for #{@jobs[0].class}  "

    results
  end
end

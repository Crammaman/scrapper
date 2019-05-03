class JobSet
  include Enumerable

  def initialize job, args_array
    @jobs = args_array.map { |args| job.new args }
  end

  def each
    @jobs.each { |job| yield job }
  end

  def perform_in_batches_of batch_size
    results = []
    threads = []
    each_slice(10) do |job_batch|

      job_batch.each do |job|
        threads << Thread.new { results << job.perform }
      end

      threads.each { |thread| thread.join }

    end

    results
  end
end

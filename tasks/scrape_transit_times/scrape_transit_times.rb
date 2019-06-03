class ScrapeTransitTimes < Task
  def initialize args
    @carrier = Carrier.find_by code: args[:carrier_code].upcase
  end

  def run
    # Just to stop warning about already loaded constant from concurrent loading.
    Tnt
    count = 1
    request_jobs_params = []

    Locality.each_pair_without_transit_time( @carrier, from_localities: from_localities, to_localities: to_localities ) do | from_locality, to_locality |

      request_jobs_params << { carrier: @carrier, from_locality: from_locality, to_locality: to_locality }

      if count % 10 == 0
        transit_request_jobs = JobSet.new RequestTransitTimeJob, request_jobs_params

        transit_times = transit_request_jobs.perform_in_batches_of 10

        SaveTransitTimesJob.perform_now transit_times: transit_times
        request_jobs_params = []
        break
      end

      count += 1
    end
  end

  def from_localities
    Locality.metro_localities
  end
  def to_localities
    Locality.metro_localities
  end
end

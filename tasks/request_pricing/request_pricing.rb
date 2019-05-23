class RequestPricing < Task
  def initialize args
    @import_paths = import_paths args[:import_paths]
  end

  def run
    consignments = JobSet.perform_now ImportConsignmentBulkUploadSharedJob, @import_paths
    consignments.flatten!
    consignments.each_with_index { |c,i|
      c[:id] = i
      c[:despatch_date] = Date.today
      c[:customer_code] = 'BLACK'
    }
    responses = JobSet.perform_now RequestPricingFromSsi, consignments
    puts responses
  end

  private
  def import_paths paths
    unless paths.nil?
      paths.split(',')

    else
      Dir.entries("input/#{task_name}").reduce([]) do | acc, file |

        if file.starts_with?( "bulk_upload")
          acc << "input/#{task_name}/#{file}"
        end

        acc
      end
    end
  end
end

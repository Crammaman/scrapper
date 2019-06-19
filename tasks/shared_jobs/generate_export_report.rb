class GenerateExportReportSharedJob < Job
  def initialize args
    @customer_id = args[:customer_id]
    @site_code = args[:site_code]
    @from_date = args[:from_date]
    @to_date   = args[:to_date]
    @output_path = args[:output_path] || "output/#{task_name}/#{task_name}_consignment_export.csv"
  end
  def perform
    receiving_email = ENV['SCRAPPER_ENV'] == 'production' ? ENV['MYFREIGHT_USER'] : 'devs@myfreight.com.au'
    query = "from:(no-reply@myfreight.com.au) to:#{receiving_email} subject:(Myfreight - Consignment Report) consignment report after:#{Date.today - 1} before:#{Date.today + 1}"

    # Clear out pre existing exports
    gmail = Gmail.new
    search_result = gmail.search query

    gmail.delete search_result unless search_result.nil?

    Myfreight.start_export( @customer_id, @from_date, @to_date, @site_code )

    search_result = nil
    count = 0
    until search_result
      search_result = gmail.search query
      if search_result.nil?
        sleep(60)
        count += 1

      elsif count > 360
        raise 'Export report not found within 3 hours'
      end
    end

    export_email = gmail.get_message search_result[0].id

    export_id = /#{ENV['MYFREIGHT_DOMAIN']}\/api\/exports\/([^']*)/.match( export_email.payload.body.data )[1]

    Myfreight.download_export export_id, @output_path
  end
end

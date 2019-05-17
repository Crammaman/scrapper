class BhpBlackwoodsReferences < Task
  def run
    # GenerateExportReportSharedJob.perform_now customer_id: 164, site_code: 'BT4015-01', from_date: Date.today, to_date: Date.today
    consignments = ExtractBhpConsignmentsJob.perform_now "output/bhp_blackwoods_references/bhp_blackwoods_references_consignment_export.csv", %w(M121997 M202787 M078537 M237023 M235657 M237025 M237026 M237029)
    OutputConsignmentsJob.perform_now consignments, "output/bhp_blackwoods_references/BHP Consignments.csv"
    SendEmailSharedJob.perform_now(
      from: 'techsupport@myfreight.com.au',
      to:   'john.plesek@blackwoods.com.au',
      body: 'Hi John, This is an example of what I\' put together, let me know if this is what they\'ll want or if I have to change it at all. Please forward to me rather than reply to the tech support address',
      attachment: "output/#{task_name}/BHP Consignments.csv"
    )
  end
end

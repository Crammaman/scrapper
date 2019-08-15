class ExportToDomo < Task
  def run
    results = RunManagedAccountsQueryJob.perform_now
    OutputQueryResultsSharedJob.perform_now results, managed_accounts_path
    
    results = RunCarrierDetailsQueryJob.perform_now
    OutputQueryResultsSharedJob.perform_now results, carrier_details_path
    
    SendEmailSharedJob.perform_now(
      from: 'api@myfreight.com.au',
      to: "1799772a37154aa8a055d8896f2d572b@myfreight-com-au.mail.domo.com",
      subject: "Managed Accounts",
      body: "All carriers for all Myfreight customers and if they are managed",
      attachment: managed_accounts_path
    )
  end
  
  private 
  def managed_accounts_path
    "output/#{task_name}/managed_accounts.csv"
  end
  def carrier_details_path
    "output/#{task_name}/carrier_details.csv"
  end
end

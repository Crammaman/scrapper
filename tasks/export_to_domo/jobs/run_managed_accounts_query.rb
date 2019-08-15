class RunManagedAccountsQueryJob < Job
  def perform
    Database.query(File.read("input/export_to_domo/accounts_list.sql"))
  end
end

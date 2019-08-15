class RunCarrierDetailsQueryJob < Job
  def perform
    Database.query(File.read("input/export_to_domo/carrier_details.sql"))
  end
end

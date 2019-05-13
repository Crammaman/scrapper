class GetConsignmentListJob < Job
  def initialize customer_id
    @customer_id = customer_id
  end

  def perform
    manifests = Myfreight.manifests( @customer_id, 'last_30_days' )

    manifests.map do |manifest|
      manifest['consignments'].map do |consignment_data|
        { id: consignment_data['id'], consignment_number: consignment_data['consignment_number']}
      end
    end.flatten!
  end
end

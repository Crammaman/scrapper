class Locality < ApplicationRecord

  def to_s
    "Locality ( Postcode: #{postcode} Locality: #{locality} Sublocality: #{sublocality} Region: #{region} )"
  end

  def self.metro_localities
    sydney + melbourne + perth + darwin + brisbane + hobart
  end

  def self.adelaide
    self.where( "postcode > '5000' AND postcode < '5199'" )
  end

  def self.canberra
    self.where( "postcode > '2600' AND postcode < '2609'" )
  end

  def self.sydney
    self.where( "postcode > '2000' AND postcode < '2234'" )
  end

  def self.melbourne
    self.where( "postcode > '3000' AND postcode < '3207'" )
  end

  def self.perth
    self.where( "postcode > '6000' AND postcode < '6199'" )
  end

  def self.darwin
    self.where( "postcode > '0800' AND postcode < '0832'" )
  end

  def self.brisbane
    self.where( "postcode > '4000' AND postcode < '4207' OR postcode > '4300' AND postcode < '4305' OR postcode > '4500' AND postcode < '4519'" )
  end

  def self.hobart
    self.where( "postcode > '7000' AND postcode < '7099'" )
  end


  def self.each_pair_without_transit_time carrier, batch_size: 1000, from_localities: [], to_localities: []

    from_localities_query = locality_query from_localities
    to_localities_query = locality_query to_localities

    while results = ActiveRecord::Base.connection.select_rows("SELECT
      lf.id as 'from_id', lf.postcode as 'from_postcode', lf.locality as 'from_locality', lf.region as 'from_region', lf.sublocality as 'from_sublocality', lf.country as 'from_country',
      lt.id as 'to_id', lt.postcode as 'to_postcode', lt.locality as 'to_locality', lt.region as 'to_region', lt.sublocality as 'to_sublocality', lt.country as 'to_country'
      FROM (#{from_localities_query}) lf
      JOIN (#{to_localities_query}) lt
      LEFT JOIN transit_times tt on tt.from_locality_id = lf.id and tt.to_locality_id = lt.id and tt.carrier_id = #{carrier.id}
      WHERE tt.id IS NULL
      LIMIT #{batch_size}
    ")
      results.each do |row|
        from_locality = self.new id: row[0].to_i, postcode: row[1], locality: row[2], region: row[3], sublocality: row[4], country: row[5]
        to_locality = self.new id: row[6].to_i, postcode: row[7], locality: row[8], region: row[9], sublocality: row[10], country: row[11]

        yield from_locality, to_locality
      end
    end
  end


  private
  def self.locality_query localities
    if localities.length == 0
      "SELECT * FROM localities"
    else
      "SELECT * FROM localities WHERE id IN (#{localities.pluck(:id).join(',')})"
    end
  end
end

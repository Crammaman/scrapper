class Location < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :postcode
      t.string :locality
      t.string :sublocality
      t.string :region
      t.string :country
      t.string :zone
      t.references :carrier
      t.json :carrier_info
      t.timestamps
    end
  end
end

class Localities < ActiveRecord::Migration[5.2]
  def change
    create_table :localities do |t|
      t.string :postcode
      t.string :locality
      t.string :region
      t.string :country
      t.string :sublocality
    end
  end
end

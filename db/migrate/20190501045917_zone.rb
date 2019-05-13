class Zone < ActiveRecord::Migration[5.2]
  def change
    create_table :zones do |t|
      t.string :code
      t.references :carrier
      t.references :locality
    end
  end
end

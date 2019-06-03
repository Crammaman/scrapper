class CreateTransitTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :transit_times do |t|
      t.references :carrier
      t.references :from_locality, index: true, foreign_key: { to_table: :localities }
      t.references :to_locality, index: true, foreign_key: { to_table: :localities }
      t.integer :days
    end
  end
end

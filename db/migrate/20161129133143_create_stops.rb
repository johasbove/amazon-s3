class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.string :nid
      t.float :latitude
      t.float :longitude
      t.time :arrives_at
      t.time :departs_at
      t.references :route, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

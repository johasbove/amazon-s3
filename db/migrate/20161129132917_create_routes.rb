class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :nid
      t.time :depot_at
      t.integer :depot
      t.string :action
      t.references :upload, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

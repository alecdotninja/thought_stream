class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :handle, null: false

      t.timestamps null: false
    end

    add_index :locations, [:handle], unique: true
  end
end

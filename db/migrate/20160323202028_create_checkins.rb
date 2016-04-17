class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.belongs_to :thought, foreign_key: true, null: false
      t.belongs_to :location, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_index :checkins, [:thought_id], unique: true
  end
end

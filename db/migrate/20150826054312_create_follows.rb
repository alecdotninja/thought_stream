class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.belongs_to :follower, index: true, null: false
      t.belongs_to :followee, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :follows, :users, column: :follower_id
    add_foreign_key :follows, :users, column: :followee_id

    add_index :follows, [:follower_id, :followee_id], unique: true
    add_index :follows, [:followee_id, :follower_id], unique: true
  end
end

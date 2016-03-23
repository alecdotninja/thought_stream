class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.belongs_to :follower, index: true
      t.belongs_to :followed, index: true

      t.timestamps null: false
    end

    add_foreign_key :follows, :users, column: :follower_id
    add_foreign_key :follows, :users, column: :followed_id
  end
end

class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.belongs_to :thought, index: true, foreign_key: true, null: false
      t.belongs_to :mentionee, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :mentions, :users, column: :mentionee_id
  end
end

class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.belongs_to :thought, index: true, foreign_key: true
      t.belongs_to :mentioned, index: true

      t.timestamps null: false
    end

    add_foreign_key :mentions, :users, column: :mentioned_id
  end
end

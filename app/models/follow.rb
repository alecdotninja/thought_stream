class Follow < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  validates :follower, :followee, presence: true
  validates :follower_id, uniqueness: { scope: [:followee_id] }

  def self.friendly
    all.tap do |friendly|
      counterparts = arel_table.alias('counterparts')

      friendly.where!(
        friendly.table[:id].in(
           arel_table.project(
             arel_table[:id]
           ).join(
             counterparts
           ).on(
             counterparts[:follower_id].eq(
               arel_table[:followee_id]
             ).and(
               counterparts[:followee_id].eq(
                 arel_table[:follower_id]
               )
             )
           )
        )
      )
    end
  end
end

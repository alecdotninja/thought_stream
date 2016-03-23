class Checkin < ActiveRecord::Base
  belongs_to :thought, inverse_of: :checkin
  belongs_to :location, inverse_of: :checkins

  has_one :user, through: :thought

  validates :location, :thought, presence: true

  scope :most_recent_for_user, -> {
    where(
      arel_table[:id].in(
        arel_table.project(
          arel_table[:id]
        ).join(
          Thought.arel_table,
          Arel::Nodes::InnerJoin
        ).on(
          Thought.arel_table[:id].eq(
            arel_table[:thought_id]
          )
        ).distinct_on([
          Thought.arel_table[:user_id]
        ]).order(
          Thought.arel_table[:user_id].asc,
          arel_table[:created_at].desc
        )
      )
    )
  }
end

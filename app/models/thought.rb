class Thought < ActiveRecord::Base
  MENTION_MATCHER = /~([a-z][a-z0-9]+)/i

  belongs_to :user, inverse_of: :thoughts

  has_many :mentions, inverse_of: :thought
  has_many :mentioned_users, through: :mentions, source: :mentioned

  validates :user, :message, presence: true
  validates :message, length: { maximum: 128 }

  validate :message_has_not_changed, unless: :new_record?

  after_save :enumerate_mentions!, on: [:create]

  after_commit { ThoughtRelayJob.perform_later(self) }

  AVERAGE_TIME_BETWEEN_CREATED_ATS_SECONDS_EXPRESSION = Arel::Nodes::Division.new(
    Arel::Nodes::Grouping.new(
      Arel::Nodes::Subtraction.new(
        Arel::Nodes::Extract.new(
          Arel::Nodes::NamedFunction.new('MAX', [
            arel_table[:created_at]
          ]),
          'EPOCH'
        ),
        Arel::Nodes::Extract.new(
          Arel::Nodes::NamedFunction.new('MIN', [
            arel_table[:created_at]
          ]),
          'EPOCH'
        )
      )
    ),
    Arel::Nodes::Grouping.new(
      Arel::Nodes::Subtraction.new(
        Arel::Nodes::NamedFunction.new('COUNT', [
          arel_table[:created_at]
        ]),
        1
      )
    )
  ).freeze

  def self.average_time_between_created_ats
    pluck(AVERAGE_TIME_BETWEEN_CREATED_ATS_SECONDS_EXPRESSION).first.try(:seconds)
  end

  private

  def message_has_not_changed
    errors.add(:message, 'cannot be changed') if message_changed?
  end

  def enumerate_mentions!
    message.scan(/~([a-z][a-z0-9]+)/i).each do |handle|
      user = User.find_by(handle: handle)

      mentions << Mention.new(mentioned: user) if user
    end
  end
end

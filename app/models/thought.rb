class Thought < ActiveRecord::Base
  MENTION_MATCHER = /~([a-z][a-z0-9_]+)/i
  CHECKIN_MATCHER = /@([a-z][a-z0-9_]+)/i

  belongs_to :user, inverse_of: :thoughts

  has_many :mentions, inverse_of: :thought, dependent: :destroy
  has_many :mentioned_users, through: :mentions, source: :mentioned

  has_one :checkin, inverse_of: :thought, dependent: :destroy

  scope :on_a_topic_before_a_time, ->(query, time = Time.now) {
    where(
        arel_table[:message].matches("%#{sanitize_sql_like(query)}%").and(
            arel_table[:created_at].lteq(time)
        )
    )
  }

  validates :user, :message, presence: true
  validates :message, length: { maximum: 128 }

  validate :message_has_not_changed, unless: :new_record?

  after_save :detect_mentions!, on: [:create]
  after_save :detect_checkin!, on: [:create]

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

  def detect_checkin!
    message.scan(CHECKIN_MATCHER).each do |match|
      handle = match.first

      location = Location.find_or_create_by!(handle: handle)

      if location.present?
        Checkin.create!(thought: self, location: location)
      end
    end
  end

  def detect_mentions!
    message.scan(MENTION_MATCHER).each do |match|
      handle = match.first

      user = User.find_by(handle: handle)

      if user.present?
        mentions.create!(mentioned: user)
      end
    end
  end
end

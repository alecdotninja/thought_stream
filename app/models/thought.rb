class Thought < ActiveRecord::Base
  MENTION_MATCHER = /~([a-z][a-z0-9_]+)/i
  CHECKIN_MATCHER = /@([a-z][a-z0-9_]+)/i

  belongs_to :user, inverse_of: :thoughts

  has_many :mentions, inverse_of: :thought, dependent: :destroy
  has_many :mentionees, through: :mentions, source: :mentionee

  has_one :checkin, inverse_of: :thought, dependent: :destroy

  validates :user, :message, presence: true
  validates :message, length: { maximum: 128 }

  validate :message_has_not_changed, unless: :new_record?

  after_save :detect_mentions!, on: [:create]
  after_save :detect_checkin!, on: [:create]

  after_commit { ThoughtRelayJob.perform_later(self) }

  # scope :on_a_topic_before_a_time, ->(query, time = Time.now) {
  #   where(
  #     arel_table[:message].matches("%#{sanitize_sql_like(query)}%").and(
  #       arel_table[:created_at].lteq(time)
  #     )
  #   )
  # }

  def self.on_topic(topic)
    all.tap do |on_topic|
      on_topic.where!(
        on_topic.table[:message].matches(
          Arel::Nodes::BindParam.new
        )
      )

      on_topic.bind!(
        [columns_hash['message'], "%#{sanitize_sql_like(topic)}%"]
      )
    end
  end

  def self.created_before(time)
    all.tap do |created_before|
      created_before.where!(
        created_before.table[:created_at].lt(
          Arel::Nodes::BindParam.new
        )
      )

      created_before.bind!(
        [columns_hash['created_at'], time]
      )
    end
  end

  def self.average_time_between_created_ats
    scope = all

    rows = scope.pluck(
      Arel::Nodes::Division.new(
        Arel::Nodes::Grouping.new(
          Arel::Nodes::Subtraction.new(
            Arel::Nodes::Extract.new(
              Arel::Nodes::NamedFunction.new('MAX', [
                scope.table[:created_at]
              ]),
              'EPOCH'
            ),
            Arel::Nodes::Extract.new(
              Arel::Nodes::NamedFunction.new('MIN', [
                scope.table[:created_at]
              ]),
              'EPOCH'
            )
          )
        ),
        Arel::Nodes::Grouping.new(
          Arel::Nodes::Subtraction.new(
            Arel::Nodes::NamedFunction.new('COUNT', [
              scope.table[:created_at]
            ]),
            1
          )
        )
      )
    )

    rows.first.try(:seconds)
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
        mentions.create!(mentionee: user)
      end
    end
  end
end
